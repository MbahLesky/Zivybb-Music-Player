import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../features/playback/application/playback_controller.dart' as playback;

/// Bridges [playback.PlaybackController] to `audio_service` so playback
/// keeps running in the background/lock screen with a system media
/// notification (SRS: background playback + notification controls).
///
/// This is a bridge, not a second source of truth: it mirrors the
/// controller's state out to the system (via [mediaItem]/[queue]/
/// [playbackState]) and routes system-initiated commands (notification
/// taps, lock-screen buttons, headset buttons) straight back into the same
/// controller the in-app UI drives, so the two surfaces never disagree.
class ZivybbAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  ZivybbAudioHandler(this._ref) {
    _ref.listen<playback.PlaybackState>(
      playback.playbackControllerProvider,
      _sync,
      fireImmediately: true,
    );
  }

  final Ref _ref;

  void _sync(playback.PlaybackState? previous, playback.PlaybackState next) {
    if (previous?.queue != next.queue) {
      queue.add([for (final song in next.queue) _toMediaItem(song)]);
    }

    final song = next.currentSong;
    if (song != null && previous?.currentSong != song) {
      mediaItem.add(_toMediaItem(song));
    }

    // Position ticks (many times a second during playback) don't need a
    // fresh broadcast — the system extrapolates position from the last
    // reported `updatePosition` + playing/speed, per audio_service's own
    // guidance. Only push when something the notification actually
    // displays has changed.
    final shouldBroadcast =
        previous == null ||
        previous.isPlaying != next.isPlaying ||
        previous.currentIndex != next.currentIndex;
    if (!shouldBroadcast) return;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          next.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: song == null
            ? AudioProcessingState.idle
            : AudioProcessingState.ready,
        playing: next.isPlaying,
        updatePosition: next.position,
        queueIndex: next.currentIndex,
      ),
    );
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );
  }

  playback.PlaybackController get _controller =>
      _ref.read(playback.playbackControllerProvider.notifier);

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> skipToNext() => _controller.next();

  @override
  Future<void> skipToPrevious() => _controller.previous();

  @override
  Future<void> seek(Duration position) => _controller.seek(position);

  @override
  Future<void> stop() async {
    await _controller.pause();
    await super.stop();
  }
}

final audioHandlerProvider = Provider<ZivybbAudioHandler>(
  (ref) => ZivybbAudioHandler(ref),
);
