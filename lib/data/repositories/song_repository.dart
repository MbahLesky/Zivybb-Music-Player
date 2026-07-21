import 'package:drift/drift.dart';

import '../../core/services/media_scanner_service.dart';
import '../datasources/app_database.dart';
import '../models/song.dart';

/// Single access point for the local song library.
///
/// Reads come from the cached [AppDatabase] so the UI never blocks on a
/// device scan; [refreshFromDevice] re-scans and upserts the cache in the
/// background (SRS N-3).
class SongRepository {
  SongRepository({required this._database, required this._scanner});

  final AppDatabase _database;
  final MediaScannerService _scanner;

  /// Emits the cached library, updating whenever it changes.
  Stream<List<Song>> watchLibrary() {
    return _database
        .select(_database.songs)
        .watch()
        .map((rows) => rows.map(_toSong).toList(growable: false));
  }

  /// Re-scans the device library and upserts the results into the cache.
  Future<List<Song>> refreshFromDevice() async {
    final songs = await _scanner.scanLibrary();
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.songs, songs.map(_toCompanion));
    });
    return songs;
  }

  Song _toSong(SongRow row) {
    return Song(
      id: row.id,
      filePath: row.filePath,
      title: row.title,
      artist: row.artist,
      album: row.album,
      duration: Duration(milliseconds: row.durationMs),
      moodTagId: row.moodTagId,
      isLiked: row.isLiked,
      isMissing: row.isMissing,
    );
  }

  SongsCompanion _toCompanion(Song song) {
    return SongsCompanion.insert(
      id: song.id,
      filePath: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      durationMs: song.duration.inMilliseconds,
      moodTagId: Value(song.moodTagId),
      isLiked: Value(song.isLiked),
      isMissing: Value(song.isMissing),
    );
  }
}
