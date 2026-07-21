import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/mood_tag.dart';
import '../../../data/repositories/song_repository.dart';
import '../../mood_tagging/application/mood_tagging_controller.dart';
import '../../mood_tagging/presentation/mood_tagging_screen.dart';
import '../../settings/application/settings_controller.dart';
import '../../visualizer/presentation/wave_visualizer.dart';
import '../application/playback_controller.dart';

/// Full playback experience for the current track.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    // Watched separately so the mood tag badge reflects live edits, since
    // `song` is a snapshot taken when the queue was loaded.
    final liveSong = song == null
        ? null
        : ref.watch(songStreamProvider(song.id)).value ?? song;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.timelapse,
              color: playback.previewModeEnabled
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: playback.previewModeEnabled
                ? 'Preview mode on (30s clips)'
                : 'Preview mode off',
            onPressed: () => ref
                .read(playbackControllerProvider.notifier)
                .togglePreviewMode(),
          ),
          if (song != null)
            IconButton(
              icon: const Icon(Icons.mood),
              tooltip: 'Tag mood',
              onPressed: () => MoodTaggingSheet.show(context, song),
            ),
        ],
      ),
      body: song == null
          ? const Center(child: Text('Nothing is playing.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${song.artist} — ${song.album}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (liveSong?.moodTagId != null) ...[
                    const SizedBox(height: 8),
                    _MoodTagLabel(moodTagId: liveSong!.moodTagId!),
                  ],
                  const _CrossfadeIndicator(),
                  const SizedBox(height: 16),
                  WaveVisualizer(color: ref.watch(visualizerColorProvider)),
                  const SizedBox(height: 24),
                  Slider(
                    min: 0,
                    max: playback.duration.inMilliseconds > 0
                        ? playback.duration.inMilliseconds.toDouble()
                        : 1,
                    value: playback.position.inMilliseconds
                        .clamp(0, playback.duration.inMilliseconds)
                        .toDouble(),
                    onChanged: (value) => ref
                        .read(playbackControllerProvider.notifier)
                        .seek(Duration(milliseconds: value.round())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_format(playback.position)),
                      Text(_format(playback.duration)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: Icon(
                          playback.shuffleEnabled
                              ? Icons.shuffle_on_outlined
                              : Icons.shuffle,
                        ),
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .toggleShuffle(),
                      ),
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .previous(),
                      ),
                      IconButton(
                        iconSize: 48,
                        icon: Icon(
                          playback.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .togglePlayPause(),
                      ),
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.skip_next),
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .next(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _MoodTagLabel extends ConsumerWidget {
  const _MoodTagLabel({required this.moodTagId});

  final String moodTagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(moodTagsStreamProvider).value ?? const [];
    MoodTag? match;
    for (final tag in tags) {
      if (tag.id == moodTagId) {
        match = tag;
        break;
      }
    }
    if (match == null) return const SizedBox.shrink();
    return Chip(label: Text(match.label), visualDensity: VisualDensity.compact);
  }
}

class _CrossfadeIndicator extends ConsumerWidget {
  const _CrossfadeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider).value;
    if (settings == null || !settings.crossfadeEnabled) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Crossfade ${settings.crossfadeDuration.inSeconds}s',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
