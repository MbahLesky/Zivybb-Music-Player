import '../datasources/sample_song_data_source.dart';
import '../models/song.dart';
import 'song_repository.dart';

/// A [SongRepository] backed by an in-memory list.
///
/// Writes survive only for the lifetime of the process; local persistence
/// replaces this once the storage service lands (Week 1 Day 5).
class InMemorySongRepository implements SongRepository {
  InMemorySongRepository({List<Song>? songs})
    : _songs = List.of(songs ?? SampleSongDataSource.load());

  final List<Song> _songs;

  @override
  Future<List<Song>> loadSongs() async => List.unmodifiable(_songs);

  @override
  Future<Song> setLiked(Song song, {required bool isLiked}) async {
    final index = _songs.indexWhere((candidate) => candidate.id == song.id);
    if (index == -1) return song;

    final updated = _songs[index].copyWith(isLiked: isLiked);
    _songs[index] = updated;
    return updated;
  }
}
