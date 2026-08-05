import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/audio_capture_controller.dart';
import '../application/visualizer_math.dart';

/// Beat-reactive wave visualizer shown on the Now Playing screen.
///
/// Draws the real frequency spectrum when the real-time visualizer setting
/// is on and the platform capture is running; otherwise it falls back to the
/// simulated waveform in [VisualizerMath], seeded by the track. The ticker
/// only runs while a track is playing, and painting is isolated in its own
/// [RepaintBoundary] so it can't force a repaint of the rest of the screen
/// (SRS N-2 / Coding-Standards §11).
class WaveVisualizer extends ConsumerStatefulWidget {
  const WaveVisualizer({super.key, required this.color});

  final Color color;

  @override
  ConsumerState<WaveVisualizer> createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends ConsumerState<WaveVisualizer>
    with SingleTickerProviderStateMixin {
  static const _barCount = 24;

  late final Ticker _ticker = createTicker(_onTick);
  List<double> _barPhases = VisualizerMath.barPhasesFor(0, _barCount);
  List<double> _amplitudes = List.filled(_barCount, 0.15);
  String? _lastSongId;

  /// The most recent captured spectrum, smoothed. Capture arrives faster
  /// than a frame and is jumpy bar-to-bar, so each new reading is eased
  /// toward rather than snapped to — bars fall more slowly than they rise,
  /// which is what makes a beat read as a beat instead of a flicker.
  List<double>? _capturedAmplitudes;

  void _onCapture(List<double> magnitudes) {
    final previous = _capturedAmplitudes;
    _capturedAmplitudes = [
      for (var i = 0; i < _barCount; i++)
        VisualizerMath.smoothTowards(
          previous == null || i >= previous.length ? 0 : previous[i],
          i < magnitudes.length ? magnitudes[i] : 0,
        ),
    ];
  }

  void _onTick(Duration elapsed) {
    setState(() {
      // Captured data already updates on its own schedule; the ticker just
      // drives repaints so both sources animate through the same path.
      _amplitudes =
          _capturedAmplitudes ??
          VisualizerMath.amplitudesAt(
            elapsedSeconds: elapsed.inMilliseconds / 1000,
            barPhases: _barPhases,
          );
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

    ref.listen(audioMagnitudesProvider, (_, next) {
      final magnitudes = next.value;
      if (magnitudes != null) _onCapture(magnitudes);
    });
    // Capture stops feeding the moment the setting goes off or playback
    // moves to a session it can't read; drop the stale spectrum so the
    // simulated waveform takes over rather than freezing mid-bar.
    if (!ref.watch(audioCaptureBindingProvider)) {
      _capturedAmplitudes = null;
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

    final painter = switch (style) {
      VisualizerStyle.bars => _BarsPainter(
        amplitudes: _amplitudes,
        color: widget.color,
      ),
      VisualizerStyle.radial => _RadialPainter(
        amplitudes: _amplitudes,
        color: widget.color,
      ),
      VisualizerStyle.particles => _ParticlesPainter(
        amplitudes: _amplitudes,
        color: widget.color,
      ),
      VisualizerStyle.line => _LinePainter(
        amplitudes: _amplitudes,
        color: widget.color,
      ),
    };

    final height = switch (style) {
      VisualizerStyle.bars || VisualizerStyle.line => 80.0,
      VisualizerStyle.radial || VisualizerStyle.particles => 160.0,
    };

    return RepaintBoundary(
      child: CustomPaint(size: Size(double.infinity, height), painter: painter),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.amplitudes, required this.color});

  final List<double> amplitudes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final barWidth = size.width / amplitudes.length;

    for (var i = 0; i < amplitudes.length; i++) {
      final barHeight = amplitudes[i] * size.height;
      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.15,
        (size.height - barHeight) / 2,
        barWidth * 0.7,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}

class _RadialPainter extends CustomPainter {
  _RadialPainter({required this.amplitudes, required this.color});

  final List<double> amplitudes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final innerRadius = maxRadius * 0.35;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < amplitudes.length; i++) {
      final angle = 2 * math.pi * i / amplitudes.length;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final length = innerRadius + amplitudes[i] * (maxRadius - innerRadius);
      canvas.drawLine(
        center + direction * innerRadius,
        center + direction * length,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.amplitudes, required this.color});

  final List<double> amplitudes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringRadius = size.shortestSide / 2 * 0.7;
    final paint = Paint();

    for (var i = 0; i < amplitudes.length; i++) {
      final angle = 2 * math.pi * i / amplitudes.length;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * ringRadius;
      final particleRadius = 3 + amplitudes[i] * 10;
      paint.color = color.withValues(alpha: 0.4 + amplitudes[i] * 0.6);
      canvas.drawCircle(position, particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.amplitudes, required this.color});

  final List<double> amplitudes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final divisions = amplitudes.length > 1 ? amplitudes.length - 1 : 1;
    final stepX = size.width / divisions;
    final path = Path();

    for (var i = 0; i < amplitudes.length; i++) {
      final x = i * stepX;
      final y = size.height - amplitudes[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}
