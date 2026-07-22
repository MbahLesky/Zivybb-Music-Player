import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/sample_song_data_source.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/in_memory_song_repository.dart';
import 'package:zivybb/features/library/application/library_controller.dart';

void main() {
  test('sample songs only use known moods', () {
    expect(SampleSongDataSource.moodIdsAreValid, isTrue);
  });

  group('LibraryController', () {
    late LibraryController controller;

    setUp(() async {
      controller = LibraryController(
        repository: InMemorySongRepository(songs: _library),
      );
      await controller.load();
    });

    tearDown(() => controller.dispose());

    test('groups songs by their folder', () {
      expect(controller.folders.map((folder) => folder.name), [
        'Focus',
        'Workout',
      ]);
      expect(controller.folders.first.songs.length, 1);
    });

    test('adds up folder running time', () {
      expect(controller.folders.last.totalDuration, const Duration(minutes: 7));
    });

    test('builds a playlist per mood in use', () {
      expect(controller.moodPlaylists.length, 1);
      expect(controller.moodPlaylists.single.tag.id, 'energetic');
      expect(controller.moodPlaylists.single.songs.length, 2);
    });

    test('toggling liked updates the library and the liked list', () async {
      expect(controller.likedSongs, isEmpty);

      final updated = await controller.toggleLiked(controller.songs.first);

      expect(updated.isLiked, isTrue);
      expect(controller.likedSongs.map((song) => song.id), ['a']);
    });
  });
}

const _library = <Song>[
  Song(
    id: 'a',
    filePath: '/storage/Music/Workout/a.mp3',
    title: 'A',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 3),
    moodTagId: 'energetic',
  ),
  Song(
    id: 'b',
    filePath: '/storage/Music/Workout/b.mp3',
    title: 'B',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 4),
    moodTagId: 'energetic',
  ),
  Song(
    id: 'c',
    filePath: '/storage/Music/Focus/c.mp3',
    title: 'C',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 5),
  ),
];
