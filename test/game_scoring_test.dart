import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/features/game/application/game_clock.dart';
import 'package:zivybb/features/game/application/game_scoring.dart';

const _sustain = Duration(milliseconds: 200);

void main() {
  group('judgeHit', () {
    test('grades by how far the tap was from the tile', () {
      expect(judgeHit(Duration.zero), HitJudgement.perfect);
      expect(judgeHit(const Duration(milliseconds: 120)), HitJudgement.great);
      expect(judgeHit(const Duration(milliseconds: 220)), HitJudgement.good);
      expect(judgeHit(const Duration(milliseconds: 400)), HitJudgement.miss);
    });

    test('treats early and late the same', () {
      expect(
        judgeHit(const Duration(milliseconds: -120)),
        judgeHit(const Duration(milliseconds: 120)),
      );
    });

    test('the window boundaries are inclusive', () {
      const config = ScoringConfig();
      expect(judgeHit(config.perfectWindow), HitJudgement.perfect);
      expect(
        judgeHit(config.perfectWindow + const Duration(milliseconds: 1)),
        HitJudgement.great,
      );
      expect(judgeHit(config.goodWindow), HitJudgement.good);
      expect(
        judgeHit(config.goodWindow + const Duration(milliseconds: 1)),
        HitJudgement.miss,
      );
    });
  });

  group('pointsFor', () {
    test('a better judgement is worth more', () {
      int points(HitJudgement judgement) =>
          pointsFor(judgement: judgement, comboBefore: 0, sustain: _sustain);
      expect(
        points(HitJudgement.perfect),
        greaterThan(points(HitJudgement.great)),
      );
      expect(
        points(HitJudgement.great),
        greaterThan(points(HitJudgement.good)),
      );
      expect(points(HitJudgement.miss), 0);
    });

    test('a longer beat is worth more than a short one', () {
      int points(Duration sustain) => pointsFor(
        judgement: HitJudgement.perfect,
        comboBefore: 0,
        sustain: sustain,
      );
      expect(
        points(const Duration(milliseconds: 500)),
        greaterThan(points(const Duration(milliseconds: 100))),
      );
    });

    test('the combo multiplier steps up and then stops', () {
      int points(int combo) => pointsFor(
        judgement: HitJudgement.perfect,
        comboBefore: combo,
        sustain: _sustain,
      );
      expect(points(10), greaterThan(points(0)));
      expect(points(30), greaterThan(points(10)));
      // Capped at 3.5x — 50 and 500 both sit above the cap.
      expect(points(500), points(50));
    });
  });

  group('RunScore', () {
    test('starts empty, with an accuracy of zero rather than NaN', () {
      const run = RunScore();
      expect(run.score, 0);
      expect(run.judged, 0);
      expect(run.accuracy, 0);
    });

    test('a hit adds points and extends the combo', () {
      final run = const RunScore().applyHit(HitJudgement.perfect, _sustain);
      expect(run.score, greaterThan(0));
      expect(run.combo, 1);
      expect(run.bestCombo, 1);
      expect(run.perfects, 1);
    });

    test('a miss breaks the combo without taking points away', () {
      var run = const RunScore();
      for (var i = 0; i < 5; i++) {
        run = run.applyHit(HitJudgement.perfect, _sustain);
      }
      final before = run.score;
      run = run.applyMiss();

      expect(run.combo, 0);
      expect(run.score, before, reason: 'a miss must never be a penalty');
      expect(run.bestCombo, 5, reason: 'the best combo is a high-water mark');
      expect(run.misses, 1);
    });

    test('a stray tap breaks the combo and scores nothing', () {
      // Load-bearing: without this, mashing every lane continuously would be
      // the optimal strategy and the score would mean nothing.
      var run = const RunScore();
      for (var i = 0; i < 4; i++) {
        run = run.applyHit(HitJudgement.great, _sustain);
      }
      final before = run.score;
      run = run.applyStray();

      expect(run.combo, 0);
      expect(run.score, before);
      expect(run.strays, 1);
      expect(run.judged, 4, reason: 'a stray is not a judged tile');
    });

    test('applying a miss judgement routes through applyMiss', () {
      final run = const RunScore()
          .applyHit(HitJudgement.perfect, _sustain)
          .applyHit(HitJudgement.miss, _sustain);
      expect(run.combo, 0);
      expect(run.misses, 1);
    });

    test('accuracy counts hits against everything judged', () {
      var run = const RunScore();
      run = run.applyHit(HitJudgement.perfect, _sustain);
      run = run.applyHit(HitJudgement.good, _sustain);
      run = run.applyMiss();
      run = run.applyMiss();

      expect(run.accuracy, 0.5);
    });

    test('the score never goes negative, whatever the sequence', () {
      var run = const RunScore();
      for (var i = 0; i < 50; i++) {
        run = i.isEven ? run.applyMiss() : run.applyStray();
      }
      expect(run.score, 0);
    });
  });

  group('GameClock', () {
    test('interpolates position between playback updates', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 10));
      clock.tick(const Duration(milliseconds: 200));

      expect(clock.audioPosition, const Duration(milliseconds: 10100));
    });

    test('honours the playback speed', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 10), speed: 2.0);
      clock.tick(const Duration(milliseconds: 200));

      expect(clock.audioPosition, const Duration(milliseconds: 10200));
    });

    test('does not advance while paused', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 5));
      clock.pause();
      clock.tick(const Duration(seconds: 30));

      expect(clock.audioPosition, const Duration(seconds: 5));
    });

    test('resuming does not jump by the length of the pause', () {
      // Otherwise every pause would dump a wall of missed tiles on resume.
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 5));
      clock.pause();
      clock.tick(const Duration(seconds: 30));
      clock.resume();
      clock.tick(const Duration(seconds: 30, milliseconds: 100));

      expect(clock.audioPosition, const Duration(milliseconds: 5100));
    });

    test('game time is monotonic across a sync', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 500));
      final before = clock.nowMs;
      clock.sync(Duration.zero);
      clock.tick(const Duration(milliseconds: 520));

      expect(clock.nowMs, greaterThan(before));
    });
  });
}
