import 'package:flutter/material.dart';

/// The Zivybb brand mark.
///
/// Renders `assets/images/zivybb_logo.png` — the same authored artwork
/// `tool/generate_icons.dart` cuts the launcher icons and splash foreground
/// from — so every surface showing the logo shows the identical mark. It used
/// to be drawn from Bezier geometry in this file, which meant the in-app logo
/// and the launcher icon could (and did) drift apart whenever one was
/// redrawn.
///
/// The mark is a bright gradient "Z" on transparency, which disappears into
/// any background close to its own colours — and the app bar it usually sits
/// in is a theme-coloured gradient. So it is drawn on a plate of the current
/// theme's [ColorScheme.surface] (light on the light theme, dark on the dark
/// one) outlined in the theme's primary colour, which keeps the mark legible
/// whatever the seed colour behind it happens to be.
class ZivybbLogo extends StatelessWidget {
  const ZivybbLogo({super.key, this.size = 96, this.semanticLabel = 'Zivybb'});

  final double size;

  final String? semanticLabel;

  /// Where the artwork lives, shared with anything else that needs it.
  static const assetPath = 'assets/images/zivybb_logo.png';

  @override
  Widget build(BuildContext context) {
    // Read from the ambient theme, not a bare `ThemeData()`: that default
    // constructor builds a throwaway light scheme, so the plate stayed white
    // and the border stayed default-blue no matter which theme was active.
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.primary, width: 2),
        // Scaled with the mark so the plate stays a rounded square at both
        // the 28px app-bar size and the 96px default.
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        semanticLabel: semanticLabel,
        // The source is 512px square; app-bar sizes are a heavy downscale, so
        // the better filter is worth it.
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
