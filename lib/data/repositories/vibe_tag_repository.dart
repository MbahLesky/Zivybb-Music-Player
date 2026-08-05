import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../datasources/app_database.dart';
import '../models/vibe_tag.dart';

/// Starting set of vibe presets offered in the Vibe Tagging sheet
/// (Screens.md #7). Seeded once; fully editable afterward — the user can
/// rename, recolor, delete, reorder, or add to these.
const _defaultVibeTags = [
  VibeTag(id: 'energetic', label: 'Energetic', colorHex: '#FF7043'),
  VibeTag(id: 'chill', label: 'Chill', colorHex: '#4FC3F7'),
  VibeTag(id: 'happy', label: 'Happy', colorHex: '#FFCA28'),
  VibeTag(id: 'sad', label: 'Sad', colorHex: '#5C6BC0'),
  VibeTag(id: 'angry', label: 'Angry', colorHex: '#E53935'),
  VibeTag(id: 'relaxed', label: 'Relaxed', colorHex: '#66BB6A'),
];

/// Single access point for vibe tags and their song assignments.
class VibeTagRepository {
  VibeTagRepository({required this._database});

  final AppDatabase _database;
  static const _uuid = Uuid();

  /// Inserts the built-in presets if the table is empty. Safe to call on
  /// every app start.
  Future<void> ensureSeeded() async {
    final existing = await _database.select(_database.vibeTags).get();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.vibeTags,
        _defaultVibeTags.indexed.map(
          (entry) => VibeTagsCompanion.insert(
            id: entry.$2.id,
            label: entry.$2.label,
            colorHex: entry.$2.colorHex,
            sortOrder: Value(entry.$1),
          ),
        ),
      );
    });
  }

  Stream<List<VibeTag>> watchVibeTags() {
    final query = _database.select(_database.vibeTags)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map(
      (rows) => rows.map(VibeTag.fromRow).toList(growable: false),
    );
  }

  /// Emits every song's vibe ids, keyed by song id, so list tiles can show
  /// their chips from one shared stream rather than a query per row.
  Stream<Map<String, List<String>>> watchSongVibeIds() {
    return _database.select(_database.songVibes).watch().map((rows) {
      final bySong = <String, List<String>>{};
      for (final row in rows) {
        bySong.putIfAbsent(row.songId, () => []).add(row.vibeTagId);
      }
      return bySong;
    });
  }

  /// Emits one song's vibe ids — used by the tagging sheet, which needs to
  /// reflect edits made while it's open.
  Stream<Set<String>> watchVibeIdsForSong(String songId) {
    final query = _database.select(_database.songVibes)
      ..where((t) => t.songId.equals(songId));
    return query.watch().map((rows) => {for (final row in rows) row.vibeTagId});
  }

  Future<void> addVibeToSong(String songId, String vibeTagId) {
    return _database
        .into(_database.songVibes)
        .insert(
          SongVibesCompanion.insert(songId: songId, vibeTagId: vibeTagId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeVibeFromSong(String songId, String vibeTagId) {
    return (_database.delete(_database.songVibes)..where(
          (t) => t.songId.equals(songId) & t.vibeTagId.equals(vibeTagId),
        ))
        .go();
  }

  /// Replaces a song's vibes wholesale — used when restoring a backup.
  Future<void> setSongVibes(String songId, List<String> vibeTagIds) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.songVibes,
      )..where((t) => t.songId.equals(songId))).go();
      if (vibeTagIds.isEmpty) return;
      await _database.batch((batch) {
        batch.insertAll(_database.songVibes, [
          for (final vibeTagId in vibeTagIds)
            SongVibesCompanion.insert(songId: songId, vibeTagId: vibeTagId),
        ], mode: InsertMode.insertOrIgnore);
      });
    });
  }

  Future<VibeTag> createVibeTag(String label, String colorHex) async {
    final id = _uuid.v4();
    final nextOrder = await _nextSortOrder();
    await _database
        .into(_database.vibeTags)
        .insert(
          VibeTagsCompanion.insert(
            id: id,
            label: label,
            colorHex: colorHex,
            sortOrder: Value(nextOrder),
          ),
        );
    return VibeTag(id: id, label: label, colorHex: colorHex);
  }

  /// Inserts a vibe tag with a caller-supplied id, keeping the one already
  /// stored if it exists — used when restoring a backup.
  Future<void> upsertVibeTag(VibeTag tag, {required int sortOrder}) {
    return _database
        .into(_database.vibeTags)
        .insert(
          VibeTagsCompanion.insert(
            id: tag.id,
            label: tag.label,
            colorHex: tag.colorHex,
            sortOrder: Value(sortOrder),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> renameVibeTag(String id, String label) {
    return (_database.update(_database.vibeTags)..where((t) => t.id.equals(id)))
        .write(VibeTagsCompanion(label: Value(label)));
  }

  Future<void> recolorVibeTag(String id, String colorHex) {
    return (_database.update(_database.vibeTags)..where((t) => t.id.equals(id)))
        .write(VibeTagsCompanion(colorHex: Value(colorHex)));
  }

  /// Deletes the tag and every song assignment of it. See
  /// `VibePlaylistGenerator.deleteVibeTag` for the full cleanup including
  /// its auto-generated playlist.
  Future<void> deleteVibeTag(String id) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.songVibes,
      )..where((t) => t.vibeTagId.equals(id))).go();
      await (_database.delete(
        _database.vibeTags,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  /// Persists a full reorder: [orderedIds] must contain every vibe tag, in
  /// its new order.
  Future<void> reorderVibeTags(List<String> orderedIds) {
    return _database.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _database.vibeTags,
          VibeTagsCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// One-off (non-reactive) fetch used to regenerate auto-generated vibe
  /// playlists (SRS F-4.2) and to write backups.
  Future<List<VibeTag>> allVibeTags() async {
    final query = _database.select(_database.vibeTags)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    final rows = await query.get();
    return rows.map(VibeTag.fromRow).toList(growable: false);
  }

  /// One-off (non-reactive) map of song id to vibe ids, used by
  /// `BackupRepository`.
  Future<Map<String, List<String>>> allSongVibeIds() async {
    final rows = await _database.select(_database.songVibes).get();
    final bySong = <String, List<String>>{};
    for (final row in rows) {
      bySong.putIfAbsent(row.songId, () => []).add(row.vibeTagId);
    }
    return bySong;
  }

  Future<int> _nextSortOrder() async {
    final maxOrder = _database.vibeTags.sortOrder.max();
    final query = _database.selectOnly(_database.vibeTags)
      ..addColumns([maxOrder]);
    final row = await query.getSingleOrNull();
    return (row?.read(maxOrder) ?? -1) + 1;
  }
}

final vibeTagRepositoryProvider = Provider<VibeTagRepository>(
  (ref) => VibeTagRepository(database: ref.watch(appDatabaseProvider)),
);
