import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../application/tile_geometry.dart';

/// Draws the falling tiles.
///
/// Shares the visualizer's vocabulary on purpose — the same accent hue shift,
/// the same glow-then-fill order, the same rounded bars — because the user
/// asked for "a clickable version of the visualizer", so the two should read
/// as the same object in different modes.
class RhythmTilePainter extends CustomPainter {
  RhythmTilePainter({
    required this.tiles,
    required this.nowMs,
    required this.travelMs,
    required this.laneCount,
    required this.color,
    required this.hitLineFraction,
    this.flashes = const {},
    super.repaint,
  });

  final List<GameTile> tiles;
  final double nowMs;
  final double travelMs;
  final int laneCount;
  final Color color;

  /// Where the hit line sits as a fraction of the board height.
  final double hitLineFraction;

  /// Lane -> game-clock time of the flash, for tap feedback.
  final Map<int, double> flashes;

  /// The visualizer's two-tone partner: hue +42°, a little lighter.
  Color get _accent {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + 42) % 360)
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || laneCount <= 0) return;

    final laneWidth = size.width / laneCount;
    final hitLineY = size.height * hitLineFraction;

    _paintLanes(canvas, size, laneWidth);
    _paintFlashes(canvas, size, laneWidth);
    _paintTiles(canvas, size, laneWidth, hitLineY);
    _paintHitLine(canvas, size, hitLineY);
  }

  void _paintLanes(Canvas canvas, Size size, double laneWidth) {
    final divider = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1.5;
    for (var lane = 1; lane < laneCount; lane++) {
      final x = lane * laneWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), divider);
    }
  }

  void _paintFlashes(Canvas canvas, Size size, double laneWidth) {
    const flashMs = 220.0;
    flashes.forEach((lane, at) {
      final age = nowMs - at;
      if (age < 0 || age > flashMs) return;
      final strength = 1 - age / flashMs;
      canvas.drawRect(
        Rect.fromLTWH(lane * laneWidth, 0, laneWidth, size.height),
        Paint()..color = _accent.withValues(alpha: 0.14 * strength),
      );
    });
  }

  void _paintTiles(
    Canvas canvas,
    Size size,
    double laneWidth,
    double hitLineY,
  ) {
    final inset = laneWidth * 0.12;

    for (final tile in tiles) {
      if (tile.lane < 0 || tile.lane >= laneCount) continue;

      final head = TileGeometry.headY(
        nowMs: nowMs,
        hitMs: tile.hitMs,
        travelMs: travelMs,
        hitLineY: hitLineY,
      );
      if (!head.isFinite) continue;

      final length = TileGeometry.lengthPx(
        sustain: tile.sustain,
        travelMs: travelMs,
        hitLineY: hitLineY,
      );
      // The tile hangs above its head: the head is the edge that meets the
      // hit line, so the body trails behind it.
      final top = head - length;
      if (top > size.height || head < 0) continue;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          tile.lane * laneWidth + inset,
          top,
          laneWidth - inset * 2,
          length,
        ),
        const Radius.circular(12),
      );

      final level = tile.level.isFinite ? tile.level.clamp(0.0, 1.0) : 0.0;
      final body = Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, top + length), [
          Color.lerp(color, _accent, level * 0.8) ?? color,
          color.withValues(alpha: 0.82),
        ]);

      // Glow only for the strong hits. A blur per tile per frame is the most
      // expensive thing on this screen, and a quiet tile does not need one.
      if (tile.strength > 0.45) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = _accent.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawRRect(rect, body);
    }
  }

  void _paintHitLine(Canvas canvas, Size size, double hitLineY) {
    canvas.drawLine(
      Offset(0, hitLineY),
      Offset(size.width, hitLineY),
      Paint()
        ..color = _accent.withValues(alpha: 0.85)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant RhythmTilePainter oldDelegate) {
    // Driven by a Listenable, so this only matters when the widget itself is
    // rebuilt with new configuration.
    return oldDelegate.color != color ||
        oldDelegate.laneCount != laneCount ||
        oldDelegate.travelMs != travelMs ||
        oldDelegate.hitLineFraction != hitLineFraction;
  }
}
