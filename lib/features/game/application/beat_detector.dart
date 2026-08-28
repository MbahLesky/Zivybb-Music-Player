import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../data/models/app_settings.dart';

/// One capture frame, stamped with the playback position it describes.
///
/// The native visualizer sends bare level lists with no timestamp of their
/// own, so whoever receives a frame has to stamp it — see `GameClock`.
@immutable
class BandFrame {
  const BandFrame({required this.bands, required this.position});

  /// Raw band levels in 0..1, low frequencies first.
  final List<double> bands;
  final Duration position;
}

/// A finished onset: one tile to spawn.
@immutable
class BeatEvent {
  const BeatEvent({
    required this.lane,
    required this.position,
    required this.sustain,
    required this.strength,
    required this.level,
  });

  /// Which lane the beat belongs in — low frequencies on the left.
  final int lane;

  /// Playback position of the frame the onset *started* on, not the frame it
  /// was emitted on. Tile timing keys off this so the wait for the sustain to
  /// finish doesn't shift the beat.
  final Duration position;

  /// How long the energy held. Drives tile length.
  final Duration sustain;

  /// How far above its threshold the onset was, 0..1. Drives scoring weight
  /// and glow.
  final double strength;

  /// The shaped level at the onset, 0..1 — the same `VisualizerMath.shape`
  /// the bars use, so tile brightness obeys the user's visualizer tuning.
  final double level;
}

/// Gameplay tuning derived from the user's visualizer settings, so the game
/// reacts the way their bars already do rather than carrying a second set of
/// knobs (the user's "properties should be based on the visualizer").
@immutable
class BeatDetectorConfig {
  const BeatDetectorConfig({
    this.laneBandEdges = defaultLaneEdges,
    this.thresholdMultiplier = 2.0,
    this.minimumFlux = 0.012,
    this.fluxWindow = 40,
    this.laneRefractory = const Duration(milliseconds: 150),
    this.globalRefractory = const Duration(milliseconds: 70),
    this.minSustain = const Duration(milliseconds: 90),
    this.maxSustain = const Duration(milliseconds: 500),
    this.sustainDropRatio = 0.55,
    this.maxLanesPerFrame = 2,
    this.resyncJump = const Duration(seconds: 1),
    this.tuning = const VisualizerTuning(),
  });

  /// Half-open `[start, end)` band ranges per lane over the 32 log-spaced
  /// bands: sub/kick, low-mid, mid, highs. Log spacing means the low lanes
  /// cover few Hz each and the high lanes many, which is what makes lane 0
  /// track the kick rather than everything at once.
  static const defaultLaneEdges = [0, 6, 14, 23, 32];

  final List<int> laneBandEdges;
  final double thresholdMultiplier;
  final double minimumFlux;
  final int fluxWindow;
  final Duration laneRefractory;
  final Duration globalRefractory;
  final Duration minSustain;
  final Duration maxSustain;
  final double sustainDropRatio;
  final int maxLanesPerFrame;
  final Duration resyncJump;
  final VisualizerTuning tuning;

  int get laneCount => laneBandEdges.length - 1;

  /// Reads the gameplay knobs out of the user's visualizer tuning.
  ///
  /// Sensitivity lowers the bar an onset has to clear, so a more sensitive
  /// visualizer gives a busier board. Responsiveness shortens the refractory
  /// and the memory window, so a twitchy visualizer gives a twitchier game.
  /// Contrast and floor are not used here — they shape [BeatEvent.level],
  /// which is appearance only.
  factory BeatDetectorConfig.from(VisualizerTuning tuning) {
    final safe = tuning.clamped();
    final responsiveness = safe.responsiveness;
    return BeatDetectorConfig(
      thresholdMultiplier: (2.0 / safe.sensitivity).clamp(0.9, 3.2),
      fluxWindow: _lerpInt(61, 25, responsiveness),
      laneRefractory: Duration(
        milliseconds: _lerpInt(200, 110, responsiveness),
      ),
      tuning: safe,
    );
  }

  static int _lerpInt(int from, int to, double t) =>
      (from + (to - from) * t).round();
}

/// Finds beat onsets in a stream of band frames.
///
/// Spectral flux, not level: a beat is a *rise* in energy, so a loud sustained
/// pad produces no tiles while a quiet drum loop does. The threshold is a
/// rolling median rather than a mean, because the onsets themselves sit in the
/// window and would drag a mean up behind them.
///
/// Onsets are emitted when they *end*, not when they start, because a tile's
/// length is its beat's sustain and that is only knowable afterwards. The
/// event still carries the start position, so the delay does not move the
/// beat. Emitting on start would mean a tile that grows while it falls.
class BeatDetector {
  BeatDetector({BeatDetectorConfig config = const BeatDetectorConfig()})
    : _config = config,
      _lanes = List.generate(
        config.laneCount,
        (_) => _LaneState(),
        growable: false,
      );

  final BeatDetectorConfig _config;
  final List<_LaneState> _lanes;

  List<double>? _previousBands;
  Duration? _previousPosition;
  Duration? _lastGlobalOnset;

  BeatDetectorConfig get config => _config;

  /// Clears all history. Called on a track change or a seek.
  void reset() {
    for (final lane in _lanes) {
      lane.reset();
    }
    _previousBands = null;
    _previousPosition = null;
    _lastGlobalOnset = null;
  }

  /// Feeds one frame and returns any onsets that finished on it — usually
  /// none, at most [BeatDetectorConfig.maxLanesPerFrame].
  List<BeatEvent> add(BandFrame frame) {
    final bands = _sanitize(frame.bands);
    if (bands.isEmpty) return const [];

    // A seek, a track change, or a crossfade handing over to the other audio
    // session all break continuity. Without this the jump reads as a huge
    // flux across every lane and sprays phantom tiles.
    final previousPosition = _previousPosition;
    if (previousPosition != null &&
        (frame.position < previousPosition ||
            frame.position - previousPosition > _config.resyncJump)) {
      reset();
      _previousBands = bands;
      _previousPosition = frame.position;
      return const [];
    }

    final previous = _previousBands;
    _previousBands = bands;
    _previousPosition = frame.position;
    if (previous == null) return const [];

    final finished = _closeSustains(bands, frame.position);
    _openOnsets(bands, previous, frame.position);
    return finished;
  }

  /// Closes any onset whose energy has decayed or which has hit the cap, and
  /// returns them as events.
  List<BeatEvent> _closeSustains(List<double> bands, Duration position) {
    final events = <BeatEvent>[];
    for (var lane = 0; lane < _lanes.length; lane++) {
      final open = _lanes[lane].open;
      if (open == null) continue;

      final level = _laneEnergy(bands, lane);
      if (level > open.peakLevel) open.peakLevel = level;

      final held = position - open.startedAt;
      final decayed = level < open.peakLevel * _config.sustainDropRatio;
      if (!decayed && held < _config.maxSustain) continue;

      _lanes[lane].open = null;
      events.add(
        BeatEvent(
          lane: lane,
          position: open.startedAt,
          sustain: held < _config.minSustain
              ? _config.minSustain
              : (held > _config.maxSustain ? _config.maxSustain : held),
          strength: open.strength,
          level: open.shapedLevel,
        ),
      );
    }
    return events;
  }

  /// Opens onsets on lanes whose flux clears the adaptive threshold.
  void _openOnsets(
    List<double> bands,
    List<double> previous,
    Duration position,
  ) {
    final candidates = <_Candidate>[];

    for (var lane = 0; lane < _lanes.length; lane++) {
      final state = _lanes[lane];
      final flux = _laneFlux(bands, previous, lane);
      final threshold = math.max(
        _config.minimumFlux,
        state.medianFlux() * _config.thresholdMultiplier,
      );
      state.pushFlux(flux, _config.fluxWindow);

      if (state.open != null) continue;
      if (flux <= threshold) continue;

      final lastOnset = state.lastOnsetAt;
      if (lastOnset != null && position - lastOnset < _config.laneRefractory) {
        continue;
      }
      candidates.add(_Candidate(lane, flux - threshold, flux / threshold));
    }
    if (candidates.isEmpty) return;

    // One kick drum smears energy across every band. Without a global gate it
    // would light all four lanes at once, which is unplayable and doesn't
    // reflect the music either.
    final lastGlobal = _lastGlobalOnset;
    if (lastGlobal != null &&
        position - lastGlobal < _config.globalRefractory) {
      return;
    }

    candidates.sort((a, b) => b.margin.compareTo(a.margin));
    final taken = candidates.take(_config.maxLanesPerFrame);
    for (final candidate in taken) {
      final level = _laneEnergy(bands, candidate.lane);
      _lanes[candidate.lane]
        ..lastOnsetAt = position
        ..open = _OpenOnset(
          startedAt: position,
          peakLevel: level,
          strength: ((candidate.ratio - 1) / 3).clamp(0.0, 1.0),
          shapedLevel: shapeLevel(level, _config.tuning),
        );
    }
    _lastGlobalOnset = position;
  }

  double _laneEnergy(List<double> bands, int lane) {
    final start = _config.laneBandEdges[lane];
    final end = math.min(_config.laneBandEdges[lane + 1], bands.length);
    if (end <= start) return 0;
    var total = 0.0;
    for (var i = start; i < end; i++) {
      total += bands[i];
    }
    return total / (end - start);
  }

  double _laneFlux(List<double> bands, List<double> previous, int lane) {
    final start = _config.laneBandEdges[lane];
    final end = math.min(_config.laneBandEdges[lane + 1], bands.length);
    if (end <= start) return 0;
    var total = 0.0;
    for (var i = start; i < end; i++) {
      // Half-wave rectified: only rises count. A fall is the tail of the
      // previous beat, not a new one.
      final rise = bands[i] - (i < previous.length ? previous[i] : 0);
      if (rise > 0) total += rise;
    }
    return total / (end - start);
  }

  /// Coerces a frame into the shape the lane maths expects, so a short,
  /// empty, or hostile frame degrades instead of throwing.
  List<double> _sanitize(List<double> bands) {
    if (bands.isEmpty) return const [];
    final wanted = _config.laneBandEdges.last;
    return List<double>.generate(wanted, (i) {
      final value = i < bands.length ? bands[i] : 0.0;
      if (!value.isFinite) return 0.0;
      return value.clamp(0.0, 1.0);
    }, growable: false);
  }
}

/// Applies the user's contrast/sensitivity/floor to a single level.
///
/// Mirrors `VisualizerMath.shape` for one value — that method takes a whole
/// list, and building a one-element list per onset just to reach it would be
/// wasteful in the detector's hot path.
double shapeLevel(double value, VisualizerTuning tuning) {
  final clamped = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
  final curved = math.pow(clamped, tuning.contrast).toDouble();
  final gained = (curved * tuning.sensitivity).clamp(0.0, 1.0);
  return (tuning.floor + (1 - tuning.floor) * gained).clamp(0.0, 1.0);
}

class _Candidate {
  const _Candidate(this.lane, this.margin, this.ratio);
  final int lane;
  final double margin;
  final double ratio;
}

class _OpenOnset {
  _OpenOnset({
    required this.startedAt,
    required this.peakLevel,
    required this.strength,
    required this.shapedLevel,
  });
  final Duration startedAt;
  double peakLevel;
  final double strength;
  final double shapedLevel;
}

class _LaneState {
  final List<double> _flux = [];
  Duration? lastOnsetAt;
  _OpenOnset? open;

  void pushFlux(double value, int window) {
    _flux.add(value);
    while (_flux.length > window) {
      _flux.removeAt(0);
    }
  }

  double medianFlux() {
    if (_flux.isEmpty) return 0;
    final sorted = List<double>.of(_flux)..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }

  void reset() {
    _flux.clear();
    lastOnsetAt = null;
    open = null;
  }
}
