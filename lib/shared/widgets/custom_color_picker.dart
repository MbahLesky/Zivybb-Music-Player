import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/color_hex.dart';

/// Keys on the two drag surfaces. They carry no runtime meaning — the drag
/// areas are bare gradients with no text or icon, so tests would otherwise
/// have nothing to aim at.
const saturationValueFieldKey = Key('color-picker-saturation-value');
const hueSliderKey = Key('color-picker-hue');

/// Hue stops around the full wheel, reused by the slider gradient here and by
/// the "any color" swatch in `ColorSwatchPicker`.
const hueWheelStops = <Color>[
  Color(0xFFFF0000),
  Color(0xFFFFFF00),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFF0000FF),
  Color(0xFFFF00FF),
  Color(0xFFFF0000),
];

/// Full-spectrum color picker: a saturation/brightness field, a hue slider,
/// and a hex box, any one of which drives the other two.
///
/// Written in-house rather than pulled from pub — it is two gradients and a
/// drag handler, and every added dependency is expensive to build here.
///
/// Alpha is deliberately absent: [colorToHex] stores `#RRGGBB` and the whole
/// app assumes its colors are opaque.
class CustomColorPickerDialog extends StatefulWidget {
  const CustomColorPickerDialog({
    super.key,
    required this.initialColor,
    this.title = 'Custom color',
  });

  final Color initialColor;
  final String title;

  /// Returns the chosen color, or null if the user cancelled.
  static Future<Color?> show(
    BuildContext context, {
    required Color initialColor,
    String title = 'Custom color',
  }) {
    return showDialog<Color>(
      context: context,
      builder: (_) => CustomColorPickerDialog(
        initialColor: initialColor,
        title: title,
      ),
    );
  }

  @override
  State<CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  /// HSV, not [Color], is the source of truth so that dragging brightness
  /// down to black and back does not throw the hue away — black has no hue to
  /// recover, so a round trip through [Color] would snap the field to red.
  late HSVColor _hsv = HSVColor.fromColor(widget.initialColor);

  late final _hexController = TextEditingController(
    text: colorToHex(widget.initialColor).substring(1),
  );

  Color get _color => _hsv.toColor();

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  /// Applies a change made by dragging, and pushes it into the hex box.
  void _dragged(HSVColor value) {
    setState(() => _hsv = value);
    final hex = colorToHex(_hsv.toColor()).substring(1);
    _hexController.value = TextEditingValue(
      text: hex,
      selection: TextSelection.collapsed(offset: hex.length),
    );
  }

  /// Applies a change made by typing. Deliberately leaves the field's text
  /// alone — rewriting it mid-edit would fight the cursor.
  void _hexTyped(String text) {
    if (text.length != 6) return;
    final value = int.tryParse(text, radix: 16);
    if (value == null) return;
    setState(() => _hsv = HSVColor.fromColor(Color(0xFF000000 | value)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SaturationValueField(
              hsv: _hsv,
              onChanged: (saturation, value) =>
                  _dragged(_hsv.withSaturation(saturation).withValue(value)),
            ),
            const SizedBox(height: 16),
            _HueSlider(
              hue: _hsv.hue,
              onChanged: (hue) => _dragged(_hsv.withHue(hue)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    decoration: const InputDecoration(
                      prefixText: '#',
                      labelText: 'Hex',
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: _hexTyped,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_color),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

/// The square: saturation left-to-right, brightness top-to-bottom.
class _SaturationValueField extends StatelessWidget {
  const _SaturationValueField({required this.hsv, required this.onChanged});

  final HSVColor hsv;

  /// Reports saturation and brightness together, since one drag sets both.
  final void Function(double saturation, double value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: saturationValueFieldKey,
      height: 170,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          void report(Offset position) {
            onChanged(
              (position.dx / width).clamp(0.0, 1.0),
              1 - (position.dy / height).clamp(0.0, 1.0),
            );
          }

          return GestureDetector(
            onPanDown: (details) => report(details.localPosition),
            onPanUpdate: (details) => report(details.localPosition),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // White → full hue across, then transparent → black down.
                  // Together these are the standard HSV square.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                        ],
                      ),
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                  Positioned(
                    left: hsv.saturation * width - 10,
                    top: (1 - hsv.value) * height - 10,
                    child: const _Thumb(size: 20),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The rainbow bar underneath the square.
class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: hueSliderKey,
      height: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          void report(Offset position) {
            onChanged((position.dx / width).clamp(0.0, 1.0) * 359.99);
          }

          return GestureDetector(
            onPanDown: (details) => report(details.localPosition),
            onPanUpdate: (details) => report(details.localPosition),
            child: Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: hueWheelStops),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: (hue / 360) * width - 12,
                  top: 0,
                  child: const _Thumb(size: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The draggable ring. White with a dark outline so it stays visible over
/// every part of the spectrum, including white and black.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 3, spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}
