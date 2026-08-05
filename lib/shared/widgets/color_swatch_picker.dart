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
  });

  final String selectedHex;
  final ValueChanged<Color> onSelected;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final selected = colorFromHex(selectedHex);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in palette)
          GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: 40,
              height: 40,
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
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}
