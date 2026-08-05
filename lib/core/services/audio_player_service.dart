import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';

/// How the queue repeats once playback reaches its natural end.
///
/// Mirrors just_audio's own [LoopMode] for the gapless engine; the crossfade
/// engine implements the same semantics itself since it doesn't use
/// just_audio's playlist/loop machinery (see [AudioPlayerService._peekNextIndex]).
enum RepeatMode { off, one, all }

/// Thin wrapper around the underlying audio engine ([AudioPlayer]).
///
/// Keeps `just_audio` out of the feature/application layer so the engine
/// can be swapped later without touching playback controllers.
///
/// Runs one of two internal engines depending on the crossfade setting:
///  * **Gapless engine** (crossfade off) — a single `AudioPlayer` driving
///    just_audio's own gapless playlist (`setAudioSources`/`seekToNext`/
///    `shuffle`). Proven, sample-accurate, left untouched.
///  * **Crossfade engine** (crossfade on) — two `AudioPlayer`s ping-ponging:
///    while the active one nears the end of its track, the standby one is
///    started on the next track at volume 0 and the two are cross-faded in
///    real time, so both tracks are genuinely audible during the overlap
///    (SRS F-1.4). just_audio can't overlap two sources on a single engine,
///    hence the second player. A manual skip (`seekToNext`/`seekToPrevious`)
///    always swaps instantly — only the natural end-of-track transition
///    fades.
/// Both engines feed the same public broadcast streams, so
/// [PlaybackController] and the UI never need to know which is active.
class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) {
    _gaplessPlayer = player ?? _createEqualizedPlayer();
    _gaplessErrorSubscription = _gaplessPlayer.errorStream.listen(
      _onGaplessError,
    );
    _bindGaplessForwarding();
  }

  // -- Gapless engine -------------------------------------------------
  late final AudioPlayer _gaplessPlayer;
  late final StreamSubscription<PlayerException> _gaplessErrorSubscription;

  // -- Crossfade engine (lazily created only while crossfade is on) ---
  AudioPlayer? _fadeA;
  AudioPlayer? _fadeB;
  StreamSubscription<PlayerException>? _fadeAErrorSubscription;
  StreamSubscription<PlayerException>? _fadeBErrorSubscription;
  bool _fadeActiveIsA = true;
  bool _fadeRampInProgress = false;
  Timer? _fadeRampTimer;

  /// Index (into [_queue]) loaded into the current standby fade player, or
  /// `null` if nothing is preloaded there yet. Used to attribute a fade
  /// player's playback error to the right song.
  int? _standbyIndex;

  AudioPlayer? get _activeFadePlayer => _fadeActiveIsA ? _fadeA : _fadeB;
  AudioPlayer? get _standbyFadePlayer => _fadeActiveIsA ? _fadeB : _fadeA;

  // -- Shared queue/order state (crossfade engine only; the gapless
  // engine delegates queue/shuffle navigation straight to just_audio). --
  List<Song> _queue = [];
  int _currentIndex = 0;
  List<int> _order = [];
  int _orderPos = 0;
  bool _shuffleEnabled = false;

  bool _crossfadeEnabled = false;
  Duration _crossfadeDuration = const Duration(seconds: 15);
  RepeatMode _repeatMode = RepeatMode.off;
  double _speed = 1.0;

  // -- Equalizer (attached to every underlying AudioPlayer so it applies
  // no matter which engine/player is currently producing sound). --
  final List<AndroidEqualizer> _equalizers = [];
  List<double>? _lastEqualizerBandGains;

  // -- Public streams, fed by whichever engine/player is currently active.
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();
  final _processingStateController =
      StreamController<ProcessingState>.broadcast();
  final _errorIndexController = StreamController<int>.broadcast();
  final _audioSessionIdController = StreamController<int?>.broadcast();

  StreamSubscription<Duration>? _fwdPosition;
  StreamSubscription<Duration?>? _fwdDuration;
  StreamSubscription<bool>? _fwdPlaying;
  StreamSubscription<int?>? _fwdCurrentIndex;
  StreamSubscription<ProcessingState>? _fwdProcessingState;
  StreamSubscription<int?>? _fwdAudioSessionId;

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  Stream<int?> get currentIndexStream => _currentIndexController.stream;
  Stream<ProcessingState> get processingStateStream =>
      _processingStateController.stream;

  /// Emits the queue index of a track that failed to play (SRS F-5.3), e.g.
  /// because its file was deleted.
  Stream<int> get playbackErrorIndexStream => _errorIndexController.stream;

  /// Emits the Android audio session id of whichever player is currently
  /// producing sound, so the visualizer can attach a capture to it. Changes
  /// whenever the active player changes — notably on every crossfade, which
  /// hands over to the other player and so a different session.
  ///
  /// Always `null` off Android.
  Stream<int?> get audioSessionIdStream => _audioSessionIdController.stream;

  bool get isShuffleModeEnabled =>
      _crossfadeEnabled ? _shuffleEnabled : _gaplessPlayer.shuffleModeEnabled;

  AudioPlayer _createEqualizedPlayer() {
    if (!Platform.isAndroid) return AudioPlayer();
    final equalizer = AndroidEqualizer();
    _equalizers.add(equalizer);
    final gains = _lastEqualizerBandGains;
    if (gains != null) {
      unawaited(_applyBandGainsTo(equalizer, gains));
    }
    return AudioPlayer(
      audioPipeline: AudioPipeline(androidAudioEffects: [equalizer]),
    );
  }

  void _onGaplessError(PlayerException error) {
    final index = error.index ?? _gaplessPlayer.currentIndex;
    if (index != null) _errorIndexController.add(index);
  }

  void _onFadeError(bool isPlayerA, PlayerException error) {
    final isActive = isPlayerA == _fadeActiveIsA;
    final index = isActive ? _currentIndex : _standbyIndex;
    if (index != null) _errorIndexController.add(index);
    if (isActive) {
      unawaited(seekToNext());
    } else if (_fadeRampInProgress) {
      _cancelRamp();
    }
  }

  void _cancelForwarding() {
    _fwdPosition?.cancel();
    _fwdDuration?.cancel();
    _fwdPlaying?.cancel();
    _fwdCurrentIndex?.cancel();
    _fwdProcessingState?.cancel();
    _fwdAudioSessionId?.cancel();
  }

  void _bindGaplessForwarding() {
    _cancelForwarding();
    _fwdPosition = _gaplessPlayer.positionStream.listen(
      _positionController.add,
    );
    _fwdDuration = _gaplessPlayer.durationStream.listen(
      _durationController.add,
    );
    _fwdPlaying = _gaplessPlayer.playingStream.listen(_playingController.add);
    _fwdCurrentIndex = _gaplessPlayer.currentIndexStream.listen((index) {
      // Mirrored into _currentIndex so queue edits and a live switch to the
      // crossfade engine start from the track actually playing, not the one
      // the queue was originally loaded at.
      if (index != null) _currentIndex = index;
      _currentIndexController.add(index);
    });
    _fwdProcessingState = _gaplessPlayer.playerStateStream
        .map((state) => state.processingState)
        .listen(_processingStateController.add);
    _fwdAudioSessionId = _gaplessPlayer.androidAudioSessionIdStream.listen(
      _audioSessionIdController.add,
    );
  }

  void _bindCrossfadeActiveForwarding() {
    _cancelForwarding();
    final active = _activeFadePlayer!;
    _fwdPosition = active.positionStream.listen((position) {
      _positionController.add(position);
      _maybeStartCrossfadeRamp(position, active.duration);
    });
    _fwdDuration = active.durationStream.listen(_durationController.add);
    _fwdPlaying = active.playingStream.listen(_playingController.add);
    _fwdProcessingState = active.playerStateStream
        .map((state) => state.processingState)
        .listen(_processingStateController.add);
    _fwdAudioSessionId = active.androidAudioSessionIdStream.listen(
      _audioSessionIdController.add,
    );
    // currentIndexStream is driven manually (_currentIndexController.add)
    // in crossfade mode — there's no single playlist to report it from.
  }

  /// Loads [queue] into the engine as a playlist and starts playback at
  /// [initialIndex]. Playback itself is started separately via [play].
  Future<void> loadQueue(List<Song> queue, {int initialIndex = 0}) async {
    _queue = queue;
    _currentIndex = initialIndex;
    _rebuildOrder();
    if (_crossfadeEnabled) {
      await _startCrossfadeEngineAt(initialIndex, position: Duration.zero);
    } else {
      await _gaplessPlayer.setAudioSources([
        for (final song in queue) AudioSource.uri(Uri.file(song.filePath)),
      ], initialIndex: initialIndex);
    }
  }

  Future<void> play() async {
    if (_crossfadeEnabled) {
      await _activeFadePlayer?.play();
      if (_fadeRampInProgress) await _standbyFadePlayer?.play();
    } else {
      await _gaplessPlayer.play();
    }
  }

  Future<void> pause() async {
    if (_crossfadeEnabled) {
      await _activeFadePlayer?.pause();
      if (_fadeRampInProgress) await _standbyFadePlayer?.pause();
    } else {
      await _gaplessPlayer.pause();
    }
  }

  /// Jumps directly to [index] in the current queue (Queue screen "play
  /// now"). Unlike [seekToNext]/[seekToPrevious], this ignores [_repeatMode]
  /// — it's an explicit user pick, not a natural end-of-queue transition.
  Future<void> jumpTo(int index) async {
    if (_crossfadeEnabled) {
      await _hardSwapTo(index);
      _orderPos = _order.indexOf(index);
    } else {
      await _gaplessPlayer.seek(Duration.zero, index: index);
    }
  }

  /// Moves the queue item at [oldIndex] to [newIndex] (Queue screen reorder).
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (!_crossfadeEnabled) {
      final item = _queue.removeAt(oldIndex);
      _queue.insert(newIndex, item);
      await _gaplessPlayer.moveAudioSource(oldIndex, newIndex);
      return;
    }
    if (_fadeRampInProgress) _cancelRamp();
    final currentSong = _queue[_currentIndex];
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    _currentIndex = _queue.indexOf(currentSong);
    _rebuildOrder();
    _currentIndexController.add(_currentIndex);
  }

  /// Removes the queue item at [index] (Queue screen remove). If it's the
  /// track currently playing, advances to whatever now sits at that
  /// position (or stops if the queue is now empty).
  Future<void> removeQueueItem(int index) async {
    if (!_crossfadeEnabled) {
      _queue.removeAt(index);
      await _gaplessPlayer.removeAudioSourceAt(index);
      return;
    }
    if (_fadeRampInProgress) _cancelRamp();
    final removingCurrent = index == _currentIndex;
    final currentSong = removingCurrent ? null : _queue[_currentIndex];
    _queue.removeAt(index);

    if (_queue.isEmpty) {
      await _activeFadePlayer?.pause();
      _currentIndex = 0;
      _order = [];
      _orderPos = 0;
      _currentIndexController.add(null);
      return;
    }

    if (removingCurrent) {
      final wasPlaying = _activeFadePlayer?.playing ?? false;
      final newIndex = index.clamp(0, _queue.length - 1);
      await _startCrossfadeEngineAt(newIndex, position: Duration.zero);
      _currentIndex = newIndex;
      _rebuildOrder();
      if (wasPlaying) await _activeFadePlayer!.play();
      _currentIndexController.add(_currentIndex);
    } else {
      _currentIndex = _queue.indexOf(currentSong!);
      _rebuildOrder();
      _currentIndexController.add(_currentIndex);
    }
  }

  /// Replaces the queue's order wholesale (Queue screen sort) while the
  /// current track keeps playing from its current position. [newQueue] must
  /// be a permutation of the existing queue.
  Future<void> setQueueOrder(List<Song> newQueue) async {
    if (_queue.isEmpty) return;
    if (_crossfadeEnabled) {
      if (_fadeRampInProgress) _cancelRamp();
      final currentSong = _queue[_currentIndex];
      _queue = List.of(newQueue);
      _currentIndex = _queue.indexOf(currentSong);
      _rebuildOrder();
      _currentIndexController.add(_currentIndex);
      return;
    }
    // Gapless: applied as successive moves — just_audio has no atomic
    // reorder, and rebuilding the playlist would interrupt playback.
    for (var target = 0; target < newQueue.length; target++) {
      final from = _queue.indexOf(newQueue[target], target);
      if (from == target) continue;
      final song = _queue.removeAt(from);
      _queue.insert(target, song);
      await _gaplessPlayer.moveAudioSource(from, target);
    }
  }

  Future<void> seekToNext() async {
    if (!_crossfadeEnabled) {
      await _gaplessPlayer.seekToNext();
      return;
    }
    var nextPos = _orderPos + 1;
    if (nextPos >= _order.length) {
      if (_repeatMode != RepeatMode.all || _order.isEmpty) return;
      nextPos = 0;
    }
    await _hardSwapTo(_order[nextPos]);
    _orderPos = nextPos;
  }

  Future<void> seekToPrevious() async {
    if (!_crossfadeEnabled) {
      await _gaplessPlayer.seekToPrevious();
      return;
    }
    var prevPos = _orderPos - 1;
    if (prevPos < 0) {
      if (_repeatMode != RepeatMode.all || _order.isEmpty) return;
      prevPos = _order.length - 1;
    }
    await _hardSwapTo(_order[prevPos]);
    _orderPos = prevPos;
  }

  Future<void> seek(Duration position) async {
    if (_crossfadeEnabled) {
      if (_fadeRampInProgress) _cancelRamp();
      await _activeFadePlayer?.seek(position);
    } else {
      await _gaplessPlayer.seek(position);
    }
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    _shuffleEnabled = enabled;
    if (_crossfadeEnabled) {
      _rebuildOrder();
    } else {
      await _gaplessPlayer.setShuffleModeEnabled(enabled);
      if (enabled) await _gaplessPlayer.shuffle();
    }
  }

  /// Rebuilds the crossfade engine's play order from [_queue], keeping the
  /// currently-playing song in place and shuffling the rest when shuffle is
  /// on (mirrors just_audio's own `.shuffle()` behavior, which the gapless
  /// engine relies on directly).
  void _rebuildOrder() {
    _order = List<int>.generate(_queue.length, (i) => i);
    if (_shuffleEnabled && _order.isNotEmpty) {
      _order.remove(_currentIndex);
      _order.shuffle();
      _order.insert(0, _currentIndex);
    }
    _orderPos = _order.indexOf(_currentIndex);
  }

  /// The index the crossfade engine should fade into next at the *natural*
  /// end of the current track — as opposed to a manual [seekToNext], which
  /// always advances along [_order] regardless of [_repeatMode]. Repeat-one
  /// returns the current index (fades into a fresh play of the same track);
  /// repeat-all wraps back to the start of [_order] instead of stopping.
  int? _peekNextIndex() {
    if (_repeatMode == RepeatMode.one) return _currentIndex;
    final nextPos = _orderPos + 1;
    if (nextPos >= _order.length) {
      if (_repeatMode == RepeatMode.all && _order.isNotEmpty) return _order[0];
      return null;
    }
    return _order[nextPos];
  }

  /// Applies [mode] to future track transitions. Takes effect immediately
  /// for the gapless engine (delegates straight to just_audio's own
  /// [LoopMode]); the crossfade engine reads [_repeatMode] lazily at the
  /// next transition (see [_peekNextIndex]).
  Future<void> setRepeatMode(RepeatMode mode) async {
    _repeatMode = mode;
    if (!_crossfadeEnabled) {
      await _gaplessPlayer.setLoopMode(_toLoopMode(mode));
    }
  }

  LoopMode _toLoopMode(RepeatMode mode) => switch (mode) {
    RepeatMode.off => LoopMode.off,
    RepeatMode.one => LoopMode.one,
    RepeatMode.all => LoopMode.all,
  };

  /// Applies [speed] (1.0 = normal) to whichever player(s) are currently
  /// producing sound, and to any crossfade player created afterward (see
  /// [_ensureFadePlayers]).
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await Future.wait([
      _gaplessPlayer.setSpeed(speed),
      if (_fadeA != null) _fadeA!.setSpeed(speed),
      if (_fadeB != null) _fadeB!.setSpeed(speed),
    ]);
  }

  /// Configures the real overlapping crossfade (SRS F-1.4): when enabled,
  /// the outgoing and incoming tracks are both audible during the final
  /// [duration] seconds of the outgoing track, one fading down while the
  /// other fades up. Switches the underlying engine live if playback is
  /// already in progress.
  Future<void> setCrossfadeSettings({
    required bool enabled,
    required Duration duration,
  }) async {
    _crossfadeDuration = duration;
    if (enabled == _crossfadeEnabled) return;
    if (enabled) {
      await _switchToCrossfadeEngine();
    } else {
      await _switchToGaplessEngine();
    }
    _crossfadeEnabled = enabled;
  }

  Future<void> _switchToCrossfadeEngine() async {
    if (_queue.isEmpty) return;
    final position = _gaplessPlayer.position;
    final wasPlaying = _gaplessPlayer.playing;
    await _gaplessPlayer.pause();
    await _startCrossfadeEngineAt(_currentIndex, position: position);
    if (wasPlaying) await _activeFadePlayer!.play();
  }

  Future<void> _switchToGaplessEngine() async {
    if (_fadeRampInProgress) _cancelRamp();
    if (_queue.isEmpty) {
      await _disposeFadePlayers();
      return;
    }
    final active = _activeFadePlayer;
    final position = active?.position ?? Duration.zero;
    final wasPlaying = active?.playing ?? false;
    await active?.pause();
    await _gaplessPlayer.setAudioSources([
      for (final song in _queue) AudioSource.uri(Uri.file(song.filePath)),
    ], initialIndex: _currentIndex);
    await _gaplessPlayer.seek(position);
    await _gaplessPlayer.setShuffleModeEnabled(_shuffleEnabled);
    if (_shuffleEnabled) await _gaplessPlayer.shuffle();
    await _gaplessPlayer.setLoopMode(_toLoopMode(_repeatMode));
    await _gaplessPlayer.setSpeed(_speed);
    _bindGaplessForwarding();
    if (wasPlaying) await _gaplessPlayer.play();
    await _disposeFadePlayers();
  }

  Future<void> _startCrossfadeEngineAt(
    int index, {
    required Duration position,
  }) async {
    _ensureFadePlayers();
    _fadeRampTimer?.cancel();
    _fadeRampInProgress = false;
    _fadeActiveIsA = true;
    _standbyIndex = null;
    await _fadeB!.pause();
    await _fadeB!.setVolume(1);
    await _fadeA!.setAudioSource(
      AudioSource.uri(Uri.file(_queue[index].filePath)),
    );
    await _fadeA!.seek(position);
    await _fadeA!.setVolume(1);
    _bindCrossfadeActiveForwarding();
  }

  void _ensureFadePlayers() {
    if (_fadeA == null) {
      _fadeA = _createEqualizedPlayer();
      unawaited(_fadeA!.setSpeed(_speed));
      _fadeAErrorSubscription = _fadeA!.errorStream.listen(
        (e) => _onFadeError(true, e),
      );
    }
    if (_fadeB == null) {
      _fadeB = _createEqualizedPlayer();
      unawaited(_fadeB!.setSpeed(_speed));
      _fadeBErrorSubscription = _fadeB!.errorStream.listen(
        (e) => _onFadeError(false, e),
      );
    }
  }

  Future<void> _disposeFadePlayers() async {
    _fadeRampTimer?.cancel();
    _fadeRampTimer = null;
    _fadeRampInProgress = false;
    _standbyIndex = null;
    await _fadeAErrorSubscription?.cancel();
    await _fadeBErrorSubscription?.cancel();
    _fadeAErrorSubscription = null;
    _fadeBErrorSubscription = null;
    await _fadeA?.dispose();
    await _fadeB?.dispose();
    _fadeA = null;
    _fadeB = null;
  }

  void _maybeStartCrossfadeRamp(Duration position, Duration? duration) {
    if (_fadeRampInProgress) return;
    if (duration == null || duration <= _crossfadeDuration) return;
    if (position < duration - _crossfadeDuration) return;
    final nextIndex = _peekNextIndex();
    if (nextIndex == null) return;
    unawaited(_beginCrossfadeRamp(nextIndex));
  }

  Future<void> _beginCrossfadeRamp(int nextIndex) async {
    _fadeRampInProgress = true;
    final active = _activeFadePlayer!;
    final standby = _standbyFadePlayer!;
    _standbyIndex = nextIndex;
    await standby.setAudioSource(
      AudioSource.uri(Uri.file(_queue[nextIndex].filePath)),
    );
    await standby.seek(Duration.zero);
    await standby.setVolume(0);
    unawaited(standby.play());

    final rampMs = _crossfadeDuration.inMilliseconds;
    final stopwatch = Stopwatch()..start();
    _fadeRampTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final t = (stopwatch.elapsedMilliseconds / rampMs).clamp(0.0, 1.0);
      active.setVolume(1 - t);
      standby.setVolume(t);
      if (t >= 1.0) {
        timer.cancel();
        unawaited(_completeCrossfadeSwap(nextIndex));
      }
    });
  }

  Future<void> _completeCrossfadeSwap(int nextIndex) async {
    final oldActive = _activeFadePlayer!;
    _fadeActiveIsA = !_fadeActiveIsA;
    _currentIndex = nextIndex;
    // Not simply `_orderPos++`: repeat-one fades into the same index (order
    // position doesn't move) and repeat-all can wrap back to `_order[0]`, so
    // the new position has to be looked up rather than assumed to be next.
    _orderPos = _order.indexOf(nextIndex);
    _standbyIndex = null;
    _fadeRampInProgress = false;
    await oldActive.pause();
    await oldActive.setVolume(1);
    await oldActive.seek(Duration.zero);
    _bindCrossfadeActiveForwarding();
    _currentIndexController.add(_currentIndex);
  }

  /// Cancels an in-progress crossfade ramp (e.g. the user seeked or skipped
  /// mid-fade), resetting the standby player back to idle.
  void _cancelRamp() {
    _fadeRampTimer?.cancel();
    _fadeRampTimer = null;
    _fadeRampInProgress = false;
    _standbyIndex = null;
    final standby = _standbyFadePlayer;
    standby?.pause();
    standby?.seek(Duration.zero);
    standby?.setVolume(1);
    _activeFadePlayer?.setVolume(1);
  }

  /// Immediately swaps to [index] (manual skip) — no fade, unlike the
  /// automatic end-of-track crossfade.
  Future<void> _hardSwapTo(int index) async {
    if (_fadeRampInProgress) _cancelRamp();
    final oldActive = _activeFadePlayer!;
    final standby = _standbyFadePlayer!;
    final wasPlaying = oldActive.playing;
    await standby.setVolume(1);
    await standby.setAudioSource(
      AudioSource.uri(Uri.file(_queue[index].filePath)),
    );
    await standby.seek(Duration.zero);
    if (wasPlaying) unawaited(standby.play());
    await oldActive.pause();
    await oldActive.setVolume(1);
    await oldActive.seek(Duration.zero);
    _fadeActiveIsA = !_fadeActiveIsA;
    _currentIndex = index;
    _standbyIndex = null;
    _bindCrossfadeActiveForwarding();
    _currentIndexController.add(_currentIndex);
  }

  /// Whether a real equalizer is available (Android only — SRS 2.3).
  bool get hasEqualizer => _equalizers.isNotEmpty;

  /// Applies [bandGains] (in dB) to every underlying player's equalizer —
  /// there can be up to three (the gapless player plus the two crossfade
  /// players) depending on which engine is active — and enables them. If a
  /// device exposes a different number of bands than `bandGains.length`
  /// (band count/frequencies are device-specific and only known at
  /// runtime), each device band samples the nearest entry in [bandGains].
  /// No-ops if no equalizer is available (SRS F-1.6).
  Future<void> applyEqualizerBandGains(List<double> bandGains) async {
    _lastEqualizerBandGains = bandGains;
    if (bandGains.isEmpty) return;
    await Future.wait([
      for (final equalizer in _equalizers)
        _applyBandGainsTo(equalizer, bandGains),
    ]);
  }

  Future<void> _applyBandGainsTo(
    AndroidEqualizer equalizer,
    List<double> bandGains,
  ) async {
    await equalizer.setEnabled(true);
    final parameters = await equalizer.parameters;
    for (final band in parameters.bands) {
      final t = parameters.bands.length <= 1
          ? 0.0
          : band.index / (parameters.bands.length - 1);
      final sourceIndex = (t * (bandGains.length - 1)).round();
      await band.setGain(
        bandGains[sourceIndex].clamp(
          parameters.minDecibels,
          parameters.maxDecibels,
        ),
      );
    }
  }

  Future<void> disableEqualizer() async {
    _lastEqualizerBandGains = null;
    await Future.wait([
      for (final equalizer in _equalizers) equalizer.setEnabled(false),
    ]);
  }

  Future<void> dispose() async {
    _fadeRampTimer?.cancel();
    _cancelForwarding();
    await _gaplessErrorSubscription.cancel();
    await _fadeAErrorSubscription?.cancel();
    await _fadeBErrorSubscription?.cancel();
    await _errorIndexController.close();
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
    await _currentIndexController.close();
    await _processingStateController.close();
    await _gaplessPlayer.dispose();
    await _fadeA?.dispose();
    await _fadeB?.dispose();
  }
}
