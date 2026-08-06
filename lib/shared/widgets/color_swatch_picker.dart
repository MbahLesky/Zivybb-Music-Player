import 'package:flutter/material.dart';

import '../../core/theme/theme_palette.dart';
import '../../core/utils/color_hex.dart';

/// A grid of tappable color circles, used for theme/visualizer color choice
/// and vibe colors alike.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
    this.palette = themePalette,
    this.swatchSize = 40,
  });

  final String selectedHex;
  final ValueChanged<Color> onSelected;
  final List<Color> palette;

  /// Diameter of each circle. Shrink it where the picker shares a row with
  /// another one, so the swatches still wrap into a tidy grid.
  final double swatchSize;

  @override
  Widget build(BuildContext context) {
    final selected = colorFromHex(selectedHex);
    final spacing = swatchSize * 0.3;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final color in palette)
          GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: swatchSize,
              height: swatchSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: color.toARGB32() == selected.toARGB32()
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 3,
                      )
                    : null,
              ),
              child: color.toARGB32() == selected.toARGB32()
                  ? Icon(
                      Icons.check,
                      size: swatchSize * 0.55,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
