import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../datasources/app_database.dart';
import '../models/mood_tag.dart';

/// Starting set of mood/energy presets offered in the Mood Tagging screen
/// (Screens.md #7). Seeded once; fully editable afterward — the user can
/// rename, recolor, delete, reorder, or add to these.
const _defaultMoodTags = [
  MoodTag(id: 'energetic', label: 'Energetic', colorHex: '#FF7043'),
  MoodTag(id: 'chill', label: 'Chill', colorHex: '#4FC3F7'),
  MoodTag(id: 'happy', label: 'Happy', colorHex: '#FFCA28'),
  MoodTag(id: 'sad', label: 'Sad', colorHex: '#5C6BC0'),
  MoodTag(id: 'angry', label: 'Angry', colorHex: '#E53935'),
  MoodTag(id: 'relaxed', label: 'Relaxed', colorHex: '#66BB6A'),
];

/// Single access point for mood/energy tags.
class MoodTagRepository {
  MoodTagRepository({required this._database});

  final AppDatabase _database;
  static const _uuid = Uuid();

  /// Inserts the built-in presets if the table is empty. Safe to call on
  /// every app start.
  Future<void> ensureSeeded() async {
    final existing = await _database.select(_database.moodTags).get();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.moodTags,
        _defaultMoodTags.indexed.map(
          (entry) => MoodTagsCompanion.insert(
            id: entry.$2.id,
            label: entry.$2.label,
            colorHex: entry.$2.colorHex,
            sortOrder: Value(entry.$1),
          ),
        ),
      );
    });
  }

  Stream<List<MoodTag>> watchMoodTags() {
    final query = _database.select(_database.moodTags)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map(
      (rows) => rows.map(MoodTag.fromRow).toList(growable: false),
    );
  }

  Future<MoodTag> createMoodTag(String label, String colorHex) async {
    final id = _uuid.v4();
    final nextOrder = await _nextSortOrder();
    await _database
        .into(_database.moodTags)
        .insert(
          MoodTagsCompanion.insert(
            id: id,
            label: label,
            colorHex: colorHex,
            sortOrder: Value(nextOrder),
          ),
        );
    return MoodTag(id: id, label: label, colorHex: colorHex);
  }

  Future<void> renameMoodTag(String id, String label) {
    return (_database.update(_database.moodTags)..where((t) => t.id.equals(id)))
        .write(MoodTagsCompanion(label: Value(label)));
  }

  Future<void> recolorMoodTag(String id, String colorHex) {
    return (_database.update(_database.moodTags)..where((t) => t.id.equals(id)))
        .write(MoodTagsCompanion(colorHex: Value(colorHex)));
  }

  /// Deletes the tag. Songs tagged with it fall back to untagged; see
  /// `MoodPlaylistGenerator.deleteMoodTag` for the full cleanup including
  /// its auto-generated playlist.
  Future<void> deleteMoodTag(String id) {
    return (_database.delete(
      _database.moodTags,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Persists a full reorder: [orderedIds] must contain every mood tag, in
  /// its new order.
  Future<void> reorderMoodTags(List<String> orderedIds) {
    return _database.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _database.moodTags,
          MoodTagsCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// One-off (non-reactive) fetch used to regenerate auto-generated mood
  /// playlists (SRS F-4.2).
  Future<List<MoodTag>> allMoodTags() async {
    final rows = await _database.select(_database.moodTags).get();
    return rows.map(MoodTag.fromRow).toList(growable: false);
  }

  Future<int> _nextSortOrder() async {
    final maxOrder = _database.moodTags.sortOrder.max();
    final query = _database.selectOnly(_database.moodTags)
      ..addColumns([maxOrder]);
    final row = await query.getSingleOrNull();
    return (row?.read(maxOrder) ?? -1) + 1;
  }
}

final moodTagRepositoryProvider = Provider<MoodTagRepository>(
  (ref) => MoodTagRepository(database: ref.watch(appDatabaseProvider)),
);
