import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/services/media_delete_service.dart';
import '../../core/services/media_scanner_service.dart';
import '../datasources/app_database.dart';
import '../models/library_source_filter.dart';
import '../models/song.dart';

/// Single access point for the local song library.
///
/// Reads come from the cached [AppDatabase] so the UI never blocks on a
/// device scan; [refreshFromDevice] re-scans and upserts the cache in the
/// background (SRS N-3).
class SongRepository {
  SongRepository({
    required this._database,
    required this._scanner,
    MediaDeleteService? mediaDelete,
  }) : _mediaDelete = mediaDelete ?? MediaDeleteService();

  final AppDatabase _database;
  final MediaScannerService _scanner;
  final MediaDeleteService _mediaDelete;

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
  /// (like the playback queue) can reflect like changes made elsewhere.
  /// Emits `null` if the song is removed from the cache.
  Stream<Song?> watchSong(String songId) {
    final query = _database.select(_database.songs)
      ..where((t) => t.id.equals(songId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : Song.fromRow(row),
    );
  }

  /// Re-scans the device library and upserts the results into the cache.
  ///
  /// Preserves user-assigned state (liked, vibes, and any Tag Editor
  /// edits to title/artist/album) for songs that already existed in the
  /// cache; only file path, duration, and missing status are refreshed from
  /// the device.
  ///
  /// With [includeVideos] off, any video previously scanned in is dropped
  /// from the library — otherwise turning the setting back off would leave
  /// the videos behind with no way to clear them.
  ///
  /// [filter] decides which scanned files count as music. It is applied to
  /// the cache as well as to the scan: narrowing it (excluding a folder,
  /// raising the minimum length) has to clear out what a previous, wider
  /// scan already let in, or the voice notes the user just switched off
  /// would sit in the library until they wiped it by hand.
  Future<List<Song>> refreshFromDevice({
    bool includeVideos = false,
    LibrarySourceFilter filter = const LibrarySourceFilter(),
  }) async {
    final scanned = await _scanner.scanLibrary(includeVideos: includeVideos);
    final songs = scanned
        .where((song) => filter.allows(song.filePath, song.duration))
        .toList(growable: false);
    await _database.batch((batch) {
      batch.insertAll(
        _database.songs,
        songs.map((song) => song.toCompanion()),
        onConflict: DoUpdate<Songs, SongRow>.withExcluded(
          (old, excluded) => SongsCompanion.custom(
            filePath: excluded.filePath,
            durationMs: excluded.durationMs,
            isMissing: const Constant(false),
            // Whichever of the two is actually known wins, so a scan that
            // comes back without a date-added — the media store leaves it
            // empty on some devices — can't wipe a value an earlier scan
            // already recorded.
            dateAdded: coalesce([excluded.dateAdded, old.dateAdded]),
          ),
        ),
      );
    });
    if (!includeVideos) await _removeVideos();
    await _pruneFiltered(filter);
    return songs;
  }

  /// Every folder the device holds audio in, with how many tracks are in
  /// each, ignoring the current filter — the Library Sources screen has to
  /// list the folders that are switched *off* as well, or there would be no
  /// way to switch one back on.
  ///
  /// Reads the device rather than the cache for the same reason. Videos are
  /// left out: they are governed by their own setting.
  Future<List<({String path, int trackCount})>> deviceFolders() async {
    final songs = await _scanner.scanLibrary();
    final counts = <String, int>{};
    for (final song in songs) {
      final folder = p.dirname(song.filePath);
      counts[folder] = (counts[folder] ?? 0) + 1;
    }
    final folders = counts.entries
        .map((entry) => (path: entry.key, trackCount: entry.value))
        .toList();
    folders.sort(
      (a, b) => p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase()),
    );
    return List.unmodifiable(folders);
  }

  /// Clears out video entries and everything referencing them, so a library
  /// that no longer includes videos doesn't keep them in playlists, vibes,
  /// or the Liked list.
  Future<void> _removeVideos() async {
    final videoIds = await (_database.select(
      _database.songs,
    )..where((t) => t.isVideo.equals(true))).map((row) => row.id).get();
    await _removeSongs(videoIds);
  }

  /// Drops cached songs the current [filter] no longer admits.
  ///
  /// Decided from the cached row's own path and duration rather than from
  /// what the scan returned: a song absent from a scan may simply be on
  /// storage that isn't mounted, and that case belongs to missing-file
  /// detection, not here.
  Future<void> _pruneFiltered(LibrarySourceFilter filter) async {
    final rows = await _database.select(_database.songs).get();
    final doomed = [
      for (final row in rows)
        if (!row.isVideo &&
            !filter.allows(
              row.filePath,
              Duration(milliseconds: row.durationMs),
            ))
          row.id,
    ];
    await _removeSongs(doomed);
  }

  /// Deletes [songIds] and everything pointing at them, in one transaction.
  Future<void> _removeSongs(List<String> songIds) async {
    if (songIds.isEmpty) return;
    await _database.transaction(() async {
      await (_database.delete(
        _database.songVibes,
      )..where((t) => t.songId.isIn(songIds))).go();
      await (_database.delete(
        _database.playlistSongs,
      )..where((t) => t.songId.isIn(songIds))).go();
      await (_database.delete(
        _database.gameScores,
      )..where((t) => t.songId.isIn(songIds))).go();
      await (_database.delete(
        _database.songs,
      )..where((t) => t.id.isIn(songIds))).go();
    });
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
  /// library"), along with its vibe assignments and any playlist entries
  /// pointing at it.
  ///
  /// Those deletes are explicit rather than left to `ON DELETE CASCADE`,
  /// because databases created before foreign keys were declared have no
  /// cascade — and a leftover entry would reappear inside a playlist the
  /// moment a device rescan reused that media-store ID.
  Future<void> deleteFromLibrary(String songId) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.songVibes,
      )..where((t) => t.songId.equals(songId))).go();
      await (_database.delete(
        _database.playlistSongs,
      )..where((t) => t.songId.equals(songId))).go();
      await (_database.delete(
        _database.gameScores,
      )..where((t) => t.songId.equals(songId))).go();
      await (_database.delete(
        _database.songs,
      )..where((t) => t.id.equals(songId))).go();
    });
  }

  /// Deletes a song's file from the device, and drops it from the library
  /// only if that actually succeeded.
  ///
  /// The order matters: from Android 11 on the system shows its own delete
  /// confirmation, so the file may well survive a request the user then
  /// declines. Removing the library row first would leave the song playable
  /// on the device but invisible in Zivybb until the next scan re-added it —
  /// stripped of its likes and vibes.
  Future<MediaDeleteOutcome> deleteFromDevice(Song song) async {
    final outcome = await _mediaDelete.deleteSong(song);
    if (outcome == MediaDeleteOutcome.deleted) {
      await deleteFromLibrary(song.id);
    }
    return outcome;
  }

  /// Bumps a song's play count and last-played timestamp (SRS F-4.3), so
  /// Song Discovery can favor tracks that are played less often.
  Future<void> recordPlayed(String songId) {
    return (_database.update(
      _database.songs,
    )..where((t) => t.id.equals(songId))).write(
      SongsCompanion.custom(
        playCount: _database.songs.playCount + const Constant(1),
        lastPlayedAt: Constant(DateTime.now()),
      ),
    );
  }

  Future<void> setLiked(String songId, bool isLiked) {
    return (_database.update(_database.songs)
          ..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(isLiked: Value(isLiked)));
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
  /// or vibe-tagged), used by `BackupRepository`.
  Future<List<Song>> taggedOrLikedSongs(Set<String> vibeTaggedSongIds) async {
    final query = _database.select(_database.songs)
      ..where((t) => t.isLiked.equals(true) | t.id.isIn(vibeTaggedSongIds));
    final rows = await query.get();
    return rows.map(Song.fromRow).toList(growable: false);
  }
}

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(
    database: ref.watch(appDatabaseProvider),
    scanner: ref.watch(mediaScannerServiceProvider),
    mediaDelete: ref.watch(mediaDeleteServiceProvider),
  );
});

final songStreamProvider = StreamProvider.family<Song?, String>((ref, songId) {
  return ref.watch(songRepositoryProvider).watchSong(songId);
});

final missingSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchMissingSongs();
});
