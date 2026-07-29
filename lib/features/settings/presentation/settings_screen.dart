import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../mood_tagging/presentation/mood_tag_management_screen.dart';
import '../application/settings_controller.dart';
import 'backup_restore_screen.dart';
import 'equalizer_screen.dart';
import 'settings_section_screen.dart';
import 'theme_customization_screen.dart';

/// Central hub for app configuration (Screens.md #11).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Settings')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerLow,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  'Fine-tune the look and feel of your listening experience.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  description: 'Adaptive dark mode, appearance, and theme colors',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsSectionScreen(
                        title: 'Theme',
                        description: 'Adjust the app theme, automatic dark mode, and visual accents.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 8),
                            Text(
                              'Appearance',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.palette_outlined),
                              title: const Text('Theme Customization'),
                              subtitle: const Text('App color, visualizer color, and style'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ThemeCustomizationScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.play_circle_outline,
                  title: 'Playback',
                  description: 'Crossfade behavior, duration, and equalizer',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsSectionScreen(
                        title: 'Playback',
                        description: 'Adjust how tracks transition and how audio is shaped.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: const Text('Crossfade'),
                              subtitle: const Text('Fade out/in between tracks'),
                              value: settings.crossfadeEnabled,
                              onChanged: (enabled) => controller.setCrossfadeEnabled(enabled),
                            ),
                            ListTile(
                              title: const Text('Crossfade duration'),
                              subtitle: _CrossfadeDurationSlider(
                                enabled: settings.crossfadeEnabled,
                                duration: settings.crossfadeDuration,
                                onChangeEnd: controller.setCrossfadeDuration,
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.equalizer),
                              title: const Text('Equalizer'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EqualizerScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.library_music_outlined,
                  title: 'Library',
                  description: 'Manage moods, back up your collection',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsSectionScreen(
                        title: 'Library',
                        description: 'Manage your music library and keep your data safe.',
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.mood_outlined),
                              title: const Text('Manage Moods'),
                              subtitle: const Text('Add, rename, recolor, or remove mood tags'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MoodTagManagementScreen(),
                                ),
                              ),
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
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Display',
                  description: 'Album art and visualizer in the mini player and Now Playing',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsSectionScreen(
                        title: 'Display',
                        description: 'Choose what shows up while music is playing.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mini player',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SwitchListTile(
                              title: const Text('Show album art'),
                              value: settings.showAlbumArtInMiniPlayer,
                              onChanged: (enabled) =>
                                  controller.setShowAlbumArtInMiniPlayer(enabled),
                            ),
                            SwitchListTile(
                              title: const Text('Show visualizer behind mini player'),
                              value: settings.showVisualizerInMiniPlayer,
                              onChanged: (enabled) =>
                                  controller.setShowVisualizerInMiniPlayer(enabled),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Now Playing',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SwitchListTile(
                              title: const Text('Show album art'),
                              value: settings.showAlbumArtInNowPlaying,
                              onChanged: (enabled) =>
                                  controller.setShowAlbumArtInNowPlaying(enabled),
                            ),
                            SwitchListTile(
                              title: const Text('Show visualizer'),
                              value: settings.showVisualizerInNowPlaying,
                              onChanged: (enabled) =>
                                  controller.setShowVisualizerInNowPlaying(enabled),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A crossfade-duration slider that tracks its own drag position locally.
///
/// Driving `value` straight from the persisted setting made the thumb feel
/// laggy/unresponsive: every pixel of drag wrote to the database and had to
/// wait for that write to round-trip back through `settingsStreamProvider`
/// before the thumb could move. Now the thumb follows the drag instantly and
/// only persists once, in [onChangeEnd].
class _CrossfadeDurationSlider extends StatefulWidget {
  const _CrossfadeDurationSlider({
    required this.enabled,
    required this.duration,
    required this.onChangeEnd,
  });

  final bool enabled;
  final Duration duration;
  final ValueChanged<Duration> onChangeEnd;

  @override
  State<_CrossfadeDurationSlider> createState() =>
      _CrossfadeDurationSliderState();
}

class _CrossfadeDurationSliderState extends State<_CrossfadeDurationSlider> {
  double? _dragSeconds;

  @override
  Widget build(BuildContext context) {
    final seconds =
        _dragSeconds ?? widget.duration.inSeconds.clamp(1, 15).toDouble();
    return Slider(
      min: 1,
      max: 15,
      divisions: 14,
      label: '${seconds.round()}s',
      value: seconds,
      onChanged: widget.enabled
          ? (value) => setState(() => _dragSeconds = value)
          : null,
      onChangeEnd: widget.enabled
          ? (value) {
              widget.onChangeEnd(Duration(seconds: value.round()));
              setState(() => _dragSeconds = null);
            }
          : null,
    );
  }
}
