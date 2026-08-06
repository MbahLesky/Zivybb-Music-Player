import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../data/models/app_settings.dart';

/// Builds the painter for [style].
CustomPainter visualizerPainterFor({
  required VisualizerStyle style,
  required List<double> amplitudes,
  required List<double> peaks,
  required Color color,
}) {
  return switch (style) {
    VisualizerStyle.bars => BarsPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.mirror => MirrorPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.radial => RadialPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.bloom => BloomPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.particles => ParticlesPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.line => LinePainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
    VisualizerStyle.ribbon => RibbonPainter(
      amplitudes: amplitudes,
      peaks: peaks,
      color: color,
    ),
  };
}

/// Shared plumbing: the amplitude data plus the palette derived from the
/// user's chosen visualizer colour.
abstract class _VisualizerPainter extends CustomPainter {
  const _VisualizerPainter({
    required this.amplitudes,
    required this.peaks,
    required this.color,
  });

  final List<double> amplitudes;

  /// Slowly-falling maxima, drawn as caps on the bar styles.
  final List<double> peaks;

  final Color color;

  /// The visualizer colour shifted round the hue wheel, giving each style a
  /// two-tone gradient that still reads as the colour the user picked.
  Color get _accent {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + 42) % 360)
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  Shader verticalShader(Size size) => ui.Gradient.linear(
    Offset(0, size.height),
    Offset(0, 0),
    [color.withValues(alpha: 0.75), _accent],
  );

  Shader radialShader(Offset centre, double radius) => ui.Gradient.radial(
    centre,
    radius,
    [_accent, color.withValues(alpha: 0.65)],
  );

  /// A soft copy of [base] for the glow pass drawn underneath each style.
  Paint glowPaint(Paint base, {double sigma = 9}) => Paint()
    ..shader = base.shader
    ..color = base.color.withValues(alpha: 0.5)
    ..style = base.style
    ..strokeWidth = base.strokeWidth
    ..strokeCap = base.strokeCap
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) =>
      oldDelegate.amplitudes != amplitudes ||
      oldDelegate.peaks != peaks ||
      oldDelegate.color != color;
}

/// Classic level meter: rounded bars rising from the baseline, each with a
/// peak cap that falls back more slowly than the bar itself.
class BarsPainter extends _VisualizerPainter {
  const BarsPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / amplitudes.length;
    final barWidth = slot * 0.62;
    final radius = Radius.circular(barWidth / 2);
    final fill = Paint()..shader = verticalShader(size);
    final glow = glowPaint(fill, sigma: 7);
    final capPaint = Paint()..color = _accent.withValues(alpha: 0.9);

    for (var i = 0; i < amplitudes.length; i++) {
      final barHeight = math.max(amplitudes[i] * size.height, barWidth);
      final left = i * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight),
        radius,
      );
      canvas.drawRRect(rect, glow);
      canvas.drawRRect(rect, fill);

      final capY = size.height - peaks[i] * size.height;
      // Only worth drawing once the cap has separated from the bar.
      if (capY < size.height - barHeight - 2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, capY, barWidth, 3),
            const Radius.circular(2),
          ),
          capPaint,
        );
      }
    }
  }
}

/// Bars mirrored about the centre line, so quiet passages collapse to a
/// hairline and loud ones bloom symmetrically outwards.
class MirrorPainter extends _VisualizerPainter {
  const MirrorPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / amplitudes.length;
    final barWidth = slot * 0.62;
    final radius = Radius.circular(barWidth / 2);
    final centreY = size.height / 2;
    final fill = Paint()
      ..shader = ui.Gradient.linear(Offset(0, centreY), Offset(0, 0), [
        color.withValues(alpha: 0.55),
        _accent,
      ]);
    final glow = glowPaint(fill, sigma: 8);

    for (var i = 0; i < amplitudes.length; i++) {
      final half = math.max(amplitudes[i] * centreY, barWidth / 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * slot + (slot - barWidth) / 2,
          centreY - half,
          barWidth,
          half * 2,
        ),
        radius,
      );
      canvas.drawRRect(rect, glow);
      canvas.drawRRect(rect, fill);
    }
  }
}

/// Spokes radiating from a ring, with peak ticks floating beyond them.
class RadialPainter extends _VisualizerPainter {
  const RadialPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final inner = maxRadius * 0.38;
    final span = maxRadius - inner;

    final spoke = Paint()
      ..shader = radialShader(centre, maxRadius)
      ..strokeWidth = math.max(size.shortestSide / amplitudes.length * 0.5, 2)
      ..strokeCap = StrokeCap.round;
    final glow = glowPaint(spoke, sigma: 6);
    final ring = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(centre, inner, ring);

    for (var i = 0; i < amplitudes.length; i++) {
      // Start at the top and go clockwise, so the loudest low frequencies
      // sit where the eye lands first.
      final angle = 2 * math.pi * i / amplitudes.length - math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final start = centre + direction * inner;
      final end = centre + direction * (inner + amplitudes[i] * span);
      canvas.drawLine(start, end, glow);
      canvas.drawLine(start, end, spoke);

      final peakAt = inner + peaks[i] * span;
      if (peakAt > inner + amplitudes[i] * span + 4) {
        canvas.drawCircle(
          centre + direction * peakAt,
          1.6,
          Paint()..color = _accent.withValues(alpha: 0.85),
        );
      }
    }
  }
}

/// A closed blob whose radius follows the spectrum — the whole shape
/// breathes with the track rather than resolving into discrete bars.
class BloomPainter extends _VisualizerPainter {
  const BloomPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final inner = maxRadius * 0.34;
    final span = maxRadius - inner;

    final path = Path();
    // Mirrored across the vertical axis so the closed shape is symmetric;
    // an unmirrored spectrum would leave a seam where the ends met.
    final points = amplitudes.length * 2;
    for (var i = 0; i <= points; i++) {
      final index = i < amplitudes.length
          ? i
          : math.max(points - i - 1, 0).clamp(0, amplitudes.length - 1);
      final angle = 2 * math.pi * i / points - math.pi / 2;
      final radius = inner + amplitudes[index] * span;
      final point = centre + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final fill = Paint()
      ..shader = radialShader(centre, maxRadius)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glowPaint(fill, sigma: 14));
    canvas.drawPath(
      path,
      Paint()
        ..shader = fill.shader
        ..color = color.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

/// Dots orbiting a ring, swelling and brightening with their band.
class ParticlesPainter extends _VisualizerPainter {
  const ParticlesPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final ringRadius = size.shortestSide / 2 * 0.62;
    final maxOffset = size.shortestSide / 2 * 0.3;

    for (var i = 0; i < amplitudes.length; i++) {
      final angle = 2 * math.pi * i / amplitudes.length - math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final position =
          centre + direction * (ringRadius + amplitudes[i] * maxOffset);
      final radius = 1.5 + amplitudes[i] * 7;
      final paint = Paint()
        ..color = Color.lerp(
          color,
          _accent,
          amplitudes[i],
        )!.withValues(alpha: 0.35 + amplitudes[i] * 0.65);
      canvas.drawCircle(position, radius * 2.2, glowPaint(paint, sigma: 6));
      canvas.drawCircle(position, radius, paint);
    }
  }
}

/// A single smoothed curve through the spectrum, filled beneath.
class LinePainter extends _VisualizerPainter {
  const LinePainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = _curvePoints(amplitudes, size);
    final stroke = Path();
    _appendSmoothed(stroke, points);

    final area = Path.from(stroke)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, size.height), [
          _accent.withValues(alpha: 0.45),
          color.withValues(alpha: 0.02),
        ]),
    );

    final line = Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0), [
        color,
        _accent,
      ])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(stroke, glowPaint(line, sigma: 8));
    canvas.drawPath(stroke, line);
  }
}

/// Two mirrored curves enclosing a filled band — a ribbon that pinches in
/// quiet passages and swells in loud ones.
class RibbonPainter extends _VisualizerPainter {
  const RibbonPainter({
    required super.amplitudes,
    required super.peaks,
    required super.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centreY = size.height / 2;
    final upper = <Offset>[];
    final lower = <Offset>[];
    final step = size.width / math.max(amplitudes.length - 1, 1);

    for (var i = 0; i < amplitudes.length; i++) {
      final half = amplitudes[i] * centreY * 0.92;
      upper.add(Offset(i * step, centreY - half));
      lower.add(Offset(i * step, centreY + half));
    }

    final path = Path();
    _appendSmoothed(path, upper);
    _appendSmoothed(path, lower.reversed.toList(), continueFrom: true);
    path.close();

    final fill = Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0), [
        color.withValues(alpha: 0.85),
        _accent.withValues(alpha: 0.85),
      ]);
    canvas.drawPath(path, glowPaint(fill, sigma: 12));
    canvas.drawPath(path, fill);
  }
}

List<Offset> _curvePoints(List<double> amplitudes, Size size) {
  final step = size.width / math.max(amplitudes.length - 1, 1);
  return [
    for (var i = 0; i < amplitudes.length; i++)
      Offset(i * step, size.height - amplitudes[i] * size.height),
  ];
}

/// Appends [points] to [path] as a quadratic spline through their midpoints,
/// which rounds the corners a plain polyline would show at these bar counts.
void _appendSmoothed(
  Path path,
  List<Offset> points, {
  bool continueFrom = false,
}) {
  if (points.isEmpty) return;
  if (continueFrom) {
    path.lineTo(points.first.dx, points.first.dy);
  } else {
    path.moveTo(points.first.dx, points.first.dy);
  }
  for (var i = 1; i < points.length; i++) {
    final previous = points[i - 1];
    final current = points[i];
    final mid = Offset(
      (previous.dx + current.dx) / 2,
      (previous.dy + current.dy) / 2,
    );
    path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
  }
  path.lineTo(points.last.dx, points.last.dy);
}
