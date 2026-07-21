import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';

/// Thin wrapper around the underlying audio engine ([AudioPlayer]).
///
/// Keeps `just_audio` out of the feature/application layer so the engine
/// can be swapped later without touching playback controllers.
class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _crossfadeSubscription = _player.positionStream.listen(
      _maybeApplyCrossfadeVolume,
    );
  }

  final AudioPlayer _player;
  late final StreamSubscription<Duration> _crossfadeSubscription;

  bool _crossfadeEnabled = false;
  Duration _crossfadeDuration = const Duration(seconds: 3);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.playerStateStream.map((state) => state.processingState);

  bool get isShuffleModeEnabled => _player.shuffleModeEnabled;

  /// Loads [queue] into the engine as a gapless playlist and starts playback
  /// at [initialIndex].
  Future<void> loadQueue(List<Song> queue, {int initialIndex = 0}) async {
    await _player.setAudioSources([
      for (final song in queue) AudioSource.uri(Uri.file(song.filePath)),
    ], initialIndex: initialIndex);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seekToNext() => _player.seekToNext();

  Future<void> seekToPrevious() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _player.shuffle();
    }
  }

  /// Configures the fade applied around track boundaries (SRS F-1.4).
  ///
  /// This is a same-engine volume fade at the boundary between consecutive
  /// gapless tracks, not two tracks playing simultaneously — a single
  /// `just_audio` engine can't overlap two audio sources. In practice it
  /// reads as a smooth transition for the common case of letting one track
  /// run into the next.
  void setCrossfadeSettings({
    required bool enabled,
    required Duration duration,
  }) {
    _crossfadeEnabled = enabled;
    _crossfadeDuration = duration;
    if (!enabled) {
      _player.setVolume(1);
    }
  }

  void _maybeApplyCrossfadeVolume(Duration position) {
    if (!_crossfadeEnabled) return;
    final duration = _player.duration;
    if (duration == null ||
        duration <= Duration.zero ||
        _crossfadeDuration <= Duration.zero) {
      return;
    }

    final fadeInEnd = _crossfadeDuration;
    final fadeOutStart = duration - _crossfadeDuration;

    var volume = 1.0;
    if (position <= fadeInEnd) {
      volume = position.inMilliseconds / fadeInEnd.inMilliseconds;
    } else if (position >= fadeOutStart) {
      final remaining = duration - position;
      volume = remaining.inMilliseconds / _crossfadeDuration.inMilliseconds;
    }
    _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _crossfadeSubscription.cancel();
    await _player.dispose();
  }
}
