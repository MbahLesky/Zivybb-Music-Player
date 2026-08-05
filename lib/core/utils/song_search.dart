import '../../data/models/song.dart';

/// Case-insensitive match against a song's title, artist, or album, used by
/// every song-list search field. An empty or whitespace-only [query]
/// matches everything.
bool songMatchesQuery(Song song, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return song.title.toLowerCase().contains(normalized) ||
      song.artist.toLowerCase().contains(normalized) ||
      song.album.toLowerCase().contains(normalized);
}
