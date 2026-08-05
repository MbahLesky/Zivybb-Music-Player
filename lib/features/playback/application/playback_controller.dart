import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../data/models/song.dart';
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

/// How the Queue screen can sort the play queue.
enum QueueSort { title, artist, duration }

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
    if (state.previewModeEnabled &&
        !_previewSkipPending &&
        position >= previewClipDuration) {
      _previewSkipPending = true;
      _player.seekToNext();
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
  }

  /// Shuffles [queue] and plays it from the start, enabling shuffle mode
  /// if it isn't already on. Backs the home screen's "shuffle all" action
  /// and the folder/playlist shuffle headers (which pass
  /// [sourcePlaylistId] so "Remove from playlist" stays available).
  Future<void> shuffleAndPlay(
    List<Song> queue, {
    String? sourcePlaylistId,
  }) async {
    if (queue.isEmpty) return;
    if (!state.shuffleEnabled) {
      await toggleShuffle();
    }
    final shuffled = List<Song>.of(queue)..shuffle();
    await playQueue(
      shuffled,
      startIndex: 0,
      sourcePlaylistId: sourcePlaylistId,
    );
  }

  Future<void> togglePlayPause() => state.isPlaying ? pause() : play();

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> next() => _player.seekToNext();

  Future<void> previous() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  /// Seeks [offset] forward (or backward when negative) from the current
  /// position, clamped to the track bounds (Now Playing's seek-step
  /// buttons).
  Future<void> seekBy(Duration offset) async {
    var target = state.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (state.duration > Duration.zero && target > state.duration) {
      target = state.duration;
    }
    await _player.seek(target);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffleEnabled;
    await _player.setShuffleModeEnabled(enabled);
    state = state.copyWith(shuffleEnabled: enabled);
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
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  /// Jumps straight to [index] in the queue (Queue screen "play now").
  Future<void> playAt(int index) async {
    await _player.jumpTo(index);
    await _player.play();
  }

  /// Moves the queue item at [oldIndex] to [newIndex] (Queue screen
  /// reorder). [newIndex] follows `ReorderableListView.onReorderItem`'s
  /// convention: already adjusted for the item's removal, usable directly.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final newQueue = [...state.queue];
    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    state = state.copyWith(queue: newQueue);
    await _player.moveQueueItem(oldIndex, newIndex);
  }

  /// Removes the queue item at [index] (Queue screen remove).
  Future<void> removeFromQueue(int index) async {
    final newQueue = [...state.queue]..removeAt(index);
    state = state.copyWith(queue: newQueue);
    await _player.removeQueueItem(index);
  }

  /// Scrambles the queue into a fresh random order and restarts playback
  /// from the top of the new order (Queue screen shuffle).
  Future<void> scrambleQueueAndPlay() async {
    if (state.queue.isEmpty) return;
    final scrambled = [...state.queue]..shuffle();
    await playQueue(
      scrambled,
      startIndex: 0,
      sourcePlaylistId: state.sourcePlaylistId,
    );
  }

  /// Sorts the queue by [sort] without interrupting the current track.
  Future<void> sortQueue(QueueSort sort) async {
    if (state.queue.isEmpty) return;
    final sorted = [...state.queue]
      ..sort(switch (sort) {
        QueueSort.title => (a, b) => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        QueueSort.artist => (a, b) => a.artist.toLowerCase().compareTo(
          b.artist.toLowerCase(),
        ),
        QueueSort.duration => (a, b) => a.duration.compareTo(b.duration),
      });
    final current = state.currentSong;
    state = state.copyWith(
      queue: sorted,
      currentIndex: current == null ? null : sorted.indexOf(current),
    );
    await _player.setQueueOrder(sorted);
  }
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);
