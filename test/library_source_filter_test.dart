import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/library_source_filter.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

import 'support/fake_scanner.dart';

const _voiceNote =
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/'
    'WhatsApp Voice Notes/202608/PTT-20260828.opus';
const _track = '/storage/emulated/0/Music/Album/Track.mp3';

Song _song(
  String id, {
  required String filePath,
  Duration duration = const Duration(minutes: 3),
}) => Song(
  id: id,
  filePath: filePath,
  title: 'Song $id',
  artist: 'Artist',
  album: 'Album',
  duration: duration,
);

void main() {
  group('LibrarySourceFilter', () {
    test('drops a WhatsApp voice note and keeps a track', () {
      const filter = LibrarySourceFilter();

      expect(filter.allows(_voiceNote, const Duration(seconds: 8)), isFalse);
      expect(filter.allows(_track, const Duration(minutes: 3)), isTrue);
    });

    test('drops a long recording on its folder name alone', () {
      const filter = LibrarySourceFilter();

      expect(
        filter.allows(
          '/storage/Recordings/meeting.m4a',
          const Duration(hours: 1),
        ),
        isFalse,
        reason: 'length is not what makes a recording a recording',
      );
    });

    test('drops a short clip from a music folder', () {
      const filter = LibrarySourceFilter();

      expect(filter.allows(_track, const Duration(seconds: 12)), isFalse);
    });

    test('keeps a track the media store gave no duration for', () {
      const filter = LibrarySourceFilter();

      expect(
        filter.allows(_track, Duration.zero),
        isTrue,
        reason: 'an unmeasured track is not the same as a short one',
      );
    });

    test('the user switching a folder on beats the name-based guess', () {
      const filter = LibrarySourceFilter();
      final folder =
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/'
          'WhatsApp Audio';
      expect(filter.allowsFolder(folder), isFalse);

      final relaxed = filter.withFolder(folder, included: true);
      expect(relaxed.allowsFolder(folder), isTrue);
      expect(relaxed.includedFolders, contains(folder));
      expect(relaxed.isUserChoice(folder), isTrue);
    });

    test('switching a folder back to its default forgets the override', () {
      const filter = LibrarySourceFilter();
      const folder = '/storage/emulated/0/Music';

      final off = filter.withFolder(folder, included: false);
      expect(off.excludedFolders, contains(folder));

      final backOn = off.withFolder(folder, included: true);
      expect(
        backOn.excludedFolders,
        isEmpty,
        reason: 'a folder at its default needs no stored decision',
      );
      expect(backOn.includedFolders, isEmpty);
      expect(backOn.allowsFolder(folder), isTrue);
    });

    test('a folder is never in both override sets at once', () {
      const folder = '/storage/emulated/0/Recordings';
      final filter = const LibrarySourceFilter()
          .withFolder(folder, included: true)
          .withFolder(folder, included: false);

      expect(filter.includedFolders, isEmpty);
      expect(filter.allowsFolder(folder), isFalse);
    });

    test('folder matching survives a differently spelled path', () {
      final filter = const LibrarySourceFilter().withFolder(
        '/storage/emulated/0/Music/',
        included: false,
      );

      expect(filter.allowsFolder('/storage/emulated/0/MUSIC'), isFalse);
    });

    test(
      'turning the guess off admits every folder the user has not vetoed',
      () {
        const filter = LibrarySourceFilter(autoExcludeNonMusicFolders: false);

        expect(filter.allowsFolder('/storage/Recordings'), isTrue);
        expect(
          filter
              .withFolder('/storage/Recordings', included: false)
              .allowsFolder('/storage/Recordings'),
          isFalse,
        );
      },
    );

    test('overrides round-trip through JSON', () {
      final filter = const LibrarySourceFilter()
          .withFolder('/a/Recordings', included: true)
          .withFolder('/b/Music', included: false);

      final read = LibrarySourceFilter.overridesFromJson(
        filter.overridesToJson(),
      );

      expect(read.included, {'/a/Recordings'});
      expect(read.excluded, {'/b/Music'});
    });

    test('unreadable stored overrides fall back to none', () {
      expect(
        LibrarySourceFilter.overridesFromJson('not json').included,
        isEmpty,
      );
      expect(LibrarySourceFilter.overridesFromJson(null).excluded, isEmpty);
      expect(LibrarySourceFilter.overridesFromJson('[1,2]').included, isEmpty);
    });
  });

  group('SongRepository filtering', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
    tearDown(() => database.close());

    test('a scan only caches what the filter admits', () async {
      final repository = SongRepository(
        database: database,
        scanner: FakeScanner([
          _song('1', filePath: _track),
          _song(
            '2',
            filePath: _voiceNote,
            duration: const Duration(seconds: 9),
          ),
        ]),
      );

      await repository.refreshFromDevice();

      expect((await repository.allSongs()).map((s) => s.id), ['1']);
    });

    test(
      'narrowing the filter clears out what an earlier scan let in',
      () async {
        final scanner = FakeScanner([
          _song('1', filePath: _track),
          _song('2', filePath: '/storage/emulated/0/Recordings/note.m4a'),
        ]);
        final repository = SongRepository(database: database, scanner: scanner);

        await repository.refreshFromDevice(
          filter: const LibrarySourceFilter(autoExcludeNonMusicFolders: false),
        );
        expect((await repository.allSongs()), hasLength(2));

        // The default filter would never have admitted the recording; the
        // point of the prune is that it goes even though it is already cached.
        await repository.refreshFromDevice();

        expect((await repository.allSongs()).map((s) => s.id), ['1']);
      },
    );

    test('a pruned song takes its playlist entry and vibe with it', () async {
      final scanner = FakeScanner([
        _song('2', filePath: '/storage/emulated/0/Recordings/note.m4a'),
      ]);
      final repository = SongRepository(database: database, scanner: scanner);
      await repository.refreshFromDevice(
        filter: const LibrarySourceFilter(autoExcludeNonMusicFolders: false),
      );

      await database
          .into(database.vibeTags)
          .insert(
            VibeTagsCompanion.insert(id: 'v', label: 'Vibe', colorHex: '#FFF'),
          );
      await database
          .into(database.songVibes)
          .insert(SongVibesCompanion.insert(songId: '2', vibeTagId: 'v'));
      await database
          .into(database.playlists)
          .insert(
            PlaylistsCompanion.insert(
              id: 'p',
              name: 'Mix',
              createdAt: DateTime.now(),
            ),
          );
      await database
          .into(database.playlistSongs)
          .insert(
            PlaylistSongsCompanion.insert(
              playlistId: 'p',
              songId: '2',
              position: 0,
            ),
          );

      await repository.refreshFromDevice();

      expect(await repository.allSongs(), isEmpty);
      expect(await database.select(database.songVibes).get(), isEmpty);
      expect(await database.select(database.playlistSongs).get(), isEmpty);
    });

    test('deviceFolders lists folders the filter excludes', () async {
      final repository = SongRepository(
        database: database,
        scanner: FakeScanner([
          _song('1', filePath: _track),
          _song('2', filePath: _voiceNote),
          _song('3', filePath: '/storage/emulated/0/Music/Album/Other.mp3'),
        ]),
      );

      final folders = await repository.deviceFolders();

      // Sorted by folder name, so the voice notes' "202608" comes before
      // "Album".
      expect(folders.map((f) => f.trackCount), [1, 2]);
      expect(
        folders.any((f) => f.path.contains('WhatsApp Voice Notes')),
        isTrue,
        reason:
            'an excluded folder must still be listed, or it can never '
            'be switched back on',
      );
    });
  });
}
