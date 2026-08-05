import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_capture_service.dart';
import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
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
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reacts to', style: theme.textTheme.titleMedium),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Real-time audio'),
                      subtitle: Text(
                        settings.realtimeVisualizerEnabled
                            ? 'Bars follow the actual music'
                            : 'Bars animate to a simulated wave',
                      ),
                      value: settings.realtimeVisualizerEnabled,
                      onChanged: (enabled) =>
                          _setRealtime(context, ref, enabled: enabled),
                    ),
                    if (!settings.realtimeVisualizerEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Android asks for microphone access to read '
                          "playback. Zivybb only reads its own audio — it "
                          'never records you.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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

  /// Turning this on is gated on the permission Android's capture effect
  /// requires: without it the visualizer would silently keep simulating, so
  /// the setting stays off and says why.
  Future<void> _setRealtime(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    if (!enabled) {
      await controller.setRealtimeVisualizerEnabled(false);
      return;
    }

    final granted = await ref
        .read(audioCaptureServiceProvider)
        .requestPermission();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone access is needed to read playback. The visualizer '
              'will keep using its simulated wave.',
            ),
          ),
        );
      }
      return;
    }
    await controller.setRealtimeVisualizerEnabled(true);
  }
}
