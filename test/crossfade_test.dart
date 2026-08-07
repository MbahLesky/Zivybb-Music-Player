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
}
