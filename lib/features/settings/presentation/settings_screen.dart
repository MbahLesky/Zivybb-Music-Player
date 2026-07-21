import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../application/settings_controller.dart';

/// Central hub for app configuration (Screens.md #11).
///
/// Only the adaptive dark mode section is wired up so far — theme/visualizer
/// color customization and backup & restore land in Weeks 3-4.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Adaptive dark mode'),
            subtitle: const Text(
              'Switch between light and dark based on time of day',
            ),
            value: settings.adaptiveDarkModeEnabled,
            onChanged: settings.manualThemeOverride != null
                ? null
                : (enabled) => controller.setAdaptiveDarkModeEnabled(enabled),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Appearance'),
          ),
          RadioGroup<ThemeOverride?>(
            groupValue: settings.manualThemeOverride,
            onChanged: (value) => controller.setManualThemeOverride(value),
            child: const Column(
              children: [
                RadioListTile<ThemeOverride?>(title: Text('Auto'), value: null),
                RadioListTile<ThemeOverride?>(
                  title: Text('Light'),
                  value: ThemeOverride.light,
                ),
                RadioListTile<ThemeOverride?>(
                  title: Text('Dark'),
                  value: ThemeOverride.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
