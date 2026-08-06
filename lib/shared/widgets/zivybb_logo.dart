import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// The Zivybb brand mark, drawn rather than loaded from an asset so it stays
/// crisp at any size and can be recoloured to match the active theme.
///
/// A calligraphic ZV monogram: one looping stroke draws the **Z** — along the
/// bottom, up and back over the top, then down across its own path and away
/// into a descending tail — and threads through a second stroke sweeping the
/// **V**, so the two interlace like a ribbon. Each is a brush stroke whose
/// width swells and pinches along its length rather than a uniform line.
///
/// The geometry mirrors `tools/zivybb_logo.py`, which rasterizes the launcher
/// icons and regenerates `assets/images/zivybb_logo.svg` from the same
/// numbers. Change one and change the other.
class ZivybbLogo extends StatelessWidget {
  const ZivybbLogo({super.key, this.size = 96, this.colors});

  final double size;

  /// Overrides the brand gradient, e.g. to tint the mark with the user's
  /// chosen theme colour. Needs at least two entries.
  final List<Color>? colors;

  /// Cyan through violet to pink, matching the launcher icon.
  static const brandColors = [
    Color(0xFF22D3EE),
    Color(0xFF8B5CF6),
    Color(0xFFF43F8E),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ZivybbLogoPainter(colors: colors ?? brandColors),
      ),
    );
  }
}

/// One cubic Bezier of a stroke's centreline.
typedef _Segment = (Offset, Offset, Offset, Offset);

class _ZivybbLogoPainter extends CustomPainter {
  const _ZivybbLogoPainter({required this.colors});

  final List<Color> colors;

  /// Everything below is in the same 512x512 design space as the SVG.
  static const _designCanvas = 512.0;

  static const List<_Segment> _strokeZ = [
    (Offset(106, 216), Offset(160, 242), Offset(232, 248), Offset(290, 234)),
    (Offset(290, 234), Offset(336, 220), Offset(332, 158), Offset(278, 146)),
    (Offset(278, 146), Offset(232, 134), Offset(196, 150), Offset(188, 182)),
    (Offset(188, 182), Offset(182, 218), Offset(204, 252), Offset(230, 278)),
    (Offset(230, 278), Offset(248, 314), Offset(232, 366), Offset(200, 402)),
  ];

  /// The V is split at its turn: offsetting one centreline through a corner
  /// that sharp folds the inner edge over itself and fills in the notch, so
  /// two strokes tapering to a shared point give a clean apex instead.
  static const List<_Segment> _strokeVDown = [
    (Offset(242, 112), Offset(258, 180), Offset(290, 270), Offset(320, 362)),
  ];
  static const List<_Segment> _strokeVUp = [
    (Offset(320, 362), Offset(346, 298), Offset(380, 204), Offset(404, 110)),
  ];

  /// Width along the centreline as (t, width). Swells on the downstrokes and
  /// pinches at turns and ends, the way a brush loaded on entry and lifted on
  /// exit would.
  static const _widthZ = [
    (0.0, 10.0),
    (0.14, 30.0),
    (0.32, 24.0),
    (0.5, 19.0),
    (0.64, 22.0),
    (0.82, 32.0),
    (1.0, 8.0),
  ];
  static const _widthVDown = [
    (0.0, 9.0),
    (0.3, 26.0),
    (0.6, 36.0),
    (0.85, 24.0),
    (1.0, 9.0),
  ];
  static const _widthVUp = [
    (0.0, 9.0),
    (0.25, 22.0),
    (0.5, 20.0),
    (0.8, 12.0),
    (1.0, 7.0),
  ];

  /// The Z's bottom stroke is redrawn last so it passes over the V there,
  /// having passed under it higher up — that alternation is the weave.
  static const _zOverRange = (0.0, 0.21);

  /// Gap punched around a stroke where it crosses in front of another.
  static const _weaveGap = 11.0;

  static const _gradientStart = Offset(105, 110);
  static const _gradientEnd = Offset(405, 400);
  static const _gradientStops = [0.0, 0.45, 1.0];

  static const _samplesPerSegment = 48;

  static Offset _cubic(_Segment seg, double t) {
    final (p0, c1, c2, p3) = seg;
    final u = 1 - t;
    return p0 * (u * u * u) +
        c1 * (3 * u * u * t) +
        c2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }

  static Offset _tangent(_Segment seg, double t) {
    final (p0, c1, c2, p3) = seg;
    final u = 1 - t;
    return (c1 - p0) * (3 * u * u) +
        (c2 - c1) * (6 * u * t) +
        (p3 - c2) * (3 * t * t);
  }

  static double _widthAt(List<(double, double)> profile, double t) {
    if (t <= profile.first.$1) return profile.first.$2;
    for (var i = 0; i < profile.length - 1; i++) {
      final (t0, w0) = profile[i];
      final (t1, w1) = profile[i + 1];
      if (t <= t1) return w0 + (w1 - w0) * (t - t0) / (t1 - t0);
    }
    return profile.last.$2;
  }

  /// Closed path tracing a variable-width stroke: walks the centreline
  /// offsetting by half the local width along the normal to collect one
  /// side, then returns down the other.
  static Path _strokeOutline(
    List<_Segment> segments,
    List<(double, double)> profile, {
    (double, double) tRange = (0.0, 1.0),
    double grow = 0.0,
    required double scale,
  }) {
    final left = <Offset>[];
    final right = <Offset>[];

    for (var index = 0; index < segments.length; index++) {
      for (var step = 0; step <= _samplesPerSegment; step++) {
        final local = step / _samplesPerSegment;
        final t = (index + local) / segments.length;
        if (t < tRange.$1 || t > tRange.$2) continue;

        final point = _cubic(segments[index], local);
        final tangent = _tangent(segments[index], local);
        final length = math.max(tangent.distance, 1e-6);
        // Normal is the tangent rotated a quarter turn.
        final normal = Offset(-tangent.dy / length, tangent.dx / length);
        final half = (_widthAt(profile, t) + grow) / 2;
        left.add((point + normal * half) * scale);
        right.add((point - normal * half) * scale);
      }
    }

    return Path()..addPolygon([...left, ...right.reversed], true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _designCanvas;

    final shader =
        LinearGradient(
          colors: colors,
          stops: colors.length == _gradientStops.length
              ? _gradientStops
              : [
                  for (var i = 0; i < colors.length; i++)
                    i / (colors.length - 1),
                ],
        ).createShader(
          Rect.fromPoints(_gradientStart * scale, _gradientEnd * scale),
        );
    final fill = Paint()..shader = shader;
    final clear = Paint()..blendMode = BlendMode.clear;

    // A layer is needed for BlendMode.clear to punch a genuinely transparent
    // gap rather than a hole straight through to whatever is behind the
    // widget.
    canvas.saveLayer(Offset.zero & size, Paint());

    void drawPiece(
      List<_Segment> segments,
      List<(double, double)> profile, {
      (double, double) tRange = (0.0, 1.0),
      bool knockOut = false,
    }) {
      if (knockOut) {
        canvas.drawPath(
          _strokeOutline(
            segments,
            profile,
            tRange: tRange,
            grow: _weaveGap,
            scale: scale,
          ),
          clear,
        );
      }
      canvas.drawPath(
        _strokeOutline(segments, profile, tRange: tRange, scale: scale),
        fill,
      );
    }

    drawPiece(_strokeZ, _widthZ);
    drawPiece(_strokeVDown, _widthVDown, knockOut: true);
    // The rising half of the V only meets the falling half, at their shared
    // apex; a gap there would bite a notch out of the point.
    drawPiece(_strokeVUp, _widthVUp);
    drawPiece(_strokeZ, _widthZ, tRange: _zOverRange, knockOut: true);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ZivybbLogoPainter oldDelegate) =>
      !listEquals(oldDelegate.colors, colors);
}
