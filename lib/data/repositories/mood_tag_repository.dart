import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/mood_tag.dart';

/// The fixed set of mood/energy presets offered in the Mood Tagging screen
/// (Screens.md #7). Seeded once; auto-generated mood playlists (Week 3)
/// build on top of these.
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

  /// Inserts the built-in presets if the table is empty. Safe to call on
  /// every app start.
  Future<void> ensureSeeded() async {
    final existing = await _database.select(_database.moodTags).get();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.moodTags,
        _defaultMoodTags.map(
          (tag) => MoodTagsCompanion.insert(
            id: tag.id,
            label: tag.label,
            colorHex: tag.colorHex,
          ),
        ),
      );
    });
  }

  Stream<List<MoodTag>> watchMoodTags() {
    return _database
        .select(_database.moodTags)
        .watch()
        .map((rows) => rows.map(MoodTag.fromRow).toList(growable: false));
  }
}

final moodTagRepositoryProvider = Provider<MoodTagRepository>(
  (ref) => MoodTagRepository(database: ref.watch(appDatabaseProvider)),
);
