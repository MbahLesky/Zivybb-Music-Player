import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/equalizer_preset.dart';
import '../../../data/repositories/equalizer_preset_repository.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../application/equalizer_controller.dart';
import '../application/settings_controller.dart';

/// Select a preset or hand-tune the curve band by band (Screens.md #10,
/// SRS F-1.6).
///
/// Backed by a real Android equalizer (`just_audio`'s `AndroidEqualizer`)
/// where available; unavailable on other platforms, in which case the
/// controls are inert until the app runs on Android.
///
/// Moving any slider switches to the Custom preset and rewrites its stored
/// curve, so a tweak starting from a built-in preset keeps that preset
/// intact and lands in Custom instead.
class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  /// Band gains while a slider is being dragged. Held locally so the thumb
  /// tracks the finger instead of waiting for the database write to
  /// round-trip back through the settings stream (same reasoning as the
  /// crossfade duration slider).
  List<double>? _dragGains;

  Future<void> _onBandChanged(int band, double gain, List<double> current) {
    final updated = [...current];
    updated[band] = gain;
    setState(() => _dragGains = updated);
    return ref
        .read(equalizerPresetRepositoryProvider)
        .updateBandGains(customEqualizerPresetId, updated);
  }

  Future<void> _onBandSettled() async {
    // Selecting Custom last means the engine picks up the finished curve in
    // one go, rather than re-reading a half-dragged one.
    await ref
        .read(settingsControllerProvider.notifier)
        .setEqualizerPreset(customEqualizerPresetId);
    if (mounted) setState(() => _dragGains = null);
  }

  Future<void> _reset() async {
    final flat = List<double>.filled(equalizerBandLabels.length, 0);
    setState(() => _dragGains = flat);
    await ref
        .read(equalizerPresetRepositoryProvider)
        .updateBandGains(customEqualizerPresetId, flat);
    await _onBandSettled();
  }

  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(equalizerPresetsStreamProvider);
    final currentPresetId = ref
        .watch(settingsStreamProvider)
        .value
        ?.currentEqualizerPresetId;
    final controller = ref.read(settingsControllerProvider.notifier);

    // The curve the sliders show: mid-drag values, else whatever is active,
    // else flat when the equalizer is off.
    final activeGains =
        _dragGains ??
        ref.watch(effectiveEqualizerBandGainsProvider) ??
        List<double>.filled(equalizerBandLabels.length, 0);
    final isOff = currentPresetId == null;

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: const GradientAppBar(title: Text('Equalizer')),
      body: presets.when(
        data: (items) {
          // Custom is offered by the sliders below, not as a radio row.
          final selectable = items
              .where((preset) => preset.id != customEqualizerPresetId)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bands',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (currentPresetId == customEqualizerPresetId)
                          TextButton(
                            onPressed: _reset,
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _BandSliders(
                      gains: activeGains,
                      dimmed: isOff,
                      onChanged: (band, gain) =>
                          _onBandChanged(band, gain, activeGains),
                      onChangeEnd: _onBandSettled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'Presets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    RadioGroup<String?>(
                      groupValue: currentPresetId,
                      onChanged: controller.setEqualizerPreset,
                      child: Column(
                        children: [
                          const RadioListTile<String?>(
                            title: Text('Off'),
                            value: null,
                          ),
                          for (final preset in selectable)
                            RadioListTile<String?>(
                              title: Text(preset.name),
                              subtitle: Text(_curveSummary(preset)),
                              value: preset.id,
                            ),
                          RadioListTile<String?>(
                            title: const Text('Custom'),
                            subtitle: const Text('Your hand-tuned bands'),
                            value: customEqualizerPresetId,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load presets: $error')),
      ),
    );
  }

  String _curveSummary(EqualizerPreset preset) {
    return [
      for (final (index, gain) in preset.bandGains.indexed)
        if (index < equalizerBandLabels.length && gain != 0)
          '${equalizerBandLabels[index]} '
              '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(0)}',
    ].join('  ·  ').ifEmpty('Flat');
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _BandSliders extends StatelessWidget {
  const _BandSliders({
    required this.gains,
    required this.dimmed,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final List<double> gains;

  /// Greys the sliders out while the equalizer is off — they still work,
  /// and touching one switches to Custom, which turns it on.
  final bool dimmed;
  final void Function(int band, double gain) onChanged;
  final VoidCallback onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Column(
        children: [
          for (final (band, label) in equalizerBandLabels.indexed)
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Slider(
                    min: -equalizerMaxGainDb,
                    max: equalizerMaxGainDb,
                    divisions: (equalizerMaxGainDb * 2).round(),
                    label: '${_signed(_gainAt(band))} dB',
                    value: _gainAt(band),
                    onChanged: (gain) => onChanged(band, gain),
                    onChangeEnd: (_) => onChangeEnd(),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${_signed(_gainAt(band))}dB',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _gainAt(band) == 0
                          ? scheme.onSurfaceVariant
                          : scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Presets are stored against a 5-band curve, but a restored or
  /// hand-edited one could be shorter — treat missing bands as flat rather
  /// than throwing.
  double _gainAt(int band) {
    if (band >= gains.length) return 0;
    return gains[band].clamp(-equalizerMaxGainDb, equalizerMaxGainDb);
  }

  String _signed(double gain) =>
      '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(0)}';
}
