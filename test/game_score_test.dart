import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/repositories/game_score_repository.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

import 'support/fake_scanner.dart';

void main() {
  late AppDatabase database;
  late GameScoreRepository scores;

  setUp(() async {
    database = AppDatabase.connect(NativeDatabase.memory());
    scores = GameScoreRepository(database: database);
  });
  tearDown(() => database.close());

  Future<void> insertSong(String id) {
    return database
        .into(database.songs)
        .insert(
          SongsCompanion.insert(
            id: id,
            filePath: '/music/$id.mp3',
            title: id,
            artist: 'Artist',
            album: 'Album',
            durationMs: 180000,
          ),
        );
  }

  group('GameScoreRepository', () {
    test('a song never played reads as zero, not as missing', () async {
      await insertSong('a');
      final entry = await scores.scoreFor('a');

      expect(entry.highScore, 0);
      expect(entry.maxCombo, 0);
      expect(entry.playCount, 0);
    });

    test('the first run becomes the high score', () async {
      await insertSong('a');

      expect(
        await scores.recordRun('a', score: 1200, maxCombo: 14),
        isTrue,
        reason: 'the first run is always a new best',
      );

      final entry = await scores.scoreFor('a');
      expect(entry.highScore, 1200);
      expect(entry.maxCombo, 14);
      expect(entry.playCount, 1);
    });

    test('a worse run cannot lower the stored best', () async {
      // The whole point of a high score — a bad run must not erase a good one.
      await insertSong('a');
      await scores.recordRun('a', score: 1200, maxCombo: 14);

      expect(await scores.recordRun('a', score: 300, maxCombo: 3), isFalse);

      final entry = await scores.scoreFor('a');
      expect(entry.highScore, 1200);
      expect(entry.maxCombo, 14);
    });

    test('the play count rises on every run, good or bad', () async {
      await insertSong('a');
      await scores.recordRun('a', score: 900, maxCombo: 9);
      await scores.recordRun('a', score: 100, maxCombo: 1);
      await scores.recordRun('a', score: 50, maxCombo: 1);

      expect((await scores.scoreFor('a')).playCount, 3);
    });

    test('a better combo is kept even when the score is worse', () async {
      // The two are independent bests: a long combo that fell apart late is
      // still the longest combo the player has managed.
      await insertSong('a');
      await scores.recordRun('a', score: 1200, maxCombo: 5);
      await scores.recordRun('a', score: 400, maxCombo: 30);

      final entry = await scores.scoreFor('a');
      expect(entry.highScore, 1200);
      expect(entry.maxCombo, 30);
    });

    test('watchScore emits the stored best as it is beaten', () async {
      await insertSong('a');
      final seen = <int>[];
      final subscription = scores
          .watchScore('a')
          .listen((entry) => seen.add(entry.highScore));

      await pumpEventQueue();
      await scores.recordRun('a', score: 500, maxCombo: 5);
      await pumpEventQueue();

      await subscription.cancel();
      expect(seen.first, 0, reason: 'starts from the zero state');
      expect(seen.last, 500);
    });

    test('scores are kept apart per song', () async {
      await insertSong('a');
      await insertSong('b');
      await scores.recordRun('a', score: 1000, maxCombo: 10);

      expect((await scores.scoreFor('b')).highScore, 0);
    });
  });

  group('score cleanup', () {
    test('removing a song from the library clears its score', () async {
      await insertSong('a');
      await scores.recordRun('a', score: 1000, maxCombo: 10);

      await SongRepository(
        database: database,
        scanner: FakeScanner(),
      ).deleteFromLibrary('a');

      expect(await database.select(database.gameScores).get(), isEmpty);
    });

    test('a foreign key stops a score outliving its song', () async {
      // Databases created from v15 on carry the cascade; this proves the
      // constraint really is applied rather than being inert like the
      // `.references()` calls were before customConstraints were added.
      await insertSong('a');
      await scores.recordRun('a', score: 1000, maxCombo: 10);

      await (database.delete(
        database.songs,
      )..where((t) => t.id.equals('a'))).go();

      expect(await database.select(database.gameScores).get(), isEmpty);
    });
  });
}
