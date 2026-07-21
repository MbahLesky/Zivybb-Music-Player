import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        .map((rows) => rows.map(Song.fromRow).toList(growable: false));
  }

  /// Emits songs the user has marked as liked/favorite.
  Stream<List<Song>> watchLikedSongs() {
    final query = _database.select(_database.songs)
      ..where((t) => t.isLiked.equals(true));
    return query.watch().map(
      (rows) => rows.map(Song.fromRow).toList(growable: false),
    );
  }

  /// Emits a single song's live state, e.g. so a screen holding a snapshot
  /// (like the playback queue) can reflect like/mood-tag changes made
  /// elsewhere. Emits `null` if the song is removed from the cache.
  Stream<Song?> watchSong(String songId) {
    final query = _database.select(_database.songs)
      ..where((t) => t.id.equals(songId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : Song.fromRow(row),
    );
  }

  /// Re-scans the device library and upserts the results into the cache.
  ///
  /// Preserves user-assigned state (liked, mood tag) for songs that already
  /// existed in the cache; only device-derived metadata is refreshed.
  Future<List<Song>> refreshFromDevice() async {
    final songs = await _scanner.scanLibrary();
    await _database.batch((batch) {
      batch.insertAll(
        _database.songs,
        songs.map((song) => song.toCompanion()),
        onConflict: DoUpdate<Songs, SongRow>.withExcluded(
          (old, excluded) => SongsCompanion.custom(
            filePath: excluded.filePath,
            title: excluded.title,
            artist: excluded.artist,
            album: excluded.album,
            durationMs: excluded.durationMs,
            isMissing: const Constant(false),
            isLiked: old.isLiked,
            moodTagId: old.moodTagId,
          ),
        ),
      );
    });
    return songs;
  }

  Future<void> setLiked(String songId, bool isLiked) {
    return (_database.update(_database.songs)
          ..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(isLiked: Value(isLiked)));
  }

  Future<void> setMoodTag(String songId, String? moodTagId) {
    return (_database.update(_database.songs)
          ..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(moodTagId: Value(moodTagId)));
  }
}

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(
    database: ref.watch(appDatabaseProvider),
    scanner: ref.watch(mediaScannerServiceProvider),
  );
});

final songStreamProvider = StreamProvider.family<Song?, String>((ref, songId) {
  return ref.watch(songRepositoryProvider).watchSong(songId);
});
