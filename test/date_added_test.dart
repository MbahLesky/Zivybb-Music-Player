import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/services/media_scanner_service.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

/// Returns whatever it was built with, so a "device rescan" can be staged
/// with an exact date-added on each pass.
class _FakeScanner implements MediaScannerService {
  _FakeScanner(this.songs);

  final List<Song> songs;

  @override
  Future<bool> hasLibraryAccess() async => true;

  @override
  Future<List<Song>> scanLibrary({bool includeVideos = false}) async => songs;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Song _song({required String id, DateTime? dateAdded}) => Song(
  id: id,
  filePath: '/music/$id.mp3',
  title: id,
  artist: 'Artist',
  album: 'Album',
  duration: const Duration(seconds: 30),
  dateAdded: dateAdded,
);

void main() {
  group('mediaStoreDateAdded', () {
    final moment = DateTime.utc(2026, 8, 1);
    final seconds = moment.millisecondsSinceEpoch ~/ 1000;

    test('reads a plain seconds value', () {
      expect(mediaStoreDateAdded(seconds)?.toUtc(), moment);
    });

    test('reads a milliseconds value from devices that report one', () {
      expect(
        mediaStoreDateAdded(seconds * 1000)?.toUtc(),
        moment,
        reason: 'a millisecond value read as seconds would land in year 56000',
      );
    });

    test('treats missing and non-positive values as unknown', () {
      expect(mediaStoreDateAdded(null), isNull);
      expect(mediaStoreDateAdded(0), isNull);
      expect(mediaStoreDateAdded(-1), isNull);
    });
  });

  group('refreshFromDevice date-added', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
    tearDown(() => database.close());

    Future<DateTime?> dateAddedOf(String id) async {
      final row = await (database.select(
        database.songs,
      )..where((t) => t.id.equals(id))).getSingle();
      return row.dateAdded;
    }

    test('records the scanned date-added', () async {
      final scanned = DateTime(2026, 5, 4);
      await SongRepository(
        database: database,
        scanner: _FakeScanner([_song(id: 'a', dateAdded: scanned)]),
      ).refreshFromDevice();

      expect(await dateAddedOf('a'), scanned);
    });

    test('a later scan without a date keeps the one already stored', () async {
      final scanned = DateTime(2026, 5, 4);
      await SongRepository(
        database: database,
        scanner: _FakeScanner([_song(id: 'a', dateAdded: scanned)]),
      ).refreshFromDevice();

      // Same song, this time with nothing in the media store's column.
      await SongRepository(
        database: database,
        scanner: _FakeScanner([_song(id: 'a')]),
      ).refreshFromDevice();

      expect(await dateAddedOf('a'), scanned);
    });

    test('backfills a row cached before the column existed', () async {
      await database
          .into(database.songs)
          .insert(
            SongsCompanion.insert(
              id: 'a',
              filePath: '/music/a.mp3',
              title: 'a',
              artist: 'Artist',
              album: 'Album',
              durationMs: 30000,
            ),
          );
      expect(await dateAddedOf('a'), isNull);

      final scanned = DateTime(2026, 5, 4);
      await SongRepository(
        database: database,
        scanner: _FakeScanner([_song(id: 'a', dateAdded: scanned)]),
      ).refreshFromDevice();

      expect(await dateAddedOf('a'), scanned);
    });
  });
}
