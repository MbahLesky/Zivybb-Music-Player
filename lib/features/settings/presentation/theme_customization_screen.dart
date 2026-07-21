import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_palette.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../application/settings_controller.dart';

/// Choose the app's color theme and the wave visualizer's color, with a
/// live preview (Screens.md #12).
class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Customization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'App theme color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ColorSwatchGrid(
            selectedHex: settings.themeSeedColorHex,
            onSelected: controller.setThemeSeedColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Visualizer color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ColorSwatchGrid(
            selectedHex: settings.visualizerColorHex,
            onSelected: controller.setVisualizerColor,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: colorFromHex(settings.visualizerColorHex),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Live preview — changes apply immediately.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatchGrid extends StatelessWidget {
  const _ColorSwatchGrid({required this.selectedHex, required this.onSelected});

  final String selectedHex;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = colorFromHex(selectedHex);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in themePalette)
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
