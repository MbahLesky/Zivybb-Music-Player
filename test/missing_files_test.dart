import 'dart:io';

// Only `Value` — a bare drift import would collide with matcher's isNull.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/services/missing_file_service.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

import 'support/fake_scanner.dart';

/// Covers SRS F-5.3 (detect a missing file and handle it gracefully) and
/// F-5.4 (find the relocated file and re-link it automatically).
void main() {
  late Directory music;
  late AppDatabase database;

  setUp(() async {
    music = await Directory.systemTemp.createTemp('zivybb_missing_test');
    database = AppDatabase.connect(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    if (music.existsSync()) await music.delete(recursive: true);
  });

  /// Creates a real file on disk so the existence check has something true
  /// to find — the whole point of F-5.3 is what happens when it doesn't.
  Future<File> writeFile(String name) async {
    final file = File('${music.path}/$name');
    await file.writeAsString('not really audio');
    return file;
  }

  Future<void> insertSong(
    String id, {
    required String filePath,
    String title = 'Title',
    String artist = 'Artist',
    bool isMissing = false,
  }) {
    return database
        .into(database.songs)
        .insert(
          SongsCompanion.insert(
            id: id,
            filePath: filePath,
            title: title,
            artist: artist,
            album: 'Album',
            durationMs: 180000,
            isMissing: Value(isMissing),
          ),
        );
  }

  Future<bool> isMissing(String id) async {
    final row = await (database.select(
      database.songs,
    )..where((t) => t.id.equals(id))).getSingle();
    return row.isMissing;
  }

  Song deviceSong({
    required String filePath,
    String id = 'device',
    String title = 'Title',
    String artist = 'Artist',
  }) => Song(
    id: id,
    filePath: filePath,
    title: title,
    artist: artist,
    album: 'Album',
    duration: const Duration(minutes: 3),
  );

  group('detectMissingFiles (F-5.3)', () {
    test('flags a song whose file is gone', () async {
      final file = await writeFile('a.mp3');
      await insertSong('a', filePath: file.path);
      await file.delete();

      await SongRepository(
        database: database,
        scanner: FakeScanner(),
      ).detectMissingFiles();

      expect(await isMissing('a'), isTrue);
    });

    test('leaves a song whose file is still there alone', () async {
      final file = await writeFile('a.mp3');
      await insertSong('a', filePath: file.path);

      await SongRepository(
        database: database,
        scanner: FakeScanner(),
      ).detectMissingFiles();

      expect(await isMissing('a'), isFalse);
    });

    test('clears the flag when the file comes back', () async {
      // Restoring from a backup or remounting an SD card has to un-flag the
      // song, or it would stay in Missing Files forever.
      final file = await writeFile('a.mp3');
      await insertSong('a', filePath: file.path, isMissing: true);

      await SongRepository(
        database: database,
        scanner: FakeScanner(),
      ).detectMissingFiles();

      expect(await isMissing('a'), isFalse);
    });

    test('checks every song rather than stopping at the first gap', () async {
      final present = await writeFile('present.mp3');
      await insertSong('gone', filePath: '${music.path}/never-existed.mp3');
      await insertSong('here', filePath: present.path);

      await SongRepository(
        database: database,
        scanner: FakeScanner(),
      ).detectMissingFiles();

      expect(await isMissing('gone'), isTrue);
      expect(await isMissing('here'), isFalse);
    });
  });

  group('scanForMatch (F-5.4)', () {
    late MissingFileService service;

    setUp(() {
      service = MissingFileService(
        songRepository: SongRepository(
          database: database,
          scanner: FakeScanner(),
        ),
        scanner: FakeScanner(),
      );
    });

    final missing = Song(
      id: 'a',
      filePath: '/old/song.mp3',
      title: 'Blue Monday',
      artist: 'New Order',
      album: 'Power',
      duration: const Duration(minutes: 3),
    );

    test('matches a file that moved but kept its name', () {
      final match = service.scanForMatch(missing, [
        deviceSong(filePath: '/new/song.mp3', title: 'Other', artist: 'Other'),
      ]);
      expect(match, '/new/song.mp3');
    });

    test('matches on title and artist when the name changed', () {
      final match = service.scanForMatch(missing, [
        deviceSong(
          filePath: '/new/renamed.mp3',
          title: 'Blue Monday',
          artist: 'New Order',
        ),
      ]);
      expect(match, '/new/renamed.mp3');
    });

    test('ignores a candidate sitting at the path already recorded', () {
      // That path is the one already known to be gone, so re-linking to it
      // would just leave the song missing.
      final match = service.scanForMatch(missing, [
        deviceSong(filePath: '/old/song.mp3'),
      ]);
      expect(match, isNull);
    });

    test('returns null when nothing resembles the song', () {
      final match = service.scanForMatch(missing, [
        deviceSong(
          filePath: '/new/unrelated.mp3',
          title: 'Sunrise',
          artist: 'Norah Jones',
        ),
      ]);
      expect(match, isNull);
    });

    test('needs both title and artist to match, not just one', () {
      final match = service.scanForMatch(missing, [
        deviceSong(
          filePath: '/new/other.mp3',
          title: 'Blue Monday',
          artist: 'Someone Else',
        ),
      ]);
      expect(match, isNull);
    });
  });

  group('autoRelinkAll (F-5.4)', () {
    test(
      're-points a missing song at its new path and clears the flag',
      () async {
        await insertSong(
          'a',
          filePath: '/old/song.mp3',
          title: 'Blue Monday',
          isMissing: true,
        );
        final songs = SongRepository(
          database: database,
          scanner: FakeScanner(),
        );

        await MissingFileService(
          songRepository: songs,
          scanner: FakeScanner([
            deviceSong(filePath: '/new/song.mp3', title: 'Blue Monday'),
          ]),
        ).autoRelinkAll();

        final row = await (database.select(
          database.songs,
        )..where((t) => t.id.equals('a'))).getSingle();
        expect(row.filePath, '/new/song.mp3');
        expect(row.isMissing, isFalse);
      },
    );

    test('leaves a song missing when the device has no match', () async {
      await insertSong('a', filePath: '/old/song.mp3', isMissing: true);
      final songs = SongRepository(database: database, scanner: FakeScanner());

      await MissingFileService(
        songRepository: songs,
        scanner: FakeScanner([
          deviceSong(
            filePath: '/new/unrelated.mp3',
            title: 'Sunrise',
            artist: 'Norah Jones',
          ),
        ]),
      ).autoRelinkAll();

      expect(await isMissing('a'), isTrue);
    });

    test('does not touch songs that were never flagged missing', () async {
      await insertSong('a', filePath: '/old/song.mp3');
      final songs = SongRepository(database: database, scanner: FakeScanner());

      await MissingFileService(
        songRepository: songs,
        scanner: FakeScanner([deviceSong(filePath: '/somewhere/song.mp3')]),
      ).autoRelinkAll();

      final row = await (database.select(
        database.songs,
      )..where((t) => t.id.equals('a'))).getSingle();
      expect(row.filePath, '/old/song.mp3');
    });
  });
}
