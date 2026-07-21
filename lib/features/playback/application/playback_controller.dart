import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../data/models/song.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

/// Snapshot of the current playback queue and transport state.
class PlaybackState {
  const PlaybackState({
    this.queue = const [],
    this.currentIndex,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.shuffleEnabled = false,
  });

  final List<Song> queue;
  final int? currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool shuffleEnabled;

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
  }) {
    return PlaybackState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    );
  }
}

/// Drives the audio engine and exposes transport state to the UI.
class PlaybackController extends Notifier<PlaybackState> {
  late final AudioPlayerService _player;

  @override
  PlaybackState build() {
    _player = ref.read(audioPlayerServiceProvider);

    final subscriptions = <StreamSubscription<void>>[
      _player.positionStream.listen(
        (position) => state = state.copyWith(position: position),
      ),
      _player.durationStream.listen(
        (duration) =>
            state = state.copyWith(duration: duration ?? Duration.zero),
      ),
      _player.playingStream.listen(
        (isPlaying) => state = state.copyWith(isPlaying: isPlaying),
      ),
      _player.currentIndexStream.listen((index) {
        if (index != null) {
          state = state.copyWith(currentIndex: index);
        }
      }),
    ];
    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });

    return const PlaybackState();
  }

  /// Loads [queue] into the engine and starts playback at [startIndex].
  Future<void> playQueue(List<Song> queue, {required int startIndex}) async {
    state = state.copyWith(queue: queue, currentIndex: startIndex);
    await _player.loadQueue(queue, initialIndex: startIndex);
    await _player.play();
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
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);
