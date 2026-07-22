import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/services/audio_engine.dart';
import '../../../data/models/song.dart';

/// Owns the playback queue and transport state for the whole app.
///
/// The mini-player and the Now Playing screen are both views onto this
/// controller, which is why queue state lives here rather than in either
/// screen.
class PlaybackController extends ChangeNotifier {
  PlaybackController({required AudioEngine engine, Random? random})
    : _engine = engine,
      _random = random ?? Random() {
    _positionSubscription = _engine.positionStream.listen(_onPositionChanged);
    _completionSubscription = _engine.trackCompletions.listen(
      (_) => unawaited(next()),
    );
  }

  /// Pressing previous past this point restarts the track instead of going
  /// back a track — the behavior every player has trained users to expect.
  static const _restartThreshold = Duration(seconds: 3);

  final AudioEngine _engine;
  final Random _random;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<void> _completionSubscription;

  List<Song> _queue = const [];

  /// Indices into [_queue], in the order they will play. Shuffle reorders this
  /// rather than the queue itself, so turning shuffle off restores the
  /// original order without a reload.
  List<int> _order = const [];
  int _orderIndex = -1;

  bool _isPlaying = false;
  bool _isShuffleEnabled = false;
  Duration _position = Duration.zero;

  List<Song> get queue => List.unmodifiable(_queue);

  Song? get currentSong => _orderIndex < 0 || _orderIndex >= _order.length
      ? null
      : _queue[_order[_orderIndex]];

  bool get isPlaying => _isPlaying;
  bool get isShuffleEnabled => _isShuffleEnabled;
  Duration get position => _position;
  Duration get duration => currentSong?.duration ?? Duration.zero;

  /// Playback progress from 0 to 1, safe to hand straight to a progress bar.
  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (_position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  /// Replaces the queue with [songs] and starts playing at [startIndex].
  ///
  /// Missing files are dropped from the queue rather than played and failed;
  /// if [startIndex] points at one, playback starts from the next playable
  /// track instead.
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    final playable = songs.where((song) => !song.isMissing).toList();
    if (playable.isEmpty) return;

    _queue = playable;
    _setOrder(startAt: _resolveStart(songs, playable, startIndex));

    await _loadCurrent();
    await _resume();
  }

  Future<void> togglePlayPause() async {
    if (currentSong == null) return;
    if (_isPlaying) {
      await _engine.pause();
      _isPlaying = false;
      notifyListeners();
      return;
    }
    await _resume();
  }

  /// Advances to the next track, stopping at the end of the queue.
  Future<void> next() async {
    if (currentSong == null) return;

    if (_orderIndex >= _order.length - 1) {
      await _engine.pause();
      await _engine.seek(Duration.zero);
      _isPlaying = false;
      notifyListeners();
      return;
    }

    _orderIndex++;
    await _loadCurrent();
    await _resume();
  }

  /// Restarts the current track, or steps back one if it just started.
  Future<void> previous() async {
    if (currentSong == null) return;

    if (_position > _restartThreshold || _orderIndex == 0) {
      await _engine.seek(Duration.zero);
      return;
    }

    _orderIndex--;
    await _loadCurrent();
    await _resume();
  }

  Future<void> seek(Duration position) => _engine.seek(position);

  /// Toggles shuffle, keeping the current track playing in place.
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;

    final current = currentSong;
    if (current == null) {
      notifyListeners();
      return;
    }

    _setOrder(startAt: _queue.indexOf(current));
    notifyListeners();
  }

  /// Keeps the queue in sync when a song's metadata changes elsewhere, e.g.
  /// after a like toggle or a tag edit.
  void syncSong(Song song) {
    final index = _queue.indexWhere((candidate) => candidate.id == song.id);
    if (index == -1) return;

    _queue = List.of(_queue)..[index] = song;
    notifyListeners();
  }

  /// Maps [startIndex] in [songs] onto an index in the [playable] queue.
  ///
  /// When the requested song is missing, playback moves forward to the next
  /// file that is actually there rather than refusing to start.
  static int _resolveStart(
    List<Song> songs,
    List<Song> playable,
    int startIndex,
  ) {
    for (var i = max(0, startIndex); i < songs.length; i++) {
      final index = playable.indexWhere((song) => song.id == songs[i].id);
      if (index != -1) return index;
    }

    return 0;
  }

  /// Rebuilds the play order around [startAt] and points at that track.
  ///
  /// Shuffling promotes [startAt] to the front so the track the user picked
  /// still plays first; in order, the queue plays from [startAt] onward.
  void _setOrder({required int startAt}) {
    final natural = [for (var i = 0; i < _queue.length; i++) i];

    if (!_isShuffleEnabled) {
      _order = natural;
      _orderIndex = startAt;
      return;
    }

    final rest = natural.where((index) => index != startAt).toList()
      ..shuffle(_random);
    _order = [startAt, ...rest];
    _orderIndex = 0;
  }

  Future<void> _loadCurrent() async {
    final song = currentSong;
    if (song == null) return;

    _position = Duration.zero;
    await _engine.load(song);
    notifyListeners();
  }

  Future<void> _resume() async {
    await _engine.play();
    _isPlaying = true;
    notifyListeners();
  }

  void _onPositionChanged(Duration position) {
    _position = position;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_positionSubscription.cancel());
    unawaited(_completionSubscription.cancel());
    unawaited(_engine.dispose());
    super.dispose();
  }
}
