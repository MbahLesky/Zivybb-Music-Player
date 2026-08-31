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

  group('VisualizerMath beat response', () {
    List<double> at(double t, {double bpm = 120, int bars = 16}) =>
        VisualizerMath.amplitudesAt(
          elapsedSeconds: t,
          barPhases: VisualizerMath.barPhasesFor(7, bars),
          beatsPerMinute: bpm,
        );

    test('the low bars punch on the beat and fall away between beats', () {
      // 120 BPM is a beat every 0.5s, so t=0 is on one and t=0.4 is nearly
      // all the way to the next.
      final onBeat = at(0)[0];
      final between = at(0.4)[0];
      expect(
        onBeat,
        greaterThan(between),
        reason: 'a beat has to be visible as a rise and a fall, not a hum',
      );
    });

    test('a faster tempo pulses more often', () {
      // Count the local maxima of the lowest bar over four seconds.
      int pulses(double bpm) {
        var count = 0;
        var previous = at(0, bpm: bpm)[0];
        var rising = false;
        for (var t = 0.02; t < 4; t += 0.02) {
          final value = at(t, bpm: bpm)[0];
          if (value > previous) {
            rising = true;
          } else if (rising) {
            count++;
            rising = false;
          }
          previous = value;
        }
        return count;
      }

      expect(
        pulses(160),
        greaterThan(pulses(80)),
        reason: 'a glance should say whether a song is slow or driving',
      );
    });

    test('low bars move more than high bars', () {
      double swing(int bar) {
        var low = 1.0;
        var high = 0.0;
        for (var t = 0.0; t < 2; t += 0.02) {
          final value = at(t)[bar];
          if (value < low) low = value;
          if (value > high) high = value;
        }
        return high - low;
      }

      expect(
        swing(0),
        greaterThan(swing(15)),
        reason: 'the kick should read louder than the hats',
      );
    });

    test('a track-seeded tempo is stable and varies between tracks', () {
      expect(
        VisualizerMath.simulatedTempoFor(42),
        VisualizerMath.simulatedTempoFor(42),
      );
      expect(
        VisualizerMath.simulatedTempoFor(1),
        isNot(VisualizerMath.simulatedTempoFor(2)),
      );
      for (final seed in [0, 1, 99, -4, 100000]) {
        final tempo = VisualizerMath.simulatedTempoFor(seed);
        expect(tempo, greaterThanOrEqualTo(78));
        expect(tempo, lessThanOrEqualTo(140));
      }
    });
  });

  group('VisualizerMath.positionEnvelope', () {
    const duration = Duration(minutes: 3);

    test('holds at full through the body of a track', () {
      expect(
        VisualizerMath.positionEnvelope(
          position: const Duration(minutes: 1),
          duration: duration,
        ),
        1.0,
      );
    });

    test('drops away across the last seconds', () {
      final sixOut = VisualizerMath.positionEnvelope(
        position: duration - const Duration(seconds: 6),
        duration: duration,
      );
      final threeOut = VisualizerMath.positionEnvelope(
        position: duration - const Duration(seconds: 3),
        duration: duration,
      );
      final atEnd = VisualizerMath.positionEnvelope(
        position: duration,
        duration: duration,
      );

      expect(sixOut, greaterThan(threeOut));
      expect(threeOut, greaterThan(atEnd));
    });

    test('never falls to nothing', () {
      expect(
        VisualizerMath.positionEnvelope(position: duration, duration: duration),
        greaterThan(0),
        reason: 'the end of a track is a hush, not a blank box',
      );
    });

    test('builds in rather than starting at full', () {
      final start = VisualizerMath.positionEnvelope(
        position: Duration.zero,
        duration: duration,
      );
      final soonAfter = VisualizerMath.positionEnvelope(
        position: const Duration(milliseconds: 800),
        duration: duration,
      );
      expect(soonAfter, greaterThan(start));
    });

    test('stays out of the way when the duration is unknown', () {
      expect(
        VisualizerMath.positionEnvelope(
          position: const Duration(seconds: 5),
          duration: Duration.zero,
        ),
        1.0,
      );
    });
  });

  group('VisualizerMath.emphasiseTransients', () {
    test('a band that jumped is drawn taller than one merely sitting loud', () {
      final result = VisualizerMath.emphasiseTransients([0.6, 0.6], [0.1, 0.6]);
      expect(
        result[0],
        greaterThan(result[1]),
        reason: 'a hit and a sustained note must not look the same',
      );
    });

    test('a falling band is left to the decay easing', () {
      expect(VisualizerMath.emphasiseTransients([0.3], [0.9]).single, 0.3);
    });

    test('passes levels through when there is nothing to compare against', () {
      expect(VisualizerMath.emphasiseTransients([0.4], null), [0.4]);
      expect(VisualizerMath.emphasiseTransients([0.4], [0.1, 0.2]), [0.4]);
    });

    test('stays drawable whatever it is fed', () {
      final result = VisualizerMath.emphasiseTransients(
        [double.nan, 4.0, -2.0],
        [0.0, double.infinity, 0.5],
      );
      for (final value in result) {
        expect(value, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('VisualizerMath.normalise', () {
    test('a quiet passage is scaled up to fill the space', () {
      final result = VisualizerMath.normalise([0.1, 0.2], 0.2);
      expect(result[1], closeTo(1.0, 1e-9));
      expect(result[0], closeTo(0.5, 1e-9));
    });

    test('silence is left silent rather than amplified into noise', () {
      expect(VisualizerMath.normalise([0.01, 0.02], 0.02), [0.01, 0.02]);
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
          // The full range: the visible minimum is the tuning's floor now,
          // so this source must not impose one of its own.
          expect(value, inInclusiveRange(0.0, 1.0));
        }
      }
    });
  });

  group('VisualizerMath.shape', () {
    const flat = VisualizerTuning(contrast: 1, sensitivity: 1, floor: 0);

    test('the neutral tuning passes levels through untouched', () {
      expect(VisualizerMath.shape([0.0, 0.25, 0.5, 1.0], flat), [
        0.0,
        0.25,
        0.5,
        1.0,
      ]);
    });

    test('raising contrast widens the gap between quiet and loud', () {
      const quiet = 0.3;
      const loud = 0.9;
      double gapAt(double contrast) {
        final shaped = VisualizerMath.shape([
          quiet,
          loud,
        ], flat.copyWith(contrast: contrast));
        return shaped[1] - shaped[0];
      }

      expect(
        gapAt(3.0),
        greaterThan(gapAt(1.0)),
        reason: 'this is the whole point of the contrast control',
      );
      expect(
        gapAt(0.5),
        lessThan(gapAt(1.0)),
        reason: 'below 1 should flatten the picture instead',
      );
    });

    test('contrast leaves a full-scale level at full scale', () {
      // Only the quiet end may move: a peak that dropped when contrast was
      // raised would read as the whole visualizer getting quieter.
      for (final contrast in [0.5, 1.0, 2.0, 4.0]) {
        expect(
          VisualizerMath.shape([1.0], flat.copyWith(contrast: contrast)).single,
          closeTo(1.0, 1e-9),
        );
      }
    });

    test('sensitivity scales levels up and clamps at the ceiling', () {
      final boosted = VisualizerMath.shape([
        0.2,
        0.9,
      ], flat.copyWith(sensitivity: 2));
      expect(boosted[0], closeTo(0.4, 1e-9));
      expect(boosted[1], 1.0, reason: 'gain must not overshoot the box');
    });

    test('the floor lifts the whole range rather than clamping it', () {
      final shaped = VisualizerMath.shape([
        0.0,
        0.5,
        1.0,
      ], flat.copyWith(floor: 0.2));
      expect(shaped.first, closeTo(0.2, 1e-9));
      expect(shaped.last, closeTo(1.0, 1e-9));
      // A clamp would have flattened this to the floor; a lift keeps it
      // distinct, which is what preserves the contrast underneath.
      expect(shaped[1], greaterThan(0.2));
      expect(shaped[1], lessThan(1.0));
    });

    test('every result stays drawable, whatever is fed in', () {
      final hostile = [-1.0, 0.0, 0.5, 1.0, 4.0, double.nan, double.infinity];
      for (final preset in VisualizerResponsePreset.values) {
        for (final value in VisualizerMath.shape(hostile, preset.tuning)) {
          expect(value, inInclusiveRange(0.0, 1.0), reason: preset.name);
        }
      }
    });
  });

  group('VisualizerTuning', () {
    test('clamped() pulls every field back into range', () {
      const wild = VisualizerTuning(
        sensitivity: 99,
        contrast: -5,
        floor: 2,
        responsiveness: 7,
        barCount: 5000,
      );
      final safe = wild.clamped();

      expect(safe.sensitivity, VisualizerTuning.sensitivityRange.$2);
      expect(safe.contrast, VisualizerTuning.contrastRange.$1);
      expect(safe.floor, VisualizerTuning.floorRange.$2);
      expect(safe.responsiveness, VisualizerTuning.responsivenessRange.$2);
      expect(safe.barCount, VisualizerTuning.barCountRange.$2);
    });

    test('rises faster than it falls at every responsiveness', () {
      for (final responsiveness in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final tuning = VisualizerTuning(responsiveness: responsiveness);
        expect(
          tuning.attack,
          greaterThan(tuning.decay),
          reason: 'transients must snap up and bleed away, never the reverse',
        );
      }
    });

    test('higher responsiveness chases the signal harder', () {
      const slow = VisualizerTuning(responsiveness: 0.1);
      const fast = VisualizerTuning(responsiveness: 0.9);
      expect(fast.attack, greaterThan(slow.attack));
      expect(fast.decay, greaterThan(slow.decay));
    });

    test('each preset is recognised as itself', () {
      for (final preset in VisualizerResponsePreset.values) {
        expect(preset.tuning.matchingPreset, preset, reason: preset.name);
      }
    });

    test('a hand-tuned value matches no preset', () {
      expect(
        VisualizerResponsePreset.balanced.tuning
            .copyWith(contrast: 2.345)
            .matchingPreset,
        isNull,
      );
    });

    test('the default settings are the balanced preset', () {
      expect(
        const VisualizerTuning(),
        VisualizerResponsePreset.balanced.tuning,
      );
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
