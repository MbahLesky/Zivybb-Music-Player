import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../library/application/library_controller.dart';
import '../../vibe_tagging/presentation/vibe_tag_management_screen.dart';
import '../application/settings_controller.dart';
import 'backup_restore_screen.dart';
import 'equalizer_screen.dart';
import 'settings_section_screen.dart';
import 'theme_customization_screen.dart';
import 'visualizer_settings_screen.dart';

/// Central hub for app configuration (Screens.md #11).
///
/// Each section's controls live in their own [ConsumerWidget] below rather
/// than being built inline here. Built inline, they would capture the
/// settings values as they stood when the category was tapped: the pushed
/// route holds that one widget instance, so later changes rebuilt this
/// screen (behind the route) while the visible switches and radios kept
/// showing stale values until the section was reopened.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  description:
                      'Adaptive dark mode, appearance, and theme colors',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsSectionScreen(
                        title: 'Theme',
                        description:
                            'Adjust the app theme, automatic dark mode, and visual accents.',
                        child: _ThemeSection(),
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.play_circle_outline,
                  title: 'Playback',
                  description: 'Crossfade, seek step, and equalizer',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsSectionScreen(
                        title: 'Playback',
                        description:
                            'Adjust how tracks transition and how audio is shaped.',
                        child: _PlaybackSection(),
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.graphic_eq,
                  title: 'Visualizer',
                  description: 'Wave color, style, and where it appears',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VisualizerSettingsScreen(),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.library_music_outlined,
                  title: 'Library',
                  description: 'Vibes, video files, back up your collection',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsSectionScreen(
                        title: 'Library',
                        description:
                            'Manage your music library and keep your data safe.',
                        child: _LibrarySection(),
                      ),
                    ),
                  ),
                ),
                _settingsCategoryCard(
                  context: context,
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Display',
                  description: 'Album art in the mini player and Now Playing',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsSectionScreen(
                        title: 'Display',
                        description:
                            'Choose what shows up while music is playing.',
                        child: _DisplaySection(),
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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

/// Theme options. Watches settings itself so the switch and radios stay
/// live while the section is open — see [SettingsScreen].
class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
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
          onChanged: controller.setManualThemeOverride,
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
          subtitle: const Text('Theme family and app color'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ThemeCustomizationScreen()),
          ),
        ),
      ],
    );
  }
}

/// Playback options. See [SettingsScreen] for why this is its own widget.
class _PlaybackSection extends ConsumerWidget {
  const _PlaybackSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Crossfade'),
          subtitle: const Text('Fade out/in between tracks'),
          value: settings.crossfadeEnabled,
          onChanged: controller.setCrossfadeEnabled,
        ),
        ListTile(
          title: const Text('Crossfade duration'),
          subtitle: _CrossfadeDurationSlider(
            enabled: settings.crossfadeEnabled,
            duration: settings.crossfadeDuration,
            onChangeEnd: controller.setCrossfadeDuration,
          ),
        ),
        const ListTile(
          title: Text('Seek step'),
          subtitle: Text('How far the Now Playing back/forward buttons jump'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            segments: [
              for (final seconds in const [5, 10, 15, 30])
                ButtonSegment(value: seconds, label: Text('${seconds}s')),
            ],
            selected: {settings.seekStep.inSeconds},
            onSelectionChanged: (selection) =>
                controller.setSeekStep(Duration(seconds: selection.first)),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.equalizer),
          title: const Text('Equalizer'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EqualizerScreen())),
        ),
      ],
    );
  }
}

/// Library options. See [SettingsScreen] for why this is its own widget.
class _LibrarySection extends ConsumerWidget {
  const _LibrarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.mood_outlined),
          title: const Text('Manage Vibes'),
          subtitle: const Text('Add, rename, recolor, or remove vibes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VibeTagManagementScreen()),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.movie_outlined),
          title: const Text('Include video files'),
          subtitle: const Text('Play videos as music — audio only, no picture'),
          value: settings.includeVideos,
          onChanged: (enabled) async {
            await controller.setIncludeVideos(enabled);
            // Videos only appear (or disappear) once the library is
            // re-scanned, so do it right away rather than leaving the toggle
            // looking inert.
            await ref.read(libraryControllerProvider.notifier).refresh();
          },
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
    );
  }
}

/// Display options. See [SettingsScreen] for why this is its own widget.
class _DisplaySection extends ConsumerWidget {
  const _DisplaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Album art in mini player'),
          value: settings.showAlbumArtInMiniPlayer,
          onChanged: controller.setShowAlbumArtInMiniPlayer,
        ),
        SwitchListTile(
          title: const Text('Album art in Now Playing'),
          value: settings.showAlbumArtInNowPlaying,
          onChanged: controller.setShowAlbumArtInNowPlaying,
        ),
      ],
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
