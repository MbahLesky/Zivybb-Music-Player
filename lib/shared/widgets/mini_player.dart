import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/playback/application/playback_controller.dart';
import '../../features/playback/presentation/now_playing_screen.dart';
import '../../routes/app_routes.dart';
import 'glass_card.dart';

/// Persistent playback bar docked at the bottom of library screens.
///
/// Collapses to nothing when no song is loaded; expands into
/// [NowPlayingScreen] on tap.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GlassCard(
        radius: 24,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.nowPlaying),
              builder: (_) => const NowPlayingScreen(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playback.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  tooltip: playback.isPlaying ? 'Pause' : 'Play',
                  onPressed: () => ref
                      .read(playbackControllerProvider.notifier)
                      .togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Next',
                  onPressed: () =>
                      ref.read(playbackControllerProvider.notifier).next(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
