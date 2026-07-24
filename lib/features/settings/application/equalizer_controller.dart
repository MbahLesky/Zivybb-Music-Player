import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/equalizer_preset.dart';
import '../../../data/repositories/equalizer_preset_repository.dart';
import 'settings_controller.dart';

final equalizerPresetsStreamProvider = StreamProvider<List<EqualizerPreset>>((
  ref,
) {
  return ref.watch(equalizerPresetRepositoryProvider).watchPresets();
});

/// The band gains for the user's selected preset, or `null` if none is
/// selected (flat / equalizer disabled).
final effectiveEqualizerBandGainsProvider = Provider<List<double>?>((ref) {
  final presetId = ref
      .watch(settingsStreamProvider)
      .value
      ?.currentEqualizerPresetId;
  if (presetId == null) return null;

  final presets = ref.watch(equalizerPresetsStreamProvider).value ?? const [];
  for (final preset in presets) {
    if (preset.id == presetId) return preset.bandGains;
  }
  return null;
});
