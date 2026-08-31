import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/visualizer_math.dart';
import '../application/visualizer_source_controller.dart';
import 'visualizer_painters.dart';

/// Wave visualizer shown on the Now Playing screen and full-screen mode.
///
/// Draws real frequency bands when the user has opted into real-audio
/// visualization and the platform capture is live, and a simulated waveform
/// otherwise — see [VisualizerMath]. Either source is eased towards by
/// [VisualizerMath.smoothTowards] on every frame, so switching between them
/// (or losing the capture mid-track) glides rather than snaps.
///
/// The ticker only runs while a track is playing, and painting is isolated
/// in its own [RepaintBoundary] so it can't force a repaint of the rest of
/// the screen (SRS N-2 / Coding-Standards §11).
class WaveVisualizer extends ConsumerStatefulWidget {
  const WaveVisualizer({
    super.key,
    required this.color,
    this.height,
    this.barCount,
    this.tuning,
    this.progress,
    this.unplayedColor,
  });

  final Color color;

  /// Draws the wave as a progress track: the part before [progress] (0..1) in
  /// [color], the rest in [unplayedColor]. Null draws it in one colour, as
  /// everywhere other than the seek bar.
  ///
  /// Done here rather than in a wrapper because both halves have to be the
  /// same frame of the same wave — two `WaveVisualizer`s side by side would
  /// each run their own ticker and drift apart within seconds.
  final double? progress;

  /// The colour of the not-yet-played part. Defaults to a muted grey.
  final Color? unplayedColor;

  /// Overrides the style's default height, e.g. to fill the full-screen mode.
  final double? height;

  /// Overrides the user's configured bar count — used by callers with a fixed
  /// idea of the density they need, and by the settings preview.
  final int? barCount;

  /// Overrides the user's saved tuning, so the settings screen can preview a
  /// slider mid-drag without writing it to the database first.
  final VisualizerTuning? tuning;

  @override
  ConsumerState<WaveVisualizer> createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends ConsumerState<WaveVisualizer>
    with SingleTickerProviderStateMixin {
  /// How fast the peak caps slide back down, in fraction-of-height a second.
  static const _peakFallPerSecond = 0.55;

  /// How fast the rolling loudness reference follows the music, per second.
  /// Slow enough that a single loud bar doesn't rescale the whole picture,
  /// fast enough to follow a quiet passage into a chorus.
  static const _referenceRisePerSecond = 2.4;
  static const _referenceFallPerSecond = 0.35;

  late final Ticker _ticker = createTicker(_onTick);
  late List<double> _barPhases;
  late List<double> _amplitudes;
  late List<double> _peaks;
  String? _lastSongId;
  Duration _lastElapsed = Duration.zero;

  /// The simulated pulse rate for the current track. Seeded from the song so
  /// a slow track and a driving one don't animate identically.
  double _simulatedTempo = 110;

  /// Last real capture frame, for [VisualizerMath.emphasiseTransients], and
  /// the rolling loudness the levels are normalised against.
  List<double>? _previousBands;
  double _loudnessReference = 0;

  /// The tuning in force: an explicit override, else the saved settings.
  ///
  /// Read straight from the provider rather than held in a field because
  /// [_onTick] needs it every frame and a slider drag can change it between
  /// two of them.
  VisualizerTuning get _tuning =>
      widget.tuning ?? ref.read(visualizerTuningProvider);

  int get _barCount => widget.barCount ?? _tuning.barCount;

  @override
  void initState() {
    super.initState();
    _barPhases = VisualizerMath.barPhasesFor(0, _barCount);
    _amplitudes = List.filled(_barCount, 0.08);
    _peaks = List.filled(_barCount, 0.08);
  }

  void _onTick(Duration elapsed) {
    // Read rather than watch: the capture pushes ~20 times a second and the
    // ticker is already driving a repaint every frame, so watching would add
    // widget rebuilds for nothing.
    final live = ref.read(visualizerSourceControllerProvider);
    final tuning = _tuning;

    final deltaSeconds = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(
      0.0,
      0.1,
    );
    _lastElapsed = elapsed;

    final raw = live == null
        ? VisualizerMath.amplitudesAt(
            elapsedSeconds: elapsed.inMilliseconds / 1000,
            barPhases: _barPhases,
            beatsPerMinute: _simulatedTempo,
          )
        : _readCapture(live, deltaSeconds);

    // Shaped before smoothing, so the eased value chases the contrast the
    // user asked for rather than the contrast being flattened back out by
    // the easing.
    final shaped = VisualizerMath.shape(raw, tuning);
    // Applied last, over everything: it is about the track as a whole, not
    // about any one band, so it scales the finished picture.
    final envelope = _positionEnvelope();
    final target = envelope >= 1
        ? shaped
        : [for (final value in shaped) value * envelope];

    setState(() {
      _amplitudes = VisualizerMath.smoothTowards(
        current: _amplitudes,
        target: target,
        attack: tuning.attack,
        decay: tuning.decay,
      );
      final fall = _peakFallPerSecond * deltaSeconds;
      _peaks = [
        for (var i = 0; i < _amplitudes.length; i++)
          math.max(_amplitudes[i], _peaks[i] - fall),
      ];
    });
  }

  /// Turns one capture frame into bar levels that read as beats.
  ///
  /// Two steps, both of which were missing and both of which are why real
  /// audio still looked barely reactive: rises are emphasised, so a hit
  /// stands out from a sustained note; and the result is scaled against a
  /// rolling loudness, so a quiet master fills the same space as a loud one
  /// and what remains on screen is the track's own dynamics.
  List<double> _readCapture(List<double> bands, double deltaSeconds) {
    final emphasised = VisualizerMath.emphasiseTransients(
      bands,
      _previousBands,
    );
    _previousBands = List.of(bands);

    final peak = VisualizerMath.peakOf(emphasised);
    final rate = peak > _loudnessReference
        ? _referenceRisePerSecond
        : _referenceFallPerSecond;
    _loudnessReference +=
        (peak - _loudnessReference) * (rate * deltaSeconds).clamp(0.0, 1.0);

    return VisualizerMath.normalise(emphasised, _loudnessReference);
  }

  /// The build-in/fade-out multiplier for where the track currently is.
  double _positionEnvelope() {
    final playback = ref.read(playbackControllerProvider);
    return VisualizerMath.positionEnvelope(
      position: playback.position,
      duration: playback.duration,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    final style = ref.watch(visualizerStyleProvider);
    // Watched (not just read in the ticker) so a change to the bar count
    // rebuilds and resizes the arrays below on the next frame.
    ref.watch(visualizerTuningProvider);

    if (_amplitudes.length != _barCount) {
      _amplitudes = List.filled(_barCount, 0.08);
      _peaks = List.filled(_barCount, 0.08);
      _barPhases = VisualizerMath.barPhasesFor(
        song?.id.hashCode ?? 0,
        _barCount,
      );
    }
    if (song?.id != _lastSongId) {
      _lastSongId = song?.id;
      _barPhases = VisualizerMath.barPhasesFor(
        song?.id.hashCode ?? 0,
        _barCount,
      );
      _simulatedTempo = VisualizerMath.simulatedTempoFor(
        song?.id.hashCode ?? 0,
      );
      // The previous track's loudness says nothing about this one, and
      // carrying it over would open the new track badly over- or
      // under-scaled until the reference caught up.
      _previousBands = null;
      _loudnessReference = 0;
    }

    if (playback.isPlaying && !_ticker.isActive) {
      _ticker.start();
    } else if (!playback.isPlaying && _ticker.isActive) {
      _ticker.stop();
    }

    final height = widget.height ?? (style.isRadial ? 200.0 : 110.0);
    final size = Size(double.infinity, height);

    CustomPaint paint(Color color) => CustomPaint(
      size: size,
      painter: visualizerPainterFor(
        style: style,
        amplitudes: _amplitudes,
        peaks: _peaks,
        color: color,
      ),
    );

    final progress = widget.progress;
    if (progress == null) return RepaintBoundary(child: paint(widget.color));

    final scheme = Theme.of(context).colorScheme;
    final circular = style.seekBarShape == VisualizerSeekBarShape.circular;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          paint(
            widget.unplayedColor ??
                scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          ClipPath(
            clipper: circular
                ? _SweepClipper(progress.clamp(0.0, 1.0))
                : _FractionClipper(progress.clamp(0.0, 1.0)),
            child: paint(widget.color),
          ),
        ],
      ),
    );
  }
}

/// Clips to the leftmost [fraction] of the box — the played part of a
/// horizontal track.
class _FractionClipper extends CustomClipper<Path> {
  const _FractionClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) =>
      Path()..addRect(Rect.fromLTWH(0, 0, size.width * fraction, size.height));

  @override
  bool shouldReclip(_FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

/// Clips to a wedge sweeping clockwise from twelve o'clock — the played part
/// of a ring. Matches `RadialPainter`, which also starts at the top.
class _SweepClipper extends CustomClipper<Path> {
  const _SweepClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    if (fraction <= 0) return Path();
    final centre = size.center(Offset.zero);
    // The diagonal, so the wedge covers the corners of a non-square box too.
    final radius = size.longestSide;
    if (fraction >= 1) {
      return Path()..addOval(Rect.fromCircle(center: centre, radius: radius));
    }
    return Path()
      ..moveTo(centre.dx, centre.dy)
      ..arcTo(
        Rect.fromCircle(center: centre, radius: radius),
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_SweepClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
