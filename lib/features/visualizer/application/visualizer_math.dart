import 'dart:math' as math;

/// Per-bar amplitude math for the wave visualizer.
///
/// On Android with the real-time visualizer switched on, bar heights come
/// from the platform capture's actual frequency spectrum and are eased with
/// [smoothTowards]. Everywhere else — the setting off, permission refused,
/// or a non-Android platform — [amplitudesAt] stands in with a deterministic
/// pseudo-random waveform seeded by the track, which animates plausibly but
/// is not an analysis of the audio signal.
class VisualizerMath {
  const VisualizerMath._();

  /// How quickly a bar climbs toward a louder reading (0..1 per frame).
  static const _riseRate = 0.55;

  /// How quickly a bar falls toward a quieter one. Deliberately slower than
  /// [_riseRate]: an instant drop reads as flicker, while a trailing decay
  /// reads as a beat.
  static const _fallRate = 0.18;

  /// Eases [current] toward [target], asymmetrically so peaks snap in and
  /// decay away. Both are clamped to the drawable `[0, 1]` range.
  static double smoothTowards(double current, double target) {
    final clampedTarget = target.clamp(0.0, 1.0);
    final rate = clampedTarget > current ? _riseRate : _fallRate;
    return (current + (clampedTarget - current) * rate).clamp(0.0, 1.0);
  }

  /// Per-bar phase offsets, seeded so the same track always looks the same
  /// and different tracks look different from one another.
  static List<double> barPhasesFor(int seed, int barCount) {
    final random = math.Random(seed);
    return List.generate(barCount, (_) => random.nextDouble() * math.pi * 2);
  }

  /// Simulated bar heights in `[0.15, 1.0]` at [elapsedSeconds], given
  /// [barPhases] from [barPhasesFor].
  static List<double> amplitudesAt({
    required double elapsedSeconds,
    required List<double> barPhases,
  }) {
    return [for (final phase in barPhases) _barValue(elapsedSeconds, phase)];
  }

  static double _barValue(double t, double phase) {
    final slow = math.sin(t * 2.2 + phase);
    final fast = math.sin(t * 5.7 + phase * 1.7);
    final value = (slow * 0.6 + fast * 0.4 + 1) / 2;
    return value.clamp(0.15, 1.0);
  }
}
