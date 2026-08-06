import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/theme/app_gradients.dart';
import '../../../data/models/app_settings.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';
import 'wave_visualizer.dart';

/// Distraction-free, full-screen version of the wave visualizer.
///
/// Keeps the screen awake for as long as it's open and hides the system
/// status/navigation bars; tapping anywhere toggles a minimal overlay with
/// track info and transport controls. Swiping left or right cycles the
/// visualizer style, so trying them out doesn't mean a round trip to
/// Settings. The controls fade themselves out after a few seconds so the
/// visualizer is left unobstructed without the user having to tap.
class FullScreenVisualizerScreen extends ConsumerStatefulWidget {
  const FullScreenVisualizerScreen({super.key});

  @override
  ConsumerState<FullScreenVisualizerScreen> createState() =>
      _FullScreenVisualizerScreenState();
}

class _FullScreenVisualizerScreenState
    extends ConsumerState<FullScreenVisualizerScreen> {
  static const _autoHideAfter = Duration(seconds: 4);

  bool _controlsVisible = true;
  Timer? _autoHide;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _autoHide?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _scheduleAutoHide() {
    _autoHide?.cancel();
    if (!_controlsVisible) return;
    _autoHide = Timer(_autoHideAfter, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _scheduleAutoHide();
  }

  /// Steps the visualizer style by [delta] places, wrapping round.
  void _cycleStyle(int delta) {
    final styles = VisualizerStyle.values;
    final current = ref.read(visualizerStyleProvider);
    final next =
        styles[(current.index + delta + styles.length) % styles.length];
    ref.read(settingsControllerProvider.notifier).setVisualizerStyle(next);

    setState(() => _controlsVisible = true);
    _scheduleAutoHide();
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
          onTap: _toggleControls,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 100) return;
            _cycleStyle(velocity < 0 ? 1 : -1);
          },
          child: Stack(
            children: [
              // A dim gradient rather than flat surface, so the glow the
              // painters draw has something to bloom against.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.surface(scheme),
                  ),
                ),
              ),
              Positioned.fill(
                child: WaveVisualizer(
                  color: ref.watch(visualizerColorProvider),
                  barCount: 56,
                ),
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
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    Text(
                                      '${ref.watch(visualizerStyleProvider).label}'
                                      '  ·  swipe to change',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
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
