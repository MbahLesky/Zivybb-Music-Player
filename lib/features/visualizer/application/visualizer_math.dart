import 'dart:math' as math;

/// Produces the per-bar amplitudes the wave visualizer draws.
///
/// Two sources feed this. When the user has opted into real-audio
/// visualization and the platform capture is running, bands arrive from
/// `VisualizerSourceController`. Otherwise [amplitudesAt] synthesizes a
/// deterministic pseudo-waveform seeded by the track — an animation, not an
/// analysis of the audio. Either way the values reaching the painters are
/// smoothed by [smoothTowards] so the picture never jumps.
class VisualizerMath {
  const VisualizerMath._();

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

  /// Eases [current] towards [target], resampling if their lengths differ.
  ///
  /// Real capture arrives at roughly 20Hz while the visualizer paints at 60,
  /// so drawing raw frames would visibly step. Rising fast and falling slow
  /// (a much larger [attack] than [decay]) is what makes a level meter feel
  /// percussive rather than mushy: transients snap up, then bleed away.
  static List<double> smoothTowards({
    required List<double> current,
    required List<double> target,
    required double attack,
    required double decay,
  }) {
    if (target.isEmpty) return current;
    return [
      for (var i = 0; i < current.length; i++)
        _ease(
          current[i],
          _sampleAt(target, i / math.max(current.length - 1, 1)),
          attack: attack,
          decay: decay,
        ),
    ];
  }

  static double _ease(
    double from,
    double to, {
    required double attack,
    required double decay,
  }) {
    final rate = to > from ? attack : decay;
    return (from + (to - from) * rate).clamp(0.0, 1.0);
  }

  /// Linearly interpolated read of [values] at [position] in `[0, 1]`, so a
  /// 32-band capture can drive any number of bars.
  static double _sampleAt(List<double> values, double position) {
    if (values.length == 1) return values.first;
    final scaled = position.clamp(0.0, 1.0) * (values.length - 1);
    final low = scaled.floor();
    final high = math.min(low + 1, values.length - 1);
    return values[low] + (values[high] - values[low]) * (scaled - low);
  }
}
