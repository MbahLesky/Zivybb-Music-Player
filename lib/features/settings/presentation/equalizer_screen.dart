import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/equalizer_controller.dart';
import '../application/settings_controller.dart';

/// Select and apply an equalizer preset (Screens.md #10, SRS F-1.6).
///
/// Backed by a real Android equalizer (`just_audio`'s `AndroidEqualizer`)
/// where available; unavailable on other platforms, in which case
/// selecting a preset is a no-op until the app runs on Android.
class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(equalizerPresetsStreamProvider);
    final currentPresetId = ref
        .watch(settingsStreamProvider)
        .value
        ?.currentEqualizerPresetId;
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Equalizer')),
      body: presets.when(
        data: (items) => ListView(
          children: [
            RadioGroup<String?>(
              groupValue: currentPresetId,
              onChanged: controller.setEqualizerPreset,
              child: Column(
                children: [
                  const RadioListTile<String?>(title: Text('Off'), value: null),
                  for (final preset in items)
                    RadioListTile<String?>(
                      title: Text(preset.name),
                      value: preset.id,
                    ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load presets: $error')),
      ),
    );
  }
}
