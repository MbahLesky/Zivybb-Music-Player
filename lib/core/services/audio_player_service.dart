import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';

/// Thin wrapper around the underlying audio engine ([AudioPlayer]).
///
/// Keeps `just_audio` out of the feature/application layer so the engine
/// can be swapped later without touching playback controllers.
class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

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

  Future<void> dispose() => _player.dispose();
}
