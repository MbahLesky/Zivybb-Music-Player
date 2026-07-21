import 'dart:math' as math;

/// Produces simulated per-bar amplitudes for the wave visualizer.
///
/// This app has no cross-platform access to a real-time audio-amplitude or
/// FFT feed from the playback engine (`just_audio` doesn't expose one), so
/// the "beat-reactive" effect is a deterministic pseudo-random waveform
/// seeded by the track — not an analysis of the actual audio signal.
/// Swapping in real amplitude data later (e.g. via a platform Visualizer
/// API) only requires replacing [amplitudesAt].
class VisualizerMath {
  const VisualizerMath._();

  /// Per-bar phase offsets, seeded so the same track always looks the same
  /// and different tracks look different from one another.
  static List<double> barPhasesFor(int seed, int barCount) {
    final random = math.Random(seed);
    return List.generate(barCount, (_) => random.nextDouble() * math.pi * 2);
  }

  /// Bar heights in `[0.15, 1.0]` at [elapsedSeconds], given [barPhases]
  /// from [barPhasesFor].
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
