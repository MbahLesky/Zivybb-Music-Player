import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/song_repository.dart';
import '../../features/playback/application/playback_controller.dart';
import '../../features/playback/presentation/now_playing_screen.dart';
import '../../features/playlists/presentation/save_to_playlist_sheet.dart';
import '../../features/settings/application/settings_controller.dart';
import '../../features/visualizer/presentation/wave_visualizer.dart';
import '../../routes/app_routes.dart';
import 'glass_card.dart';
import 'song_artwork.dart';

/// Persistent playback bar docked at the bottom of library screens.
///
/// Collapses to nothing when no song is loaded; expands into
/// [NowPlayingScreen] on tap.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final queuedSong = playback.currentSong;
    if (queuedSong == null) {
      return const SizedBox.shrink();
    }

    // The queue holds a snapshot taken when it was loaded, so the like state
    // there goes stale as soon as the song is liked anywhere else (Now
    // Playing does the same for the same reason).
    final song =
        ref.watch(songStreamProvider(queuedSong.id)).value ?? queuedSong;

    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GlassCard(
        radius: 24,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            if (settings.showVisualizerInMiniPlayer)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: IgnorePointer(
                    child: WaveVisualizer(
                      color: ref.watch(visualizerColorProvider),
                    ),
                  ),
                ),
              ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: AppRoutes.nowPlaying),
                  builder: (_) => const NowPlayingScreen(),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (settings.showAlbumArtInMiniPlayer) ...[
                      SongArtwork(song: song, size: 40),
                      const SizedBox(width: 10),
                    ],
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
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        song.isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                      tooltip: song.isLiked ? 'Unlike' : 'Like',
                      onPressed: () => ref
                          .read(songRepositoryProvider)
                          .setLiked(song.id, !song.isLiked),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.playlist_add),
                      tooltip: 'Save to playlist',
                      onPressed: () => SaveToPlaylistSheet.show(context, song),
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
          ],
        ),
      ),
    );
  }
}
