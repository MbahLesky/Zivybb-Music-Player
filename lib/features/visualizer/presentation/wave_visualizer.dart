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
  });

  final Color color;

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

  late final Ticker _ticker = createTicker(_onTick);
  late List<double> _barPhases;
  late List<double> _amplitudes;
  late List<double> _peaks;
  String? _lastSongId;
  Duration _lastElapsed = Duration.zero;

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
    final raw =
        live ??
        VisualizerMath.amplitudesAt(
          elapsedSeconds: elapsed.inMilliseconds / 1000,
          barPhases: _barPhases,
        );
    // Shaped before smoothing, so the eased value chases the contrast the
    // user asked for rather than the contrast being flattened back out by
    // the easing.
    final target = VisualizerMath.shape(raw, tuning);

    final deltaSeconds = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(
      0.0,
      0.1,
    );
    _lastElapsed = elapsed;

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
    }

    if (playback.isPlaying && !_ticker.isActive) {
      _ticker.start();
    } else if (!playback.isPlaying && _ticker.isActive) {
      _ticker.stop();
    }

    final height = widget.height ?? (style.isRadial ? 200.0 : 110.0);

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: visualizerPainterFor(
          style: style,
          amplitudes: _amplitudes,
          peaks: _peaks,
          color: widget.color,
        ),
      ),
    );
  }
}
