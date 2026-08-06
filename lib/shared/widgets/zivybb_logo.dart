import 'package:flutter/material.dart';

/// The Zivybb brand mark.
///
/// Renders `assets/images/zivybb_logo.png` — the same authored artwork
/// `tool/generate_icons.dart` cuts the launcher icons and splash foreground
/// from — so every surface showing the logo shows the identical mark. It used
/// to be drawn from Bezier geometry in this file, which meant the in-app logo
/// and the launcher icon could (and did) drift apart whenever one was
/// redrawn.
class ZivybbLogo extends StatelessWidget {
  const ZivybbLogo({super.key, this.size = 96, this.semanticLabel = 'Zivybb'});

  final double size;

  final String? semanticLabel;

  /// Where the artwork lives, shared with anything else that needs it.
  static const assetPath = 'assets/images/zivybb_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      semanticLabel: semanticLabel,
      // The source is 512px square; app-bar sizes are a heavy downscale, so
      // the better filter is worth it.
      filterQuality: FilterQuality.medium,
    );
  }
}
