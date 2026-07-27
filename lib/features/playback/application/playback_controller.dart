import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show LoopMode;

import '../../../core/services/audio_player_service.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';
import '../../settings/application/equalizer_controller.dart';
import '../../settings/application/settings_controller.dart';

/// How the queue repeats once it reaches the end (SRS F-1.2 extension).
enum PlaybackRepeatMode {
  off,
  all,
  one;

  PlaybackRepeatMode get next => switch (this) {
    PlaybackRepeatMode.off => PlaybackRepeatMode.all,
    PlaybackRepeatMode.all => PlaybackRepeatMode.one,
    PlaybackRepeatMode.one => PlaybackRepeatMode.off,
  };

  LoopMode get engineLoopMode => switch (this) {
    PlaybackRepeatMode.off => LoopMode.off,
    PlaybackRepeatMode.all => LoopMode.all,
    PlaybackRepeatMode.one => LoopMode.one,
  };
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

/// How long a preview clip plays before auto-advancing (SRS F-4.1).
const previewClipDuration = Duration(seconds: 30);

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
    this.repeatMode = PlaybackRepeatMode.off,
  });

  final List<Song> queue;
  final int? currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool shuffleEnabled;
  final bool previewModeEnabled;
  final PlaybackRepeatMode repeatMode;

  Song? get currentSong {
    final index = currentIndex;
    if (index == null || index < 0 || index >= queue.length) {
      return null;
    }
    return queue[index];
  }

  PlaybackState copyWith({
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? shuffleEnabled,
    bool? previewModeEnabled,
    PlaybackRepeatMode? repeatMode,
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
  Future<void> playQueue(List<Song> queue, {required int startIndex}) async {
    state = state.copyWith(queue: queue, currentIndex: startIndex);
    await _player.loadQueue(queue, initialIndex: startIndex);
    await _player.play();
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

  Future<void> togglePlayPause() {
    return state.isPlaying ? _player.pause() : _player.play();
  }

  Future<void> next() => _player.seekToNext();

  Future<void> previous() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffleEnabled;
    await _player.setShuffleModeEnabled(enabled);
    state = state.copyWith(shuffleEnabled: enabled);
  }

  /// Cycles repeat mode off → all → one → off (Now Playing's repeat button).
  Future<void> cycleRepeatMode() async {
    final mode = state.repeatMode.next;
    await _player.setLoopMode(mode.engineLoopMode);
    state = state.copyWith(repeatMode: mode);
  }

  void togglePreviewMode() {
    state = state.copyWith(previewModeEnabled: !state.previewModeEnabled);
  }
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);
