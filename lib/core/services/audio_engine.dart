import '../../data/models/song.dart';

/// The playback surface the app codes against.
///
/// Keeping this an interface means the package chosen for gapless playback and
/// crossfade (Architecture Overview, section 5) stays a detail of the data
/// layer instead of leaking into playback controllers and screens.
abstract interface class AudioEngine {
  /// Playback position within the loaded track.
  Duration get position;

  /// Emits on every position change while playing.
  Stream<Duration> get positionStream;

  /// Emits once each time a track plays through to its end.
  Stream<void> get trackCompletions;

  /// Prepares [song] for playback without starting it.
  Future<void> load(Song song);

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> dispose();
}
