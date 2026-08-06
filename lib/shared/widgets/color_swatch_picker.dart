import 'package:flutter/material.dart';

import '../../core/theme/theme_palette.dart';
import '../../core/utils/color_hex.dart';
import 'custom_color_picker.dart';

/// A grid of tappable color circles, used for theme/visualizer color choice
/// and vibe colors alike.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
    this.palette = themePalette,
    this.swatchSize = 40,
    this.allowCustom = false,
  });

  final String selectedHex;
  final ValueChanged<Color> onSelected;
  final List<Color> palette;

  /// Diameter of each circle. Shrink it where the picker shares a row with
  /// another one, so the swatches still wrap into a tidy grid.
  final double swatchSize;

  /// Appends a rainbow swatch that opens the full-spectrum picker, so the
  /// curated palette stays a set of shortcuts rather than the only choice.
  final bool allowCustom;

  @override
  Widget build(BuildContext context) {
    final selected = colorFromHex(selectedHex);
    final spacing = swatchSize * 0.3;
    final isCustom = !palette.any((color) => _sameColor(color, selected));

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final color in palette)
          _Swatch(
            size: swatchSize,
            onTap: () => onSelected(color),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            isSelected: _sameColor(color, selected),
            child: _sameColor(color, selected)
                ? Icon(
                    Icons.check,
                    size: swatchSize * 0.55,
                    color: Colors.white,
                  )
                : null,
          ),
        if (allowCustom)
          _Swatch(
            size: swatchSize,
            tooltip: 'Custom color',
            onTap: () async {
              final picked = await CustomColorPickerDialog.show(
                context,
                initialColor: selected,
              );
              if (picked != null) onSelected(picked);
            },
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: hueWheelStops),
            ),
            isSelected: isCustom,
            // When a custom color is active the wheel carries it as an inner
            // dot, so the swatch shows both what it does and what is chosen.
            child: isCustom
                ? Container(
                    width: swatchSize * 0.5,
                    height: swatchSize * 0.5,
                    decoration: BoxDecoration(
                      color: selected,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )
                : Icon(Icons.add, size: swatchSize * 0.5, color: Colors.white),
          ),
      ],
    );
  }

  /// Alpha is ignored everywhere else in this app's color handling, but
  /// compare on the full ARGB anyway — every palette entry is opaque, so the
  /// two are equivalent and this stays honest about what it checks.
  static bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.size,
    required this.onTap,
    required this.decoration,
    required this.isSelected,
    this.child,
    this.tooltip,
  });

  final double size;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  final bool isSelected;
  final Widget? child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final swatch = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: decoration.copyWith(
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : decoration.border,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
    return tooltip == null ? swatch : Tooltip(message: tooltip!, child: swatch);
  }
}
