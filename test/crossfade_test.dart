import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/core/services/audio_player_service.dart';

void main() {
  group('effectiveCrossfadeFor', () {
    // Regression: the ramp used to be skipped outright when a track was no
    // longer than the configured crossfade. Since nothing else advances the
    // queue while crossfade is on, playback stopped dead on the short track
    // instead of moving to the next one.
    const configured = Duration(seconds: 15);

    Duration fadeFor(Duration trackLength) =>
        effectiveCrossfadeFor(configured, trackLength);

    test('uses the configured fade on comfortably long tracks', () {
      expect(fadeFor(const Duration(minutes: 4)), configured);
      expect(fadeFor(const Duration(seconds: 46)), configured);
    });

    test('caps the fade at a third of a short track', () {
      expect(fadeFor(const Duration(seconds: 30)), const Duration(seconds: 10));
      expect(fadeFor(const Duration(seconds: 15)), const Duration(seconds: 5));
      expect(fadeFor(const Duration(seconds: 6)), const Duration(seconds: 2));
    });

    test('always leaves room to play before fading', () {
      // The trigger fires at `duration - fade`, so a fade equal to the whole
      // track would start it at zero and never let the track be heard.
      for (final seconds in [1, 2, 5, 10, 15, 20, 30, 45, 60, 300]) {
        final length = Duration(seconds: seconds);
        final fade = fadeFor(length);
        expect(
          fade,
          lessThan(length),
          reason: '${seconds}s track must keep some solo playing time',
        );
        expect(fade, greaterThanOrEqualTo(Duration.zero));
      }
    });

    test('leaves the incoming track time of its own before it fades out', () {
      // The incoming track plays throughout the ramp, so it becomes active
      // already `fade` in. Capping at a third guarantees it still has more
      // than that left, otherwise it would fade straight back out and the
      // queue would drain far faster than real time.
      for (final seconds in [6, 12, 15, 20, 30, 45, 90]) {
        final length = Duration(seconds: seconds);
        final fade = fadeFor(length);
        expect(
          fade * 2,
          lessThanOrEqualTo(length),
          reason: '${seconds}s track would re-trigger immediately',
        );
      }
    });

    test('degenerate durations do not produce a negative fade', () {
      expect(fadeFor(Duration.zero), Duration.zero);
      expect(fadeFor(const Duration(seconds: -5)), Duration.zero);
    });

    test('a fade shorter than the track is left untouched', () {
      expect(
        effectiveCrossfadeFor(
          const Duration(seconds: 2),
          const Duration(minutes: 3),
        ),
        const Duration(seconds: 2),
      );
    });
  });

  group('crossfadeBetween', () {
    const configured = Duration(seconds: 15);

    test('a long pair gets the configured overlap', () {
      expect(
        crossfadeBetween(
          configured,
          const Duration(minutes: 4),
          const Duration(minutes: 3),
        ),
        configured,
      );
    });

    test('a short incoming track shortens the overlap', () {
      // The bug this exists for: a long track fading into a short one for the
      // full 15s hands the short track over already past its own ramp point,
      // so it immediately fades out again into the track after — which plays
      // as though the short track were skipped.
      final fade = crossfadeBetween(
        configured,
        const Duration(minutes: 4),
        const Duration(seconds: 20),
      );
      expect(fade, const Duration(microseconds: 20000000 ~/ 3));
    });

    test('the overlap always leaves the incoming track more than it takes', () {
      for (final nextSeconds in [10, 20, 30, 45, 60, 120]) {
        final next = Duration(seconds: nextSeconds);
        final fade = crossfadeBetween(
          configured,
          const Duration(minutes: 5),
          next,
        );
        expect(
          fade * 2,
          lessThan(next),
          reason: 'a \${nextSeconds}s track must not be consumed by the fade',
        );
      }
    });

    test('whichever track is shorter decides', () {
      final shortOutgoing = crossfadeBetween(
        configured,
        const Duration(seconds: 21),
        const Duration(minutes: 4),
      );
      final shortIncoming = crossfadeBetween(
        configured,
        const Duration(minutes: 4),
        const Duration(seconds: 21),
      );
      expect(shortOutgoing, shortIncoming);
    });

    test('an unknown incoming duration falls back to the outgoing cap', () {
      // Unknown is not the same as short — a missing duration must not
      // collapse the crossfade to nothing.
      expect(
        crossfadeBetween(configured, const Duration(minutes: 4), Duration.zero),
        configured,
      );
    });
  });

  group('shouldAdvanceOnCompletion', () {
    test('the active player finishing advances the queue', () {
      expect(
        shouldAdvanceOnCompletion(
          crossfadeEnabled: true,
          rampInProgress: false,
          fromActivePlayer: true,
        ),
        isTrue,
      );
    });

    test('the faded-out player finishing does not', () {
      // The regression this guards: the outgoing player reaches its end just
      // after the swap has already moved the queue on, so acting on it
      // advances a second time and lands on the track *after* the one that
      // just faded in.
      expect(
        shouldAdvanceOnCompletion(
          crossfadeEnabled: true,
          rampInProgress: false,
          fromActivePlayer: false,
        ),
        isFalse,
      );
    });

    test('nothing advances while a ramp is still running', () {
      expect(
        shouldAdvanceOnCompletion(
          crossfadeEnabled: true,
          rampInProgress: true,
          fromActivePlayer: true,
        ),
        isFalse,
      );
    });

    test('the gapless engine drives its own queue', () {
      expect(
        shouldAdvanceOnCompletion(
          crossfadeEnabled: false,
          rampInProgress: false,
          fromActivePlayer: true,
        ),
        isFalse,
      );
    });
  });

  group('shouldKeepSkippingAfterError', () {
    test('skips past the first few failures', () {
      expect(shouldKeepSkippingAfterError(1), isTrue);
      expect(shouldKeepSkippingAfterError(4), isTrue);
    });

    test('stops once a run of tracks has failed', () {
      // Without a bound this recursion runs the whole queue as fast as files
      // can fail to load, which looks like a frozen player rather than an
      // error — a folder that moved, or a card pulled out, is enough.
      expect(shouldKeepSkippingAfterError(5), isFalse);
      expect(shouldKeepSkippingAfterError(50), isFalse);
    });

    test('the limit is configurable', () {
      expect(shouldKeepSkippingAfterError(2, limit: 2), isFalse);
      expect(shouldKeepSkippingAfterError(1, limit: 2), isTrue);
    });
  });
}
