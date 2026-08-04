import 'package:flutter/material.dart';

/// The Zivybb brand mark, drawn rather than loaded from an asset so it stays
/// crisp at any size and can be recoloured to match the active theme.
///
/// One unbroken stroke read two ways: the top bar and the long descending
/// diagonal spell a **Z**, while that diagonal and the kicked-up tail meet in
/// a point that reads as a **V**. The geometry mirrors
/// `assets/images/zivybb_logo.svg` — change one and change the other, plus
/// `tools/zivybb_logo.py`, which rasterizes the launcher icons from the same
/// numbers.
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

class _ZivybbLogoPainter extends CustomPainter {
  const _ZivybbLogoPainter({required this.colors});

  final List<Color> colors;

  /// Design-space coordinates, on the same 512x512 canvas as the SVG.
  static const _designCanvas = 512.0;
  static const _designStrokeWidth = 62.0;
  static const _points = [
    Offset(116.9, 164.5),
    Offset(350.6, 131.6),
    Offset(230.4, 382.8),
    Offset(385.9, 282.2),
  ];
  static const _gradientStart = Offset(100, 110);
  static const _gradientEnd = Offset(400, 400);
  static const _gradientStops = [0.0, 0.45, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _designCanvas;
    Offset toLocal(Offset design) => design * scale;

    final path = Path()
      ..moveTo(toLocal(_points.first).dx, toLocal(_points.first).dy);
    for (final point in _points.skip(1)) {
      path.lineTo(toLocal(point).dx, toLocal(point).dy);
    }

    // Evenly spaced stops unless the caller supplied exactly three colours,
    // in which case the brand's off-centre midpoint is preserved.
    final stops = colors.length == _gradientStops.length
        ? _gradientStops
        : [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)];

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _designStrokeWidth * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(colors: colors, stops: stops).createShader(
          Rect.fromPoints(toLocal(_gradientStart), toLocal(_gradientEnd)),
        ),
    );
  }

  @override
  bool shouldRepaint(_ZivybbLogoPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
