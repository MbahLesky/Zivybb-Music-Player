import 'dart:math' as math;

import '../../../data/models/app_settings.dart';

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

  /// A plausible tempo for [seed]'s track, in beats per minute.
  ///
  /// The simulation has no way to know a song's real tempo — nothing short of
  /// reading the audio does — but a *fixed* rate made every track look
  /// identical, which is the thing that made the visualizer read as
  /// decoration rather than as a response to the music. Seeding the pulse
  /// from the track at least means a given song always has its own pace and
  /// two songs differ, in the same spirit as [barPhasesFor].
  static double simulatedTempoFor(int seed) {
    final random = math.Random(seed);
    return 78 + random.nextDouble() * 62;
  }

  /// Simulated bar heights in `[0, 1]` at [elapsedSeconds], given [barPhases]
  /// from [barPhasesFor] and a pulse at [beatsPerMinute].
  ///
  /// Shaped like a drum pattern rather than a pair of sine waves: each beat
  /// snaps up and decays away, low bars hit hardest and slowest (a kick), high
  /// bars flicker at twice the rate and a fraction of the size (hats), and a
  /// slow swell underneath keeps the whole thing from reading as a metronome.
  /// That profile is what lets a glance at the bars say "this is a hard beat"
  /// or "this is a slow song" — which two fixed sines never could.
  static List<double> amplitudesAt({
    required double elapsedSeconds,
    required List<double> barPhases,
    double beatsPerMinute = 110,
  }) {
    final period = 60 / (beatsPerMinute <= 0 ? 110 : beatsPerMinute);
    final beat = _beatEnvelope(elapsedSeconds, period);
    final offBeat = _beatEnvelope(elapsedSeconds + period / 2, period / 2);
    // A bar-length swell, so successive beats aren't carbon copies.
    final swell = 0.5 + 0.5 * math.sin(elapsedSeconds * math.pi / (period * 4));

    final count = barPhases.length;
    return [
      for (var i = 0; i < count; i++)
        _barValue(
          elapsedSeconds: elapsedSeconds,
          phase: barPhases[i],
          position: count == 1 ? 0.0 : i / (count - 1),
          beat: beat,
          offBeat: offBeat,
          swell: swell,
        ),
    ];
  }

  /// One percussive hit per [period]: straight up, then an exponential fall.
  static double _beatEnvelope(double t, double period) {
    if (period <= 0) return 0;
    final into = (t % period) / period;
    return math.exp(-5.5 * into);
  }

  static double _barValue({
    required double elapsedSeconds,
    required double phase,
    required double position,
    required double beat,
    required double offBeat,
    required double swell,
  }) {
    // Low bars carry the kick, high bars the hats, and the crossover is
    // gradual so the picture reads as one instrument rather than two blocks.
    final lowWeight = math.pow(1 - position, 1.6).toDouble();
    final highWeight = math.pow(position, 1.4).toDouble();

    final kick = beat * lowWeight * 0.95;
    final hats = offBeat * highWeight * 0.5;
    // Per-bar wobble, so neighbouring bars in the same register still differ.
    final shimmer =
        (math.sin(elapsedSeconds * 6.3 + phase * 2.2) + 1) / 2 * 0.22;
    final body = swell * (0.18 + 0.22 * (1 - (position - 0.5).abs() * 2));

    final value = kick + hats + shimmer * (0.4 + highWeight) + body;
    // The full range, not a floored one: the visible minimum is
    // `VisualizerTuning.floor`'s job now, and clamping here would put a hard
    // limit on how far the contrast setting could push quiet bands down.
    return value.clamp(0.0, 1.0);
  }

  /// How much of the picture to draw given where the track is, in `[0, 1]`.
  ///
  /// Songs open and close; the bars should too. This builds in over the first
  /// [buildIn] and falls away across the last [fadeOut], which is the "as most
  /// songs end, the bars gradually drop" the visualizer never used to do —
  /// and unlike the pulse it is real information, since the position and the
  /// duration are both known.
  ///
  /// Returns 1 when the duration is unknown, and never falls below [minimum]:
  /// the last second of a track should be a hush, not a blank box.
  static double positionEnvelope({
    required Duration position,
    required Duration duration,
    Duration buildIn = const Duration(milliseconds: 1200),
    Duration fadeOut = const Duration(seconds: 6),
    double minimum = 0.12,
  }) {
    if (duration <= Duration.zero) return 1;
    final elapsed = position.inMilliseconds.clamp(0, duration.inMilliseconds);
    final remaining = duration.inMilliseconds - elapsed;

    var envelope = 1.0;
    if (buildIn > Duration.zero && elapsed < buildIn.inMilliseconds) {
      envelope = elapsed / buildIn.inMilliseconds;
    }
    if (fadeOut > Duration.zero && remaining < fadeOut.inMilliseconds) {
      final out = remaining / fadeOut.inMilliseconds;
      envelope = math.min(envelope, out);
    }
    return (minimum + (1 - minimum) * envelope.clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  /// Adds each band's *rise* to itself, so a band that just jumped is drawn
  /// taller than one merely sitting loud.
  ///
  /// Level alone makes a sustained pad and a snare look the same, which is why
  /// real capture still read as barely beat-reactive. Only rises count — a
  /// fall is already handled by the slow decay in [smoothTowards].
  static List<double> emphasiseTransients(
    List<double> bands,
    List<double>? previous, {
    double amount = 0.85,
  }) {
    if (previous == null || previous.length != bands.length) return bands;
    return [
      for (var i = 0; i < bands.length; i++)
        () {
          final level = bands[i].isFinite ? bands[i].clamp(0.0, 1.0) : 0.0;
          final was = previous[i].isFinite ? previous[i].clamp(0.0, 1.0) : 0.0;
          final rise = level - was;
          return (level + (rise > 0 ? rise * amount : 0)).clamp(0.0, 1.0);
        }(),
    ];
  }

  /// Rescales [bands] against [reference], the loudest level seen lately.
  ///
  /// A quiet recording used to sit as a permanently short row of bars and a
  /// loud one permanently near the ceiling, so the display said more about
  /// mastering than about the music. Normalising against a rolling peak means
  /// both fill the space and what is left on screen is the *shape* of the
  /// track. Left alone when there is nothing loud enough to normalise
  /// against, so silence stays silent rather than being amplified into noise.
  static List<double> normalise(
    List<double> bands,
    double reference, {
    double quietFloor = 0.08,
  }) {
    if (reference <= quietFloor) return bands;
    return [
      for (final band in bands)
        ((band.isFinite ? band : 0.0) / reference).clamp(0.0, 1.0),
    ];
  }

  /// The largest finite value in [values], or 0.
  static double peakOf(List<double> values) {
    var peak = 0.0;
    for (final value in values) {
      if (value.isFinite && value > peak) peak = value;
    }
    return peak;
  }

  /// Reshapes raw levels in `[0, 1]` per the user's [tuning], applied to
  /// either source before smoothing.
  ///
  /// The order matters. Contrast is a gamma curve applied first, on the raw
  /// value: raising a number below 1 to a power above 1 pulls it down, and
  /// pulls it down harder the smaller it already was, so quiet bands collapse
  /// while loud ones barely move — which is what widens the visible gap
  /// between low and high. Sensitivity then scales the whole curve, and only
  /// afterwards is the floor added, as a lift of the entire range rather than
  /// a clamp. Lifting rather than clamping is deliberate: a clamp would flatten
  /// everything below the floor into one indistinguishable line, undoing the
  /// contrast that was just applied.
  static List<double> shape(List<double> raw, VisualizerTuning tuning) {
    return [
      for (final value in raw)
        _shapeOne(value.isFinite ? value.clamp(0.0, 1.0) : 0.0, tuning),
    ];
  }

  static double _shapeOne(double value, VisualizerTuning tuning) {
    final curved = math.pow(value, tuning.contrast).toDouble();
    final gained = (curved * tuning.sensitivity).clamp(0.0, 1.0);
    return (tuning.floor + (1 - tuning.floor) * gained).clamp(0.0, 1.0);
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
