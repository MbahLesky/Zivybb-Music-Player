import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/glass_card.dart';
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
    final theme = Theme.of(context);

    final selectedStyle = ref.watch(appThemeStyleProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Theme Customization')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainerLow,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme family',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final style in AppThemeStyle.values)
                          ChoiceChip(
                            label: Text(style.label),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selectedStyle == style
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            selected: selectedStyle == style,
                            selectedColor: theme.colorScheme.primaryContainer,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: selectedStyle == style
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            onSelected: (_) =>
                                controller.setAppThemeStyle(style),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // App and visualizer colors sit side by side so the two can be
              // compared (and clashes spotted) without scrolling between them.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ColorPickerCard(
                        title: 'App color',
                        selectedHex: settings.themeSeedColorHex,
                        onSelected: controller.setThemeSeedColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ColorPickerCard(
                        title: 'Visualizer color',
                        selectedHex: settings.visualizerColorHex,
                        onSelected: controller.setVisualizerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: settings.visualizerStyle == style
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            selected: settings.visualizerStyle == style,
                            selectedColor: theme.colorScheme.primaryContainer,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: settings.visualizerStyle == style
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            onSelected: (_) =>
                                controller.setVisualizerStyle(style),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: colorFromHex(settings.visualizerColorHex),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Live preview — changes apply immediately.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One half of the side-by-side app/visualizer colour pair.
class _ColorPickerCard extends StatelessWidget {
  const _ColorPickerCard({
    required this.title,
    required this.selectedHex,
    required this.onSelected,
  });

  final String title;
  final String selectedHex;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ColorSwatchPicker(
            selectedHex: selectedHex,
            onSelected: onSelected,
            swatchSize: 32,
          ),
        ],
      ),
    );
  }
}
