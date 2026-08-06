import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../visualizer/application/visualizer_source_controller.dart';
import '../application/settings_controller.dart';

/// Choose the wave visualizer's color and style, and where it appears
/// (moved out of Theme Customization so every visualizer option lives in
/// one place).
class VisualizerSettingsScreen extends ConsumerWidget {
  const VisualizerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Visualizer')),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Tune the wave visualizer and choose where it appears.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ColorSwatchPicker(
                      selectedHex: settings.visualizerColorHex,
                      onSelected: controller.setVisualizerColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Style', style: theme.textTheme.titleMedium),
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
              const _RealVisualizerCard(),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where it appears',
                      style: theme.textTheme.titleMedium,
                    ),
                    SwitchListTile(
                      title: const Text('Behind the mini player'),
                      value: settings.showVisualizerInMiniPlayer,
                      onChanged: (enabled) =>
                          controller.setShowVisualizerInMiniPlayer(enabled),
                    ),
                    SwitchListTile(
                      title: const Text('In Now Playing'),
                      value: settings.showVisualizerInNowPlaying,
                      onChanged: (enabled) =>
                          controller.setShowVisualizerInNowPlaying(enabled),
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

/// The opt-in for driving the visualizer from real audio.
///
/// Kept explicit about the permission rather than hiding it behind a bare
/// switch: Android only exposes the audio it is playing through an API it
/// gates behind RECORD_AUDIO, which reads alarmingly on a music player that
/// never touches the microphone.
class _RealVisualizerCard extends ConsumerWidget {
  const _RealVisualizerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final theme = Theme.of(context);
    final isLive = ref.watch(realVisualizerActiveProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('React to real audio'),
            subtitle: const Text(
              'Needs microphone permission — Android only exposes playing '
              'audio through an API behind it. Zivybb never records.',
            ),
            isThreeLine: true,
            value: settings.realVisualizerEnabled,
            onChanged: (enabled) => _toggle(context, ref, enabled),
          ),
          if (settings.realVisualizerEnabled) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isLive ? Icons.graphic_eq : Icons.hourglass_empty,
                  size: 16,
                  color: isLive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isLive
                        ? 'Live — reading the audio now playing.'
                        : 'Waiting for playback. Falls back to the simulated '
                              'waveform if your device refuses the capture.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final applied = await ref
        .read(settingsControllerProvider.notifier)
        .setRealVisualizerEnabled(enabled);

    if (enabled && !applied) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Permission denied, so the visualizer stays simulated.',
          ),
        ),
      );
    }
  }
}
