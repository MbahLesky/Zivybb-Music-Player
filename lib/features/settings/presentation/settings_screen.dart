import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../application/settings_controller.dart';
import 'backup_restore_screen.dart';
import 'equalizer_screen.dart';
import 'theme_customization_screen.dart';

/// Central hub for app configuration (Screens.md #11).
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
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Customization'),
            subtitle: const Text('App color and visualizer color'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ThemeCustomizationScreen(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Playback'),
          ),
          SwitchListTile(
            title: const Text('Crossfade'),
            subtitle: const Text('Fade out/in between tracks'),
            value: settings.crossfadeEnabled,
            onChanged: (enabled) => controller.setCrossfadeEnabled(enabled),
          ),
          ListTile(
            title: const Text('Crossfade duration'),
            subtitle: Slider(
              min: 1,
              max: 8,
              divisions: 7,
              label: '${settings.crossfadeDuration.inSeconds}s',
              value: settings.crossfadeDuration.inSeconds
                  .clamp(1, 8)
                  .toDouble(),
              onChanged: settings.crossfadeEnabled
                  ? (value) => controller.setCrossfadeDuration(
                      Duration(seconds: value.round()),
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.equalizer),
            title: const Text('Equalizer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EqualizerScreen())),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Library'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
