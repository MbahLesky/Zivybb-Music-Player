import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/features/library/application/library_view_controller.dart';

Song _song({
  required String id,
  String title = 'Song',
  String artist = 'Artist',
  String album = 'Album',
  Duration duration = const Duration(minutes: 3),
  int playCount = 0,
  DateTime? lastPlayedAt,
}) {
  return Song(
    id: id,
    filePath: '/music/$id.mp3',
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    playCount: playCount,
    lastPlayedAt: lastPlayedAt,
  );
}

void main() {
  group('applyLibraryView search', () {
    final library = [
      _song(id: '1', title: 'Blue Monday', artist: 'New Order', album: 'Power'),
      _song(id: '2', title: 'Sunrise', artist: 'Norah Jones', album: 'Come'),
      _song(id: '3', title: 'Bluebird', artist: 'Alexi Murdoch', album: 'Time'),
    ];

    List<String> idsFor(String query) => applyLibraryView(
      library,
      query: query,
      sort: LibrarySort.title,
    ).map((song) => song.id).toList();

    test('an empty query returns everything', () {
      expect(idsFor('').length, 3);
    });

    test('matches on title', () {
      expect(idsFor('blue').toSet(), {'1', '3'});
    });

    test('matches on artist', () {
      expect(idsFor('norah'), ['2']);
    });

    test('matches on album', () {
      expect(idsFor('power'), ['1']);
    });

    test('is case insensitive and ignores surrounding whitespace', () {
      expect(idsFor('  BLUEBIRD  '), ['3']);
    });

    test('returns nothing when there is no match', () {
      expect(idsFor('zzzz'), isEmpty);
    });

    test('leaves the source list untouched', () {
      applyLibraryView(library, query: 'blue', sort: LibrarySort.artist);
      expect(library.map((song) => song.id), ['1', '2', '3']);
    });
  });

  group('applyLibraryView sort', () {
    final now = DateTime(2026, 8, 4, 12);
    final library = [
      _song(
        id: 'c',
        title: 'Charlie',
        artist: 'Zoe',
        album: 'Third',
        duration: const Duration(minutes: 1),
        playCount: 10,
        lastPlayedAt: now.subtract(const Duration(days: 5)),
      ),
      _song(
        id: 'a',
        title: 'Alpha',
        artist: 'Yves',
        album: 'Second',
        duration: const Duration(minutes: 6),
        playCount: 2,
        lastPlayedAt: now,
      ),
      _song(
        id: 'b',
        title: 'Bravo',
        artist: 'Xander',
        album: 'First',
        duration: const Duration(minutes: 3),
      ),
    ];

    List<String> idsFor(LibrarySort sort) => applyLibraryView(
      library,
      query: '',
      sort: sort,
    ).map((song) => song.id).toList();

    test('sorts by title', () {
      expect(idsFor(LibrarySort.title), ['a', 'b', 'c']);
    });

    test('sorts by artist', () {
      expect(idsFor(LibrarySort.artist), ['b', 'a', 'c']);
    });

    test('sorts by album', () {
      expect(idsFor(LibrarySort.album), ['b', 'a', 'c']);
    });

    test('sorts by duration in both directions', () {
      expect(idsFor(LibrarySort.durationShortest), ['c', 'b', 'a']);
      expect(idsFor(LibrarySort.durationLongest), ['a', 'b', 'c']);
    });

    test('sorts by play count in both directions', () {
      expect(idsFor(LibrarySort.mostPlayed), ['c', 'a', 'b']);
      expect(idsFor(LibrarySort.leastPlayed), ['b', 'a', 'c']);
    });

    test('recently played puts never-played songs last', () {
      expect(idsFor(LibrarySort.recentlyPlayed), ['a', 'c', 'b']);
    });

    test('every sort keeps the whole list', () {
      for (final sort in LibrarySort.values) {
        expect(idsFor(sort), hasLength(library.length), reason: sort.name);
      }
    });
  });

  test('search and sort compose', () {
    final library = [
      _song(id: '1', title: 'Blue Two', playCount: 1),
      _song(id: '2', title: 'Red One', playCount: 9),
      _song(id: '3', title: 'Blue One', playCount: 5),
    ];

    final result = applyLibraryView(
      library,
      query: 'blue',
      sort: LibrarySort.mostPlayed,
    );

    expect(result.map((song) => song.id), ['3', '1']);
  });
}
