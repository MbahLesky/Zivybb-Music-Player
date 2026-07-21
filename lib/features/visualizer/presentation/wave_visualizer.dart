import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../playback/application/playback_controller.dart';
import '../application/visualizer_math.dart';

/// Beat-reactive wave visualizer shown on the Now Playing screen.
///
/// See [VisualizerMath] for an important caveat: the animation is a
/// simulated waveform seeded by the track, not real audio analysis. The
/// ticker only runs while a track is playing, and painting is isolated in
/// its own [RepaintBoundary] so it can't force a repaint of the rest of the
/// screen (SRS N-2 / Coding-Standards §11).
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

  void _onTick(Duration elapsed) {
    setState(() {
      _amplitudes = VisualizerMath.amplitudesAt(
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

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(double.infinity, 80),
        painter: _WavePainter(amplitudes: _amplitudes, color: widget.color),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.amplitudes, required this.color});

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
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}
