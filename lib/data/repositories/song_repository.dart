import 'dart:io';

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

  /// Emits songs currently flagged as missing (SRS F-5.3), for the Missing
  /// Files screen.
  Stream<List<Song>> watchMissingSongs() {
    final query = _database.select(_database.songs)
      ..where((t) => t.isMissing.equals(true));
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
  /// Preserves user-assigned state (liked, mood tag, and any Tag Editor
  /// edits to title/artist/album) for songs that already existed in the
  /// cache; only file path, duration, and missing status are refreshed from
  /// the device.
  Future<List<Song>> refreshFromDevice() async {
    final songs = await _scanner.scanLibrary();
    await _database.batch((batch) {
      batch.insertAll(
        _database.songs,
        songs.map((song) => song.toCompanion()),
        onConflict: DoUpdate<Songs, SongRow>.withExcluded(
          (old, excluded) => SongsCompanion.custom(
            filePath: excluded.filePath,
            durationMs: excluded.durationMs,
            isMissing: const Constant(false),
          ),
        ),
      );
    });
    return songs;
  }

  /// Checks every cached song's file for existence and updates [isMissing]
  /// accordingly (SRS F-5.3). Awaits each check in turn — async `dart:io`
  /// calls are dispatched off the main isolate's event loop, so this
  /// doesn't block the UI (SRS N-3) — rather than spawning a dedicated
  /// isolate, which is more than a personal-sized library needs.
  Future<void> detectMissingFiles() async {
    final rows = await _database.select(_database.songs).get();
    for (final row in rows) {
      final isMissingNow = !await File(row.filePath).exists();
      if (isMissingNow != row.isMissing) {
        await setMissing(row.id, isMissingNow);
      }
    }
  }

  Future<void> setMissing(String songId, bool isMissing) {
    return (_database.update(_database.songs)
          ..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(isMissing: Value(isMissing)));
  }

  /// Points a song at a newly found file location and clears [isMissing]
  /// (SRS F-5.4).
  Future<void> relink(String songId, String newFilePath) {
    return (_database.update(
      _database.songs,
    )..where((t) => t.id.equals(songId))).write(
      SongsCompanion(
        filePath: Value(newFilePath),
        isMissing: const Value(false),
      ),
    );
  }

  /// Removes a song from the library entirely (Screens.md #14: "remove from
  /// library").
  Future<void> deleteFromLibrary(String songId) {
    return (_database.delete(
      _database.songs,
    )..where((t) => t.id.equals(songId))).go();
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

  /// Edits a song's metadata (SRS F-6.1). This updates Zivybb's cache only,
  /// not the audio file's own tags; [refreshFromDevice] never overwrites
  /// these fields once cached, so the edit sticks.
  Future<void> updateMetadata(
    String songId, {
    required String title,
    required String artist,
    required String album,
  }) {
    return (_database.update(
      _database.songs,
    )..where((t) => t.id.equals(songId))).write(
      SongsCompanion(
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
      ),
    );
  }

  /// One-off (non-reactive) lookup used to regenerate auto-generated mood
  /// playlists (SRS F-4.2).
  Future<List<Song>> songsWithMoodTag(String moodTagId) async {
    final query = _database.select(_database.songs)
      ..where((t) => t.moodTagId.equals(moodTagId));
    final rows = await query.get();
    return rows.map(Song.fromRow).toList(growable: false);
  }

  /// One-off (non-reactive) lookup used by [MissingFileService].
  Future<List<Song>> missingSongs() async {
    final query = _database.select(_database.songs)
      ..where((t) => t.isMissing.equals(true));
    final rows = await query.get();
    return rows.map(Song.fromRow).toList(growable: false);
  }

  /// One-off (non-reactive) fetch of the entire cached library, used by
  /// `BackupRepository` to match backup entries against the current
  /// library.
  Future<List<Song>> allSongs() async {
    final rows = await _database.select(_database.songs).get();
    return rows.map(Song.fromRow).toList(growable: false);
  }

  /// One-off (non-reactive) fetch of songs with backup-worthy state (liked
  /// or mood-tagged), used by `BackupRepository`.
  Future<List<Song>> taggedOrLikedSongs() async {
    final query = _database.select(_database.songs)
      ..where((t) => t.isLiked.equals(true) | t.moodTagId.isNotNull());
    final rows = await query.get();
    return rows.map(Song.fromRow).toList(growable: false);
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

final missingSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchMissingSongs();
});
