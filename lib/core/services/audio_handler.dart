import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../features/playback/application/playback_controller.dart'
    as playback;

/// Custom action name for the notification's like button, round-tripped
/// through `audio_service` back into [ZivybbAudioHandler.customAction].
const toggleLikeAction = 'zivybb.toggleLike';

/// Bridges [playback.PlaybackController] to `audio_service` so playback
/// keeps running in the background/lock screen with a system media
/// notification (SRS: background playback + notification controls).
///
/// This is a bridge, not a second source of truth: it mirrors the
/// controller's state out to the system (via [mediaItem]/[queue]/
/// [playbackState]) and routes system-initiated commands (notification
/// taps, lock-screen buttons, headset buttons) straight back into the same
/// controller the in-app UI drives, so the two surfaces never disagree.
class ZivybbAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  ZivybbAudioHandler(this._ref) {
    _ref.listen<playback.PlaybackState>(
      playback.playbackControllerProvider,
      _sync,
      fireImmediately: true,
    );
    _ref.onDispose(() => _likedSubscription?.cancel());
  }

  final Ref _ref;

  /// Whether the current song is liked. Tracked separately from
  /// [playback.PlaybackState] because its `queue` holds [Song] snapshots
  /// taken when the queue was loaded — liking a song from anywhere in the
  /// app updates the database, not those snapshots.
  bool _isLiked = false;
  String? _likedSongId;
  StreamSubscription<Song?>? _likedSubscription;

  void _sync(playback.PlaybackState? previous, playback.PlaybackState next) {
    if (previous?.queue != next.queue) {
      queue.add([for (final song in next.queue) _toMediaItem(song)]);
    }

    final song = next.currentSong;
    if (song != null && previous?.currentSong != song) {
      mediaItem.add(_toMediaItem(song));
    }
    _watchLikedState(song?.id);

    // Position ticks (many times a second during playback) don't need a
    // fresh broadcast — the system extrapolates position from the last
    // reported `updatePosition` + playing/speed, per audio_service's own
    // guidance. Only push when something the notification actually
    // displays has changed.
    //
    // The current song is part of that test, not just the index: restoring a
    // saved session loads a track at index 0 while paused, so neither
    // `isPlaying` nor `currentIndex` moves, and without this the handler
    // stayed at `AudioProcessingState.idle` — which audio_service reads as
    // "nothing to show" — until the user pressed play.
    final shouldBroadcast =
        previous == null ||
        previous.isPlaying != next.isPlaying ||
        previous.currentIndex != next.currentIndex ||
        previous.currentSong != next.currentSong;
    if (!shouldBroadcast) return;

    _broadcast(next);
  }

  /// Re-points the liked-state subscription at [songId], so the heart in the
  /// notification tracks likes made anywhere in the app (or from the
  /// notification itself).
  void _watchLikedState(String? songId) {
    if (songId == _likedSongId) return;
    _likedSongId = songId;
    _likedSubscription?.cancel();
    _likedSubscription = null;

    if (songId == null) {
      _isLiked = false;
      return;
    }
    _likedSubscription = _ref
        .read(songRepositoryProvider)
        .watchSong(songId)
        .listen((song) {
          final isLiked = song?.isLiked ?? false;
          if (isLiked == _isLiked) return;
          _isLiked = isLiked;
          _broadcast(_ref.read(playback.playbackControllerProvider));
        });
  }

  void _broadcast(playback.PlaybackState state) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.custom(
            androidIcon: _isLiked
                ? 'drawable/ic_notification_favorite'
                : 'drawable/ic_notification_favorite_border',
            label: _isLiked ? 'Unlike' : 'Like',
            name: toggleLikeAction,
          ),
          MediaControl.skipToPrevious,
          state.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        // The collapsed notification only fits three actions, so it keeps
        // the transport controls; the heart shows once expanded and on the
        // lock screen, where all four are visible.
        androidCompactActionIndices: const [1, 2, 3],
        processingState: state.currentSong == null
            ? AudioProcessingState.idle
            : AudioProcessingState.ready,
        playing: state.isPlaying,
        updatePosition: state.position,
        queueIndex: state.currentIndex,
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
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name != toggleLikeAction) {
      return super.customAction(name, extras);
    }
    final songId = _likedSongId;
    if (songId == null) return;
    // No local state update: the write lands in the database, and the
    // watchSong subscription above pushes the new heart back out.
    await _ref.read(songRepositoryProvider).setLiked(songId, !_isLiked);
  }

  @override
  Future<void> stop() async {
    await _controller.pause();
    await super.stop();
  }
}

final audioHandlerProvider = Provider<ZivybbAudioHandler>(
  (ref) => ZivybbAudioHandler(ref),
);
