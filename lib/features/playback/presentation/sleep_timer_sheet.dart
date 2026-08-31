import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/sleep_timer_controller.dart';

/// Arms, inspects, or cancels the sleep timer.
class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => const SleepTimerSheet(),
    );
  }

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  late bool _finishCurrentTrack = ref
      .read(sleepTimerControllerProvider)
      .finishCurrentTrack;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(sleepTimerControllerProvider);
    final controller = ref.read(sleepTimerControllerProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: const Text('Sleep timer'),
              subtitle: Text(
                timer.isActive
                    ? 'Pausing in ${_formatRemaining(timer.remaining!)}'
                    : 'Pause playback after a while',
              ),
            ),
            if (timer.isActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel timer'),
                  onPressed: () {
                    controller.cancel();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            SwitchListTile(
              title: const Text('Finish current track'),
              subtitle: const Text(
                'Wait for the song to end instead of cutting it off',
              ),
              value: _finishCurrentTrack,
              onChanged: (value) => setState(() => _finishCurrentTrack = value),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                timer.isActive ? 'Restart with' : 'Pause after',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in sleepTimerPresets)
                    ActionChip(
                      label: Text('${preset.inMinutes} min'),
                      onPressed: () {
                        controller.start(
                          preset,
                          finishCurrentTrack: _finishCurrentTrack,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRemaining(Duration remaining) {
    if (remaining == Duration.zero) return 'when this track ends';
    final minutes = remaining.inMinutes;
    if (minutes >= 1) return '$minutes min';
    return '${remaining.inSeconds} sec';
  }
}
