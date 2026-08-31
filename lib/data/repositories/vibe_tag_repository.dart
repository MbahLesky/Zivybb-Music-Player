import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../datasources/app_database.dart';
import '../models/vibe_tag.dart';

/// Starting set of folders vibes are grouped into. Like the vibes
/// themselves these are only a starting point — the user can rename,
/// recolor, reorder, delete, or add to them.
const _defaultVibeCategories = [
  VibeCategory(id: 'mood', name: 'Mood', colorHex: '#7E57C2'),
  VibeCategory(id: 'feeling', name: 'Feeling', colorHex: '#EC407A'),
  VibeCategory(id: 'place', name: 'Place', colorHex: '#26A69A'),
  VibeCategory(id: 'time', name: 'Time', colorHex: '#42A5F5'),
  VibeCategory(id: 'genre', name: 'Genre', colorHex: '#FFA726'),
  VibeCategory(id: 'activity', name: 'Activity', colorHex: '#66BB6A'),
];

/// Starting set of vibe presets offered in the Vibe Tagging sheet
/// (Screens.md #7). Seeded once; fully editable afterward — the user can
/// rename, recolor, delete, reorder, refile, or add to these.
const _defaultVibeTags = [
  VibeTag(
    id: 'energetic',
    label: 'Energetic',
    colorHex: '#FF7043',
    categoryId: 'mood',
  ),
  VibeTag(id: 'chill', label: 'Chill', colorHex: '#4FC3F7', categoryId: 'mood'),
  VibeTag(
    id: 'happy',
    label: 'Happy',
    colorHex: '#FFCA28',
    categoryId: 'feeling',
  ),
  VibeTag(id: 'sad', label: 'Sad', colorHex: '#5C6BC0', categoryId: 'feeling'),
  VibeTag(
    id: 'angry',
    label: 'Angry',
    colorHex: '#E53935',
    categoryId: 'feeling',
  ),
  VibeTag(
    id: 'relaxed',
    label: 'Relaxed',
    colorHex: '#66BB6A',
    categoryId: 'mood',
  ),
];

/// Single access point for vibe tags and their song assignments.
class VibeTagRepository {
  VibeTagRepository({required this._database});

  final AppDatabase _database;
  static const _uuid = Uuid();

  /// Inserts the built-in folders and presets if their tables are empty.
  /// Safe to call on every app start.
  ///
  /// The two are seeded independently: installs predating vibe folders
  /// already have vibes, so gating the folders on an empty vibe table would
  /// leave them with no folders at all. Those installs get the built-in
  /// folders plus a backfill for any built-in vibe they still have under its
  /// original id — vibes the user added themselves are left uncategorised
  /// rather than guessed at.
  Future<void> ensureSeeded() async {
    await _seedCategories();

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
            categoryId: Value(entry.$2.categoryId),
          ),
        ),
      );
    });
  }

  Future<void> _seedCategories() async {
    final existing = await _database.select(_database.vibeCategories).get();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.vibeCategories,
        _defaultVibeCategories.indexed.map(
          (entry) => VibeCategoriesCompanion.insert(
            id: entry.$2.id,
            name: entry.$2.name,
            colorHex: entry.$2.colorHex,
            sortOrder: Value(entry.$1),
          ),
        ),
      );
      // Only touches rows still carrying a built-in id and no folder, so a
      // user who has already refiled (or renamed) one keeps their choice.
      for (final tag in _defaultVibeTags) {
        batch.update(
          _database.vibeTags,
          VibeTagsCompanion(categoryId: Value(tag.categoryId)),
          where: (t) => t.id.equals(tag.id) & t.categoryId.isNull(),
        );
      }
    });
  }

  Stream<List<VibeCategory>> watchVibeCategories() {
    final query = _database.select(_database.vibeCategories)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map(
      (rows) => rows.map(VibeCategory.fromRow).toList(growable: false),
    );
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

  Future<VibeTag> createVibeTag(
    String label,
    String colorHex, {
    String? categoryId,
  }) async {
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
            categoryId: Value(categoryId),
          ),
        );
    return VibeTag(
      id: id,
      label: label,
      colorHex: colorHex,
      categoryId: categoryId,
    );
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
            categoryId: Value(tag.categoryId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Moves [id] into [categoryId], or out of every folder when it is null.
  Future<void> setVibeCategory(String id, String? categoryId) {
    return (_database.update(_database.vibeTags)..where((t) => t.id.equals(id)))
        .write(VibeTagsCompanion(categoryId: Value(categoryId)));
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

  Future<VibeCategory> createVibeCategory(String name, String colorHex) async {
    final id = _uuid.v4();
    final nextOrder = await _nextCategorySortOrder();
    await _database
        .into(_database.vibeCategories)
        .insert(
          VibeCategoriesCompanion.insert(
            id: id,
            name: name,
            colorHex: colorHex,
            sortOrder: Value(nextOrder),
          ),
        );
    return VibeCategory(id: id, name: name, colorHex: colorHex);
  }

  Future<void> renameVibeCategory(String id, String name) {
    return (_database.update(_database.vibeCategories)
          ..where((t) => t.id.equals(id)))
        .write(VibeCategoriesCompanion(name: Value(name)));
  }

  Future<void> recolorVibeCategory(String id, String colorHex) {
    return (_database.update(_database.vibeCategories)
          ..where((t) => t.id.equals(id)))
        .write(VibeCategoriesCompanion(colorHex: Value(colorHex)));
  }

  /// Deletes the folder. Its vibes survive, uncategorised — a folder is a way
  /// of arranging vibes, so throwing it away must not throw away the tagging
  /// work that went into them.
  ///
  /// Clears `category_id` explicitly rather than leaving it to the `ON DELETE
  /// SET NULL` constraint: that constraint only exists on databases created
  /// after vibe folders landed.
  Future<void> deleteVibeCategory(String id) async {
    await _database.transaction(() async {
      await (_database.update(_database.vibeTags)
            ..where((t) => t.categoryId.equals(id)))
          .write(const VibeTagsCompanion(categoryId: Value(null)));
      await (_database.delete(
        _database.vibeCategories,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  /// Persists a full folder reorder: [orderedIds] must contain every folder,
  /// in its new order.
  Future<void> reorderVibeCategories(List<String> orderedIds) {
    return _database.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _database.vibeCategories,
          VibeCategoriesCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// One-off (non-reactive) fetch of the folders, used to write backups.
  Future<List<VibeCategory>> allVibeCategories() async {
    final query = _database.select(_database.vibeCategories)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    final rows = await query.get();
    return rows.map(VibeCategory.fromRow).toList(growable: false);
  }

  /// Inserts a folder with a caller-supplied id, keeping the one already
  /// stored if it exists — used when restoring a backup.
  Future<void> upsertVibeCategory(
    VibeCategory category, {
    required int sortOrder,
  }) {
    return _database
        .into(_database.vibeCategories)
        .insert(
          VibeCategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            colorHex: category.colorHex,
            sortOrder: Value(sortOrder),
          ),
          mode: InsertMode.insertOrIgnore,
        );
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

  Future<int> _nextCategorySortOrder() async {
    final maxOrder = _database.vibeCategories.sortOrder.max();
    final query = _database.selectOnly(_database.vibeCategories)
      ..addColumns([maxOrder]);
    final row = await query.getSingleOrNull();
    return (row?.read(maxOrder) ?? -1) + 1;
  }
}

final vibeTagRepositoryProvider = Provider<VibeTagRepository>(
  (ref) => VibeTagRepository(database: ref.watch(appDatabaseProvider)),
);
