import 'dart:math' as math;

import 'beat_detector.dart';

/// Generates a playable beat pattern when there is no real audio feed.
///
/// Deliberately *not* the simulated visualizer waveform run through
/// [BeatDetector]. `VisualizerMath.amplitudesAt` is two sine waves at roughly
/// 0.35 Hz and 0.9 Hz; sampled at the capture's ~20 Hz and differenced, its
/// per-lane flux barely varies, so an adaptive threshold would yield either
/// almost no tiles or a metronomic drone at the sine period — and it would
/// read as a bug in the detector rather than a limit of the input.
///
/// So the fallback lays its own beats on a fixed grid instead. It is honest
/// rather than accurate: it plays properly, and the screen says plainly that
/// the tiles are not this song. Seeded from the track so a given song always
/// produces the same pattern.
class SimulatedBeatSource {
  SimulatedBeatSource({
    required this.seed,
    this.laneCount = 4,
    this.beatPeriod = const Duration(milliseconds: 500),
  });

  /// Track-derived, so a given song always produces the same pattern.
  final int seed;
  final int laneCount;

  /// 120 BPM. A fixed grid is the point — there is no tempo to follow.
  final Duration beatPeriod;

  /// The events whose beat falls in `(from, to]`.
  ///
  /// Keyed off absolute playback position rather than a running counter, so
  /// seeking produces the pattern that belongs to where you landed and the
  /// same window always yields the same events.
  List<BeatEvent> eventsBetween(Duration from, Duration to) {
    if (to <= from) return const [];
    final periodMs = beatPeriod.inMilliseconds;
    if (periodMs <= 0) return const [];

    final firstIndex = (from.inMilliseconds / periodMs).floor() + 1;
    final lastIndex = (to.inMilliseconds / periodMs).floor();
    if (lastIndex < firstIndex) return const [];

    final events = <BeatEvent>[];
    for (var index = firstIndex; index <= lastIndex; index++) {
      final beatMs = index * periodMs;
      if (beatMs <= from.inMilliseconds || beatMs > to.inMilliseconds) {
        continue;
      }
      // Per-beat rather than per-call, so the same beat is identical however
      // the window happens to be sliced.
      final random = math.Random(seed ^ (index * 0x9E3779B1));

      // A quarter of the grid is left empty so the pattern breathes instead
      // of being a metronome.
      if (random.nextDouble() < 0.25) continue;

      final strength = 0.35 + random.nextDouble() * 0.65;
      events.add(
        BeatEvent(
          lane: random.nextInt(laneCount),
          position: Duration(milliseconds: beatMs),
          sustain: Duration(milliseconds: 110 + random.nextInt(320)),
          strength: strength,
          level: (0.35 + strength * 0.6).clamp(0.0, 1.0),
        ),
      );
    }
    return events;
  }
}
