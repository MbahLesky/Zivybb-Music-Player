import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../application/settings_controller.dart';

/// Choose the app's color theme, the wave visualizer's color and style,
/// with a live preview (Screens.md #12).
class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Theme Customization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'App theme color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ColorSwatchPicker(
            selectedHex: settings.themeSeedColorHex,
            onSelected: controller.setThemeSeedColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Visualizer color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ColorSwatchPicker(
            selectedHex: settings.visualizerColorHex,
            onSelected: controller.setVisualizerColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Visualizer style',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in VisualizerStyle.values)
                ChoiceChip(
                  label: Text(style.label),
                  selected: settings.visualizerStyle == style,
                  onSelected: (_) => controller.setVisualizerStyle(style),
                ),
            ],
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
