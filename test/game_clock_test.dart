import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/features/game/application/game_clock.dart';

void main() {
  group('GameClock', () {
    test('game time only advances while running', () {
      final clock = GameClock()..resume();

      clock.tick(const Duration(milliseconds: 100));
      expect(clock.nowMs, closeTo(100, 1e-6));

      clock.tick(const Duration(milliseconds: 200));
      expect(clock.nowMs, closeTo(200, 1e-6));
    });

    test('a paused game freezes rather than fast-forwarding', () {
      // Regression test: game time used to be read straight off the ticker,
      // which keeps counting while playback is paused. Every tile in flight
      // therefore fell to the hit line, expired and was scored as a miss while
      // the music sat still — pausing a song wrecked the run.
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));

      clock.pause();
      clock.tick(const Duration(seconds: 30));
      clock.tick(const Duration(seconds: 60));

      expect(
        clock.nowMs,
        closeTo(100, 1e-6),
        reason: 'a minute of paused ticker must move the board not at all',
      );
    });

    test('resuming picks up where it left off, however long the pause', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.pause();
      clock.tick(const Duration(seconds: 30));

      clock.resume();
      clock.tick(const Duration(seconds: 30, milliseconds: 16));

      expect(clock.nowMs, closeTo(116, 1e-6));
    });

    test('audio position interpolates between syncs', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 45));

      clock.tick(const Duration(milliseconds: 300));

      expect(
        clock.audioPosition,
        const Duration(seconds: 45, milliseconds: 200),
      );
    });

    test('a paused clock reports the last synced position, unmoved', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 45));
      clock.pause();

      clock.tick(const Duration(seconds: 30));

      expect(clock.audioPosition, const Duration(seconds: 45));
    });

    test('speed scales the interpolation', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(const Duration(seconds: 10), speed: 2);

      clock.tick(const Duration(milliseconds: 200));

      expect(
        clock.audioPosition,
        const Duration(seconds: 10, milliseconds: 200),
        reason: 'at double speed, 100ms of game time is 200ms of track',
      );
    });

    test('a non-positive speed is treated as normal rather than freezing', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 100));
      clock.sync(Duration.zero, speed: 0);

      clock.tick(const Duration(milliseconds: 200));

      expect(clock.audioPosition, const Duration(milliseconds: 100));
    });

    test('reset restarts position tracking without rewinding game time', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 500));
      clock.sync(const Duration(minutes: 2));

      clock.reset();

      expect(
        clock.nowMs,
        closeTo(500, 1e-6),
        reason: 'tiles carry absolute arrivals; rewinding would strand them',
      );
      expect(clock.audioPosition, Duration.zero);
    });

    test('a ticker that jumps backwards is ignored rather than rewinding', () {
      final clock = GameClock()..resume();
      clock.tick(const Duration(milliseconds: 200));
      clock.tick(const Duration(milliseconds: 100));

      expect(clock.nowMs, closeTo(200, 1e-6));
    });
  });
}
