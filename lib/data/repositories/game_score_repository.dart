import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';

/// A song's stored rhythm-mode best.
class GameScoreEntry {
  const GameScoreEntry({
    required this.songId,
    required this.highScore,
    required this.maxCombo,
    required this.playCount,
  });

  factory GameScoreEntry.fromRow(GameScoreRow row) {
    return GameScoreEntry(
      songId: row.songId,
      highScore: row.highScore,
      maxCombo: row.maxCombo,
      playCount: row.playCount,
    );
  }

  /// The zero state for a song that has never been played in rhythm mode, so
  /// the screen can show "0" rather than an empty slot before the first run.
  const GameScoreEntry.none(this.songId)
    : highScore = 0,
      maxCombo = 0,
      playCount = 0;

  final String songId;
  final int highScore;
  final int maxCombo;
  final int playCount;
}

/// Stores the best rhythm-mode result per song.
class GameScoreRepository {
  GameScoreRepository({required this._database});

  final AppDatabase _database;

  /// Emits [songId]'s stored best, updating as it is beaten. Emits
  /// [GameScoreEntry.none] rather than null for a song never played, so the
  /// UI has no empty state to special-case.
  Stream<GameScoreEntry> watchScore(String songId) {
    final query = _database.select(_database.gameScores)
      ..where((t) => t.songId.equals(songId));
    return query.watchSingleOrNull().map(
      (row) => row == null
          ? GameScoreEntry.none(songId)
          : GameScoreEntry.fromRow(row),
    );
  }

  /// One-off read of [songId]'s stored best.
  Future<GameScoreEntry> scoreFor(String songId) async {
    final query = _database.select(_database.gameScores)
      ..where((t) => t.songId.equals(songId));
    final row = await query.getSingleOrNull();
    return row == null
        ? GameScoreEntry.none(songId)
        : GameScoreEntry.fromRow(row);
  }

  /// Records a finished run.
  ///
  /// The play count always rises, but the score and combo only ever move
  /// upward — a bad run must not wipe out a good one, which is the whole
  /// point of a high score. Returns whether this run set a new best.
  Future<bool> recordRun(
    String songId, {
    required int score,
    required int maxCombo,
  }) async {
    final existing = await scoreFor(songId);
    final isNewBest = score > existing.highScore;

    await _database
        .into(_database.gameScores)
        .insertOnConflictUpdate(
          GameScoresCompanion.insert(
            songId: songId,
            highScore: Value(
              score > existing.highScore ? score : existing.highScore,
            ),
            maxCombo: Value(
              maxCombo > existing.maxCombo ? maxCombo : existing.maxCombo,
            ),
            playCount: Value(existing.playCount + 1),
            updatedAt: DateTime.now(),
          ),
        );

    return isNewBest;
  }

  /// Drops a song's stored best. Used when the song leaves the library.
  Future<void> clear(String songId) {
    return (_database.delete(
      _database.gameScores,
    )..where((t) => t.songId.equals(songId))).go();
  }
}

final gameScoreRepositoryProvider = Provider<GameScoreRepository>((ref) {
  return GameScoreRepository(database: ref.watch(appDatabaseProvider));
});

final gameScoreStreamProvider = StreamProvider.family<GameScoreEntry, String>((
  ref,
  songId,
) {
  return ref.watch(gameScoreRepositoryProvider).watchScore(songId);
});
