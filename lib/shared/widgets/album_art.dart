import 'package:flutter/material.dart';

/// Stand-in artwork for a song or playlist.
///
/// Local files often have no embedded art, so rather than showing an identical
/// grey square everywhere, the gradient is derived from [seed] — the same song
/// always gets the same colors, which makes lists easier to scan.
class AlbumArt extends StatelessWidget {
  const AlbumArt({
    required this.seed,
    this.size = 52,
    this.icon = Icons.music_note,
    super.key,
  });

  final String seed;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hue = (seed.hashCode % 360).toDouble();
    final base = HSLColor.fromAHSL(1, hue, 0.4, isDark ? 0.32 : 0.68);
    final accent = base.withLightness(
      (base.lightness + (isDark ? 0.12 : -0.12)).clamp(0.0, 1.0),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.toColor(), accent.toColor()],
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.42,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
