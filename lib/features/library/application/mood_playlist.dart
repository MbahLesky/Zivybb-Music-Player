import '../../../data/models/mood_tag.dart';
import '../../../data/models/song.dart';

/// A playlist derived from a mood tag rather than assembled by hand.
///
/// These are generated from the library on every load, so they are never
/// stale and are not persisted like user-created playlists are.
class MoodPlaylist {
  const MoodPlaylist({required this.tag, required this.songs});

  final MoodTag tag;
  final List<Song> songs;
}
