import '../models/song.dart';

/// Read/write access to the user's song library.
///
/// The library screen depends on this interface rather than on any concrete
/// source, so the device scanner (and, much later, any non-local source) can
/// be swapped in without touching the presentation or application layers.
abstract interface class SongRepository {
  /// Returns every known song, including ones flagged missing.
  Future<List<Song>> loadSongs();

  /// Persists the liked state of [song] and returns the updated record.
  Future<Song> setLiked(Song song, {required bool isLiked});
}
