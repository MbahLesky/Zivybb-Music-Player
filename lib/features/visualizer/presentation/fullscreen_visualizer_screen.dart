import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';
import 'wave_visualizer.dart';

/// Distraction-free, full-screen version of the wave visualizer.
///
/// Keeps the screen awake for as long as it's open and hides the system
/// status/navigation bars; tapping anywhere toggles a minimal overlay with
/// track info and transport controls.
class FullScreenVisualizerScreen extends ConsumerStatefulWidget {
  const FullScreenVisualizerScreen({super.key});

  @override
  ConsumerState<FullScreenVisualizerScreen> createState() =>
      _FullScreenVisualizerScreenState();
}

class _FullScreenVisualizerScreenState
    extends ConsumerState<FullScreenVisualizerScreen> {
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _controlsVisible = !_controlsVisible),
          child: Stack(
            children: [
              Positioned.fill(
                child: WaveVisualizer(color: ref.watch(visualizerColorProvider)),
              ),
              AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Exit full screen',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    if (song != null)
                                      Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 32,
                                icon: const Icon(Icons.skip_previous),
                                tooltip: 'Previous',
                                onPressed: () => ref
                                    .read(playbackControllerProvider.notifier)
                                    .previous(),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                iconSize: 48,
                                icon: Icon(
                                  playback.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                ),
                                tooltip: playback.isPlaying ? 'Pause' : 'Play',
                                onPressed: () => ref
                                    .read(playbackControllerProvider.notifier)
                                    .togglePlayPause(),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                iconSize: 32,
                                icon: const Icon(Icons.skip_next),
                                tooltip: 'Next',
                                onPressed: () => ref
                                    .read(playbackControllerProvider.notifier)
                                    .next(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
