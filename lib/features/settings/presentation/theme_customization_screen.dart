import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../application/settings_controller.dart';

/// Choose the app's theme family and color, with a live preview
/// (Screens.md #12). Visualizer options live in their own settings section.
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
      bottomNavigationBar: const MiniPlayer(),
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
              // Only the app color lives here. Everything visualizer-related
              // — its color, style, and the real-audio opt-in — moved to the
              // Visualizer section so all of it sits in one place.
              _ColorPickerCard(
                title: 'App color',
                selectedHex: settings.themeSeedColorHex,
                onSelected: controller.setThemeSeedColor,
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: colorFromHex(settings.themeSeedColorHex),
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

/// The app-colour picker, in a card matching the surrounding sections.
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
            allowCustom: true,
          ),
        ],
      ),
    );
  }
}
