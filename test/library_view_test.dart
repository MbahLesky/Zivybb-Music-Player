import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/features/library/application/library_view_controller.dart';

Song _song({
  required String id,
  String title = 'Song',
  String artist = 'Artist',
  String album = 'Album',
  String? filePath,
  Duration duration = const Duration(minutes: 3),
  int playCount = 0,
  DateTime? lastPlayedAt,
  DateTime? dateAdded,
  bool isLiked = false,
}) {
  return Song(
    id: id,
    filePath: filePath ?? '/music/$id.mp3',
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    playCount: playCount,
    lastPlayedAt: lastPlayedAt,
    dateAdded: dateAdded,
    isLiked: isLiked,
  );
}

List<String> _ids(
  List<Song> songs, {
  String query = '',
  LibraryView view = const LibraryView(),
  Set<String> vibeTaggedSongIds = const {},
  Set<String>? restrictToSongIds,
}) => applyLibraryView(
  songs,
  query: query,
  view: view,
  vibeTaggedSongIds: vibeTaggedSongIds,
  restrictToSongIds: restrictToSongIds,
).map((song) => song.id).toList();

List<String> _idsPreservingOrder(List<Song> songs, {String query = ''}) =>
    applyLibraryView(
      songs,
      query: query,
      view: const LibraryView(),
      preserveOrder: true,
    ).map((song) => song.id).toList();

void main() {
  group('applyLibraryView search', () {
    final library = [
      _song(id: '1', title: 'Blue Monday', artist: 'New Order', album: 'Power'),
      _song(id: '2', title: 'Sunrise', artist: 'Norah Jones', album: 'Come'),
      _song(id: '3', title: 'Bluebird', artist: 'Alexi Murdoch', album: 'Time'),
    ];

    test('an empty query keeps everything', () {
      expect(_ids(library), ['1', '3', '2']);
    });

    test('matches on title, artist, and album alike', () {
      expect(_ids(library, query: 'blue'), ['1', '3']);
      expect(_ids(library, query: 'norah'), ['2']);
      expect(_ids(library, query: 'power'), ['1']);
    });

    test('ignores case and surrounding space', () {
      expect(_ids(library, query: '  BLUEBIRD '), ['3']);
    });
  });

  group('LibraryFilterOption', () {
    final library = [
      _song(id: 'liked', isLiked: true, playCount: 4),
      _song(id: 'tagged', playCount: 2),
      _song(id: 'fresh'),
      _song(id: 'likedFresh', isLiked: true),
    ];
    const tagged = {'tagged'};

    test('liked keeps only liked songs', () {
      expect(
        _ids(
          library,
          view: const LibraryView(filters: {LibraryFilterOption.liked}),
        ),
        ['liked', 'likedFresh'],
      );
    });

    test('has-a-vibe and no-vibe split the library between them', () {
      expect(
        _ids(
          library,
          view: const LibraryView(filters: {LibraryFilterOption.hasVibe}),
          vibeTaggedSongIds: tagged,
        ),
        ['tagged'],
      );
      expect(
        _ids(
          library,
          view: const LibraryView(filters: {LibraryFilterOption.noVibe}),
          vibeTaggedSongIds: tagged,
        ),
        // These all share a title, so the sort is a no-op and the input order
        // stands.
        ['liked', 'fresh', 'likedFresh'],
      );
    });

    test('never-played keeps songs with no play history', () {
      expect(
        _ids(
          library,
          view: const LibraryView(filters: {LibraryFilterOption.neverPlayed}),
        ),
        ['fresh', 'likedFresh'],
      );
    });

    test(
      'several filters narrow together rather than replacing each other',
      () {
        expect(
          _ids(
            library,
            view: const LibraryView(
              filters: {
                LibraryFilterOption.liked,
                LibraryFilterOption.neverPlayed,
              },
            ),
          ),
          ['likedFresh'],
          reason: 'the point of a filter set is asking for both at once',
        );
      },
    );

    test('switching on has-a-vibe switches off no-vibe', () {
      final view = const LibraryView()
          .toggling(LibraryFilterOption.noVibe)
          .toggling(LibraryFilterOption.hasVibe);

      expect(view.filters, {LibraryFilterOption.hasVibe});
      expect(
        view.filters,
        isNot(contains(LibraryFilterOption.noVibe)),
        reason: 'both at once matches nothing, which reads as a broken list',
      );
    });

    test('toggling the same option twice clears it', () {
      final view = const LibraryView()
          .toggling(LibraryFilterOption.liked)
          .toggling(LibraryFilterOption.liked);
      expect(view.filters, isEmpty);
      expect(view.isDefault, isTrue);
    });
  });

  group('folder narrowing', () {
    final library = [
      _song(id: '1', filePath: '/music/Albums/One.mp3'),
      _song(id: '2', filePath: '/music/Albums/Two.mp3'),
      _song(id: '3', filePath: '/music/Singles/Three.mp3'),
    ];

    test('a device folder keeps only that folder', () {
      expect(
        _ids(library, view: const LibraryView(deviceFolder: '/music/Albums')),
        ['1', '2'],
      );
    });

    test('a vibe folder restriction narrows before anything else', () {
      expect(_ids(library, restrictToSongIds: {'3'}), ['3']);
    });

    test('folder and filter combine', () {
      final withLike = [
        _song(id: '1', filePath: '/music/Albums/One.mp3', isLiked: true),
        _song(id: '2', filePath: '/music/Albums/Two.mp3'),
        _song(id: '3', filePath: '/music/Singles/Three.mp3', isLiked: true),
      ];
      expect(
        _ids(
          withLike,
          view: const LibraryView(
            deviceFolder: '/music/Albums',
            filters: {LibraryFilterOption.liked},
          ),
        ),
        ['1'],
      );
    });
  });

  group('sorting', () {
    final library = [
      _song(
        id: 'b',
        title: 'Beta',
        artist: 'Zeta',
        album: 'Second',
        duration: const Duration(minutes: 2),
        playCount: 9,
        lastPlayedAt: DateTime(2026, 1, 2),
        dateAdded: DateTime(2026, 3, 1),
      ),
      _song(
        id: 'a',
        title: 'Alpha',
        artist: 'Yankee',
        album: 'First',
        duration: const Duration(minutes: 5),
        playCount: 1,
        lastPlayedAt: DateTime(2026, 5, 6),
        dateAdded: DateTime(2026, 1, 1),
      ),
      _song(id: 'c', title: 'Gamma', artist: 'Xray', album: 'Third'),
    ];

    List<String> sorted(LibrarySortField field, SortDirection direction) =>
        _ids(
          library,
          view: LibraryView(sortField: field, direction: direction),
        );

    test('every field orders both ways', () {
      expect(sorted(LibrarySortField.title, SortDirection.ascending), [
        'a',
        'b',
        'c',
      ]);
      expect(sorted(LibrarySortField.title, SortDirection.descending), [
        'c',
        'b',
        'a',
      ]);
      expect(sorted(LibrarySortField.artist, SortDirection.ascending), [
        'c',
        'a',
        'b',
      ]);
      expect(sorted(LibrarySortField.album, SortDirection.ascending), [
        'a',
        'b',
        'c',
      ]);
      expect(sorted(LibrarySortField.length, SortDirection.ascending), [
        'b',
        'c',
        'a',
      ]);
      expect(sorted(LibrarySortField.length, SortDirection.descending), [
        'a',
        'c',
        'b',
      ]);
      expect(sorted(LibrarySortField.playCount, SortDirection.descending), [
        'b',
        'a',
        'c',
      ]);
      expect(sorted(LibrarySortField.playCount, SortDirection.ascending), [
        'c',
        'a',
        'b',
      ]);
    });

    test('unknown last-played sorts last whichever way the list points', () {
      expect(sorted(LibrarySortField.lastPlayed, SortDirection.descending), [
        'a',
        'b',
        'c',
      ]);
      expect(sorted(LibrarySortField.lastPlayed, SortDirection.ascending), [
        'b',
        'a',
        'c',
      ], reason: 'never played is not the same as played longest ago');
    });

    test('unknown date-added sorts last whichever way the list points', () {
      expect(sorted(LibrarySortField.dateAdded, SortDirection.descending), [
        'b',
        'a',
        'c',
      ]);
      expect(sorted(LibrarySortField.dateAdded, SortDirection.ascending), [
        'a',
        'b',
        'c',
      ], reason: 'an unknown date is not evidence of an old one');
    });

    test('preserveOrder keeps a hand-arranged list as it arrived', () {
      final arranged = [
        _song(id: 'z', title: 'Zulu'),
        _song(id: 'a', title: 'Alpha'),
        _song(id: 'm', title: 'Mike'),
      ];

      expect(_idsPreservingOrder(arranged), [
        'z',
        'a',
        'm',
      ], reason: 'opening a playlist must not silently alphabetise it');
      expect(_idsPreservingOrder(arranged, query: 'alpha'), [
        'a',
      ], reason: 'searching still narrows, it just does not reorder');
    });

    test('ties break on title, so the order never wobbles', () {
      final tied = [
        _song(id: '2', title: 'Beta', playCount: 3),
        _song(id: '1', title: 'Alpha', playCount: 3),
      ];
      expect(
        _ids(
          tied,
          view: const LibraryView(
            sortField: LibrarySortField.playCount,
            direction: SortDirection.descending,
          ),
        ),
        ['1', '2'],
      );
    });
  });

  group('LibraryView', () {
    test('picking a field takes that field\'s natural direction', () {
      final view = const LibraryView().sortedBy(LibrarySortField.lastPlayed);
      expect(view.direction, SortDirection.descending);
      expect(
        view.sortField.directionLabel(view.direction),
        'Recently played first',
      );

      final byTitle = view.sortedBy(LibrarySortField.title);
      expect(byTitle.direction, SortDirection.ascending);
      expect(byTitle.sortField.directionLabel(byTitle.direction), 'A–Z');
    });

    test(
      're-picking the field already in force leaves the direction alone',
      () {
        final reversed = const LibraryView().reversed;
        expect(
          reversed.sortedBy(LibrarySortField.title).direction,
          SortDirection.descending,
        );
      },
    );

    test('every field labels both of its directions', () {
      for (final field in LibrarySortField.values) {
        for (final direction in SortDirection.values) {
          expect(field.directionLabel(direction), isNotEmpty);
        }
        expect(
          field.directionLabel(SortDirection.ascending),
          isNot(field.directionLabel(SortDirection.descending)),
        );
      }
    });

    test('the active count covers filters and both kinds of folder', () {
      const view = LibraryView(
        filters: {LibraryFilterOption.liked, LibraryFilterOption.neverPlayed},
        vibeCategoryId: 'mood',
        deviceFolder: '/music',
      );
      expect(view.activeFilterCount, 4);
      expect(view.isDefault, isFalse);
    });

    test('a fresh view is the default', () {
      expect(const LibraryView().isDefault, isTrue);
      expect(const LibraryView().activeFilterCount, 0);
      expect(
        const LibraryView().sortChosen,
        isFalse,
        reason: 'carrying a default order is not the same as choosing one',
      );
    });

    test('picking a sort, or reversing one, counts as choosing', () {
      expect(
        const LibraryView().sortedBy(LibrarySortField.album).sortChosen,
        isTrue,
      );
      expect(const LibraryView().reversed.sortChosen, isTrue);
      expect(
        const LibraryView().toggling(LibraryFilterOption.liked).sortChosen,
        isFalse,
        reason: 'filtering a playlist should not also reorder it',
      );
    });

    test('copyWith can clear a folder back to null', () {
      const view = LibraryView(deviceFolder: '/music', vibeCategoryId: 'mood');
      final cleared = view.copyWith(deviceFolder: null, vibeCategoryId: null);
      expect(cleared.deviceFolder, isNull);
      expect(cleared.vibeCategoryId, isNull);
      expect(cleared.isDefault, isTrue);
    });

    test('describe names what is in force', () {
      const view = LibraryView(
        filters: {LibraryFilterOption.liked},
        sortField: LibrarySortField.playCount,
        direction: SortDirection.descending,
      );
      expect(view.describe(), contains('Liked only'));
      expect(view.describe(), contains('Most played first'));
    });
  });
}
