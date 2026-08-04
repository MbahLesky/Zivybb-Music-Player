import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/playback_session_repository.dart';
import '../../../data/repositories/song_repository.dart';
import '../../settings/application/equalizer_controller.dart';
import '../../settings/application/settings_controller.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

/// How long a preview clip plays before auto-advancing (SRS F-4.1).
const previewClipDuration = Duration(seconds: 30);

const _unset = Object();

/// Snapshot of the current playback queue and transport state.
class PlaybackState {
  const PlaybackState({
    this.queue = const [],
    this.currentIndex,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.shuffleEnabled = false,
    this.previewModeEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.speed = 1.0,
    this.sourcePlaylistId,
  });

  final List<Song> queue;
  final int? currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool shuffleEnabled;
  final bool previewModeEnabled;
  final RepeatMode repeatMode;
  final double speed;

  /// The playlist this queue was played from, if any — lets the Now Playing
  /// screen's "more" menu offer "Remove from playlist" only when it makes
  /// sense. Cleared whenever a new queue starts from somewhere else (e.g.
  /// "shuffle all" from the library).
  final String? sourcePlaylistId;

  Song? get currentSong {
    final index = currentIndex;
    if (index == null || index < 0 || index >= queue.length) {
      return null;
    }
    return queue[index];
  }

  /// Pass [sourcePlaylistId] to change it, including to `null`. Omit it to
  /// leave it untouched.
  PlaybackState copyWith({
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? shuffleEnabled,
    bool? previewModeEnabled,
    RepeatMode? repeatMode,
    double? speed,
    Object? sourcePlaylistId = _unset,
  }) {
    return PlaybackState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      previewModeEnabled: previewModeEnabled ?? this.previewModeEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      speed: speed ?? this.speed,
      sourcePlaylistId: identical(sourcePlaylistId, _unset)
          ? this.sourcePlaylistId
          : sourcePlaylistId as String?,
    );
  }
}

/// Drives the audio engine and exposes transport state to the UI.
class PlaybackController extends Notifier<PlaybackState> {
  late final AudioPlayerService _player;

  /// Guards against repeatedly calling `seekToNext` while position keeps
  /// reporting past [previewClipDuration] during the async gap before the
  /// track actually changes.
  bool _previewSkipPending = false;

  /// Rate-limits session writes. Position updates arrive many times a
  /// second; persisting each one would hammer the database for no benefit,
  /// so the saved position is at most this stale.
  Timer? _sessionSaveTimer;
  static const _sessionSaveInterval = Duration(seconds: 5);

  @override
  PlaybackState build() {
    _player = ref.read(audioPlayerServiceProvider);

    final subscriptions = <StreamSubscription<void>>[
      _player.positionStream.listen(_onPosition),
      _player.durationStream.listen(
        (duration) =>
            state = state.copyWith(duration: duration ?? Duration.zero),
      ),
      _player.playingStream.listen(
        (isPlaying) => state = state.copyWith(isPlaying: isPlaying),
      ),
      _player.currentIndexStream.listen((index) {
        if (index != null) {
          _previewSkipPending = false;
          state = state.copyWith(currentIndex: index);
          final song = state.currentSong;
          if (song != null) {
            ref.read(songRepositoryProvider).recordPlayed(song.id);
          }
        }
      }),
      _player.playbackErrorIndexStream.listen(_onPlaybackError),
    ];
    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
      _sessionSaveTimer?.cancel();
    });

    // Keep the engine's crossfade config in sync with the persisted setting.
    ref.listen(settingsStreamProvider, (previous, next) {
      final settings = next.value;
      if (settings != null) {
        _player.setCrossfadeSettings(
          enabled: settings.crossfadeEnabled,
          duration: settings.crossfadeDuration,
        );
      }
    }, fireImmediately: true);

    // Keep the device equalizer in sync with the selected preset.
    ref.listen(effectiveEqualizerBandGainsProvider, (previous, next) {
      if (next != null) {
        _player.applyEqualizerBandGains(next);
      } else {
        _player.disableEqualizer();
      }
    }, fireImmediately: true);

    return const PlaybackState();
  }

  void _onPosition(Duration position) {
    state = state.copyWith(position: position);
    _scheduleSessionSave();
    if (state.previewModeEnabled &&
        !_previewSkipPending &&
        position >= previewClipDuration) {
      _previewSkipPending = true;
      _player.seekToNext();
    }
  }

  /// Persists the session at most once per [_sessionSaveInterval].
  void _scheduleSessionSave() {
    if (_sessionSaveTimer?.isActive ?? false) return;
    _sessionSaveTimer = Timer(_sessionSaveInterval, saveSession);
  }

  /// Writes the current queue and transport settings so the next launch can
  /// resume them. Safe to call at any time; a no-op for an empty queue.
  Future<void> saveSession() async {
    final current = state;
    if (current.queue.isEmpty) return;
    await ref
        .read(playbackSessionRepositoryProvider)
        .save(
          PlaybackSession(
            songIds: [for (final song in current.queue) song.id],
            currentIndex: current.currentIndex ?? 0,
            position: current.position,
            shuffleEnabled: current.shuffleEnabled,
            repeatMode: current.repeatMode,
            speed: current.speed,
            sourcePlaylistId: current.sourcePlaylistId,
          ),
        );
  }

  /// Reloads the last session's queue, paused and seeked to where it left
  /// off, and reapplies shuffle/repeat/speed.
  ///
  /// Never starts playback — the user opened the app, they did not press
  /// play. Songs that have since left the library are dropped, and the
  /// resume point follows the song that was playing rather than its old
  /// index, so removals don't land the user on an unrelated track.
  Future<void> restoreSession() async {
    if (state.queue.isNotEmpty) return;

    final session = await ref.read(playbackSessionRepositoryProvider).load();
    if (session == null || session.songIds.isEmpty) return;

    final library = await ref.read(songRepositoryProvider).allSongs();
    final byId = {for (final song in library) song.id: song};
    final queue = [
      for (final id in session.songIds)
        if (byId[id] != null) byId[id]!,
    ];
    if (queue.isEmpty) return;

    final resumeSongId = session.currentSongId;
    final resumeIndex = resumeSongId == null
        ? 0
        : queue.indexWhere((song) => song.id == resumeSongId);
    final index = resumeIndex < 0 ? 0 : resumeIndex;

    state = state.copyWith(
      queue: queue,
      currentIndex: index,
      shuffleEnabled: session.shuffleEnabled,
      repeatMode: session.repeatMode,
      speed: session.speed,
      position: session.position,
      sourcePlaylistId: session.sourcePlaylistId,
    );

    await _player.loadQueue(queue, initialIndex: index);
    await _player.setRepeatMode(session.repeatMode);
    await _player.setSpeed(session.speed);
    if (session.shuffleEnabled) {
      await _player.setShuffleModeEnabled(true);
    }
    // Only meaningful once the source is loaded, hence last.
    if (session.position > Duration.zero) {
      await _player.seek(session.position);
    }
  }

  /// Marks the failed track missing and skips past it (SRS F-5.3): a
  /// deleted or corrupt file should never crash playback.
  Future<void> _onPlaybackError(int index) async {
    if (index >= 0 && index < state.queue.length) {
      final song = state.queue[index];
      await ref.read(songRepositoryProvider).setMissing(song.id, true);
    }
    try {
      await _player.seekToNext();
    } catch (_) {
      // Nothing left to skip to.
    }
  }

  /// Loads [queue] into the engine and starts playback at [startIndex].
  /// Pass [sourcePlaylistId] when playing from within a specific playlist
  /// so the Now Playing screen can offer "Remove from playlist"; omit it
  /// (or pass `null`) for queues with no such context, which also clears
  /// any previous one.
  Future<void> playQueue(
    List<Song> queue, {
    required int startIndex,
    String? sourcePlaylistId,
  }) async {
    state = state.copyWith(
      queue: queue,
      currentIndex: startIndex,
      sourcePlaylistId: sourcePlaylistId,
    );
    await _player.loadQueue(queue, initialIndex: startIndex);
    await _player.play();
    unawaited(saveSession());
  }

  /// Shuffles [queue] and plays it from the start, enabling shuffle mode
  /// if it isn't already on. Backs the home screen's "shuffle all" action.
  Future<void> shuffleAndPlay(List<Song> queue) async {
    if (queue.isEmpty) return;
    if (!state.shuffleEnabled) {
      await toggleShuffle();
    }
    final shuffled = List<Song>.of(queue)..shuffle();
    await playQueue(shuffled, startIndex: 0);
  }

  /// Jumps to [index] in the current queue (Queue screen tap-to-play).
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    await _player.skipToIndex(index);
    state = state.copyWith(currentIndex: index);
  }

  /// Removes the track at [index] from the queue. Playback continues
  /// uninterrupted unless the removed track is the one playing.
  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    final current = state.currentIndex;
    await _player.removeFromQueue(index);
    state = state.copyWith(
      queue: [...state.queue]..removeAt(index),
      currentIndex: current != null && index < current ? current - 1 : current,
    );
    unawaited(saveSession());
  }

  /// Reorders the queue, keeping the currently-playing track playing.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= state.queue.length) return;
    if (newIndex < 0 || newIndex >= state.queue.length) return;

    await _player.moveInQueue(oldIndex, newIndex);
    final reordered = [...state.queue];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));

    var current = state.currentIndex;
    if (current != null) {
      if (current == oldIndex) {
        current = newIndex;
      } else if (oldIndex < current && newIndex >= current) {
        current--;
      } else if (oldIndex > current && newIndex <= current) {
        current++;
      }
    }
    state = state.copyWith(queue: reordered, currentIndex: current);
    unawaited(saveSession());
  }

  Future<void> togglePlayPause() => state.isPlaying ? pause() : play();

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> next() => _player.seekToNext();

  Future<void> previous() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffleEnabled;
    await _player.setShuffleModeEnabled(enabled);
    state = state.copyWith(shuffleEnabled: enabled);
    unawaited(saveSession());
  }

  void togglePreviewMode() {
    state = state.copyWith(previewModeEnabled: !state.previewModeEnabled);
  }

  /// Cycles Off -> Repeat all -> Repeat one -> Off, for a single tap-to-cycle
  /// repeat button.
  Future<void> cycleRepeatMode() async {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await _player.setRepeatMode(next);
    state = state.copyWith(repeatMode: next);
    unawaited(saveSession());
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(speed: speed);
    unawaited(saveSession());
  }
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);
