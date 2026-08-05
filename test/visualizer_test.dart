import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/data/models/app_settings.dart';
import 'package:zivybb/features/visualizer/application/visualizer_math.dart';
import 'package:zivybb/features/visualizer/presentation/visualizer_painters.dart';

void main() {
  group('VisualizerMath.smoothTowards', () {
    List<double> smooth(List<double> from, List<double> to) =>
        VisualizerMath.smoothTowards(
          current: from,
          target: to,
          attack: 0.5,
          decay: 0.1,
        );

    test('moves towards the target without overshooting it', () {
      final result = smooth([0.0, 1.0], [1.0, 0.0]);
      expect(result[0], greaterThan(0.0));
      expect(result[0], lessThan(1.0));
      expect(result[1], lessThan(1.0));
      expect(result[1], greaterThan(0.0));
    });

    test('rises faster than it falls', () {
      final rise = smooth([0.0], [1.0]).single;
      final fall = 1.0 - smooth([1.0], [0.0]).single;
      expect(
        rise,
        greaterThan(fall),
        reason: 'attack should outpace decay so transients snap',
      );
    });

    test('keeps the current length when the target is a different size', () {
      final result = VisualizerMath.smoothTowards(
        current: List.filled(40, 0.0),
        target: List.filled(32, 1.0),
        attack: 1,
        decay: 1,
      );
      expect(result, hasLength(40));
      expect(result.every((value) => value == 1.0), isTrue);
    });

    test('resamples a smaller target across the full width', () {
      // A ramp resampled onto more bars should stay monotonic rather than
      // stepping or clustering at one end.
      final result = VisualizerMath.smoothTowards(
        current: List.filled(9, 0.0),
        target: [0.0, 0.5, 1.0],
        attack: 1,
        decay: 1,
      );
      for (var i = 1; i < result.length; i++) {
        expect(result[i], greaterThanOrEqualTo(result[i - 1]));
      }
      expect(result.first, closeTo(0.0, 1e-9));
      expect(result.last, closeTo(1.0, 1e-9));
    });

    test('stays clamped to 0..1', () {
      final result = VisualizerMath.smoothTowards(
        current: [0.5],
        target: [5.0],
        attack: 1,
        decay: 1,
      );
      expect(result.single, lessThanOrEqualTo(1.0));
    });

    test('an empty target leaves the current values alone', () {
      expect(smooth([0.3, 0.7], []), [0.3, 0.7]);
    });
  });

  group('VisualizerMath simulated waveform', () {
    test('is deterministic for a given seed', () {
      expect(
        VisualizerMath.barPhasesFor(42, 8),
        VisualizerMath.barPhasesFor(42, 8),
      );
    });

    test('differs between seeds', () {
      expect(
        VisualizerMath.barPhasesFor(1, 8),
        isNot(VisualizerMath.barPhasesFor(2, 8)),
      );
    });

    test('stays within the drawable range', () {
      final phases = VisualizerMath.barPhasesFor(7, 16);
      for (var t = 0.0; t < 5; t += 0.25) {
        final values = VisualizerMath.amplitudesAt(
          elapsedSeconds: t,
          barPhases: phases,
        );
        expect(values, hasLength(16));
        for (final value in values) {
          expect(value, inInclusiveRange(0.15, 1.0));
        }
      }
    });
  });

  group('visualizerPainterFor', () {
    final amplitudes = [for (var i = 0; i < 16; i++) i / 15];
    final peaks = [for (var i = 0; i < 16; i++) (i / 15).clamp(0.0, 1.0)];

    test('returns a painter for every style', () {
      for (final style in VisualizerStyle.values) {
        expect(
          visualizerPainterFor(
            style: style,
            amplitudes: amplitudes,
            peaks: peaks,
            color: const Color(0xFF673AB7),
          ),
          isNotNull,
          reason: style.name,
        );
      }
    });

    test('every style paints without throwing, including at zero level', () {
      for (final style in VisualizerStyle.values) {
        for (final data in [amplitudes, List.filled(16, 0.0)]) {
          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          visualizerPainterFor(
            style: style,
            amplitudes: data,
            peaks: data,
            color: const Color(0xFF673AB7),
          ).paint(canvas, const Size(300, 160));
          recorder.endRecording();
        }
      }
    });

    test('radial styles are flagged so they get a squarer box', () {
      expect(VisualizerStyle.radial.isRadial, isTrue);
      expect(VisualizerStyle.bloom.isRadial, isTrue);
      expect(VisualizerStyle.particles.isRadial, isTrue);
      expect(VisualizerStyle.bars.isRadial, isFalse);
      expect(VisualizerStyle.ribbon.isRadial, isFalse);
    });

    test('every style has a distinct label', () {
      final labels = VisualizerStyle.values.map((s) => s.label).toSet();
      expect(labels, hasLength(VisualizerStyle.values.length));
    });
  });
}
