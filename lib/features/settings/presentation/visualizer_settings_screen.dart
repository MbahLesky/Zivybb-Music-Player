import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../visualizer/application/visualizer_source_controller.dart';
import '../../visualizer/presentation/wave_visualizer.dart';
import '../application/settings_controller.dart';

/// Choose the wave visualizer's color, style, response, and where it appears
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
      bottomNavigationBar: const MiniPlayer(),
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
                      allowCustom: true,
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
              const _ResponseCard(),
              const SizedBox(height: 16),
              const _RealVisualizerCard(),
              const SizedBox(height: 16),
              const _PlacementCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// How hard the visualizer reacts: presets on top, individual sliders below.
///
/// Sliders track their own drag position and only persist on release, for the
/// same reason the crossfade slider does — writing on every pixel of drag
/// makes the thumb wait for a database round trip. The preview above them
/// reads the in-progress value, so the effect of a drag is visible before it
/// is committed.
class _ResponseCard extends ConsumerStatefulWidget {
  const _ResponseCard();

  @override
  ConsumerState<_ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends ConsumerState<_ResponseCard> {
  /// The tuning being dragged, or null when nothing is mid-drag and the saved
  /// value is what's shown.
  VisualizerTuning? _draft;

  bool _advancedOpen = false;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(visualizerTuningProvider);
    final draft = _draft;
    // Once the write has come back through the settings stream the draft has
    // done its job; dropping it hands control back to the saved value, so a
    // change made anywhere else still reaches this card.
    if (draft != null && draft == saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _draft == saved) setState(() => _draft = null);
      });
    }
    final tuning = draft ?? saved;
    final theme = Theme.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    final activePreset = tuning.matchingPreset;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Response', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'How far apart quiet and loud bars look, and how quickly they '
            'chase the music.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // Live preview, so every control below can be judged by looking
          // rather than by guessing what the numbers mean.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: WaveVisualizer(
                color: ref.watch(visualizerColorProvider),
                height: 96,
                tuning: tuning,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const _PreviewHint(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in VisualizerResponsePreset.values)
                ChoiceChip(
                  label: Text(preset.label),
                  tooltip: preset.description,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: activePreset == preset
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  selected: activePreset == preset,
                  selectedColor: theme.colorScheme.primaryContainer,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: activePreset == preset
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                  onSelected: (_) {
                    setState(() => _draft = null);
                    controller.setVisualizerTuning(preset.tuning);
                  },
                ),
            ],
          ),
          if (activePreset == null) ...[
            const SizedBox(height: 8),
            Text(
              'Custom — adjusted from every preset.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Theme(
            // The default divider lines read as a card seam inside a
            // GlassCard, which already has its own edge.
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: _advancedOpen,
              onExpansionChanged: (open) =>
                  setState(() => _advancedOpen = open),
              title: Text('Advanced', style: theme.textTheme.titleSmall),
              children: [
                _TuningSlider(
                  label: 'Sensitivity',
                  help: 'Overall level. Higher pushes every bar up.',
                  value: tuning.sensitivity,
                  range: VisualizerTuning.sensitivityRange,
                  format: (value) => '${value.toStringAsFixed(2)}×',
                  onChanged: (value) => setState(
                    () => _draft = tuning.copyWith(sensitivity: value),
                  ),
                  onChangeEnd: (value) =>
                      _commit(controller, tuning.copyWith(sensitivity: value)),
                ),
                _TuningSlider(
                  label: 'Contrast',
                  help:
                      'The gap between quiet and loud. Higher drops quiet '
                      'bands away so peaks stand out; lower evens them up.',
                  value: tuning.contrast,
                  range: VisualizerTuning.contrastRange,
                  format: (value) => value.toStringAsFixed(2),
                  onChanged: (value) =>
                      setState(() => _draft = tuning.copyWith(contrast: value)),
                  onChangeEnd: (value) =>
                      _commit(controller, tuning.copyWith(contrast: value)),
                ),
                _TuningSlider(
                  label: 'Floor',
                  help:
                      'How tall the bars stay in silence. Zero lets them '
                      'disappear completely.',
                  value: tuning.floor,
                  range: VisualizerTuning.floorRange,
                  format: (value) => value.toStringAsFixed(2),
                  onChanged: (value) =>
                      setState(() => _draft = tuning.copyWith(floor: value)),
                  onChangeEnd: (value) =>
                      _commit(controller, tuning.copyWith(floor: value)),
                ),
                _TuningSlider(
                  label: 'Responsiveness',
                  help:
                      'Smooth and flowing at the low end, twitchy at the top.',
                  value: tuning.responsiveness,
                  range: VisualizerTuning.responsivenessRange,
                  format: (value) => '${(value * 100).round()}%',
                  onChanged: (value) => setState(
                    () => _draft = tuning.copyWith(responsiveness: value),
                  ),
                  onChangeEnd: (value) => _commit(
                    controller,
                    tuning.copyWith(responsiveness: value),
                  ),
                ),
                _TuningSlider(
                  label: 'Bar count',
                  help: 'Fewer, chunkier bars or more, finer ones.',
                  value: tuning.barCount.toDouble(),
                  range: (
                    VisualizerTuning.barCountRange.$1.toDouble(),
                    VisualizerTuning.barCountRange.$2.toDouble(),
                  ),
                  divisions:
                      VisualizerTuning.barCountRange.$2 -
                      VisualizerTuning.barCountRange.$1,
                  format: (value) => '${value.round()}',
                  onChanged: (value) => setState(
                    () => _draft = tuning.copyWith(barCount: value.round()),
                  ),
                  onChangeEnd: (value) => _commit(
                    controller,
                    tuning.copyWith(barCount: value.round()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _commit(SettingsController controller, VisualizerTuning tuning) {
    controller.setVisualizerTuning(tuning);
    // Held until the saved value has actually come back through the settings
    // stream; dropping it immediately would flick the preview back to the old
    // value for the frame or two the write takes.
    setState(() => _draft = tuning);
  }
}

/// Explains why the preview may be sitting still.
class _PreviewHint extends StatelessWidget {
  const _PreviewHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Preview — play something to see it move.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// One labelled slider with its current value and a one-line explanation.
class _TuningSlider extends StatelessWidget {
  const _TuningSlider({
    required this.label,
    required this.help,
    required this.value,
    required this.range,
    required this.format,
    required this.onChanged,
    required this.onChangeEnd,
    this.divisions,
  });

  final String label;
  final String help;
  final double value;
  final (double, double) range;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.labelLarge)),
            Text(
              format(value),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          help,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          min: range.$1,
          max: range.$2,
          divisions: divisions,
          value: value.clamp(range.$1, range.$2),
          label: format(value),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}

/// Where the visualizer is drawn, as one exclusive choice plus the
/// no-artwork fallback.
class _PlacementCard extends ConsumerWidget {
  const _PlacementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where it appears', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'On Now Playing',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          RadioGroup<VisualizerPlacement>(
            groupValue: settings.visualizerPlacement,
            onChanged: (placement) {
              if (placement != null) {
                controller.setVisualizerPlacement(placement);
              }
            },
            child: Column(
              children: [
                for (final placement in VisualizerPlacement.values)
                  RadioListTile<VisualizerPlacement>(
                    contentPadding: EdgeInsets.zero,
                    value: placement,
                    title: Text(placement.label),
                    subtitle: Text(
                      _placementDescription(
                        placement,
                        settings.visualizerStyle,
                      ),
                    ),
                    // Bloom is one closed blob with no direction to read
                    // progress along, so it cannot be a track. Disabled and
                    // explained rather than offered and ignored.
                    enabled:
                        placement != VisualizerPlacement.seekBar ||
                        settings.visualizerStyle.supportsSeekBar,
                  ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Stand in for missing artwork'),
            subtitle: const Text(
              'Songs with no album art get the visualizer where the art '
              'would be, instead of a music-note placeholder.',
            ),
            isThreeLine: true,
            value: settings.visualizerAsArtworkFallback,
            // Moot while the visualizer already replaces the artwork for
            // every song, so it is disabled rather than quietly ineffective.
            onChanged:
                settings.visualizerPlacement ==
                    VisualizerPlacement.replaceArtwork
                ? null
                : controller.setVisualizerAsArtworkFallback,
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Behind the mini player'),
            value: settings.showVisualizerInMiniPlayer,
            onChanged: controller.setShowVisualizerInMiniPlayer,
          ),
        ],
      ),
    );
  }

  /// What the seek-bar option turns into depends on the chosen style, so the
  /// row says which of the three it will be rather than describing a
  /// behaviour the current style doesn't have.
  static String _placementDescription(
    VisualizerPlacement placement,
    VisualizerStyle style,
  ) {
    if (placement != VisualizerPlacement.seekBar) return placement.description;
    return switch (style.seekBarShape) {
      VisualizerSeekBarShape.horizontal =>
        'The wave becomes the progress bar — played in colour, the rest grey',
      VisualizerSeekBarShape.circular =>
        'A ring around the artwork, filling the artwork slot, that scrubs',
      VisualizerSeekBarShape.unsupported =>
        'Not available for ${style.label} — it has no direction to read '
            'progress along',
    };
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
