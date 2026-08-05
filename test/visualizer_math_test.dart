import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/features/visualizer/application/visualizer_math.dart';

void main() {
  group('smoothTowards', () {
    test('rises faster than it falls', () {
      // A beat should snap in and decay out; equal rates read as flicker.
      final rise = VisualizerMath.smoothTowards(0, 1);
      final fall = 1 - VisualizerMath.smoothTowards(1, 0);
      expect(rise, greaterThan(fall));
    });

    test('moves toward the target without overshooting it', () {
      var value = 0.0;
      for (var i = 0; i < 100; i++) {
        value = VisualizerMath.smoothTowards(value, 0.8);
        expect(value, lessThanOrEqualTo(0.8));
      }
      expect(value, closeTo(0.8, 0.01), reason: 'it should converge');
    });

    test('clamps readings outside the drawable range', () {
      // The native capture is normalized, but a bad frame must not paint a
      // bar off the top of the widget or below its baseline.
      expect(VisualizerMath.smoothTowards(0.5, 5), lessThanOrEqualTo(1.0));
      expect(VisualizerMath.smoothTowards(0.5, -5), greaterThanOrEqualTo(0.0));
    });
  });

  group('simulated fallback', () {
    test('stays within the drawable range', () {
      final phases = VisualizerMath.barPhasesFor(42, 24);
      for (var t = 0.0; t < 5; t += 0.1) {
        final amplitudes = VisualizerMath.amplitudesAt(
          elapsedSeconds: t,
          barPhases: phases,
        );
        expect(amplitudes, hasLength(24));
        for (final amplitude in amplitudes) {
          expect(amplitude, inInclusiveRange(0.15, 1.0));
        }
      }
    });

    test('is deterministic per track but differs between tracks', () {
      expect(
        VisualizerMath.barPhasesFor(1, 8),
        VisualizerMath.barPhasesFor(1, 8),
        reason: 'the same track should always look the same',
      );
      expect(
        VisualizerMath.barPhasesFor(1, 8),
        isNot(VisualizerMath.barPhasesFor(2, 8)),
      );
    });
  });
}
