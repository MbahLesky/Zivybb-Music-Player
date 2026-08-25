import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../features/playback/application/playback_controller.dart';
import 'song_artwork.dart';
import 'vibe_chips.dart';

/// A song row used across the Library, Liked Songs, Playlist Detail, and
/// Folder Browser screens.
///
/// Deliberately not a card. Every row used to be its own bordered,
/// drop-shadowed [GlassCard]: stacked four pixels apart, each row's border sat
/// against its neighbour's and the list read as a run of doubled lines, and
/// every row ran its own `BackdropFilter` blur for the privilege. The row now
/// carries no chrome at all — album art gives the list its rhythm, and the
/// only filled shape is the one marking the track that's playing.
class SongListTile extends ConsumerWidget {
  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
  });

  final Song song;
  final VoidCallback onTap;

  /// Overrides the default like-toggle trailing icon, e.g. for a
  /// remove-from-playlist action.
  final Widget? trailing;

  static const _artworkSize = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Selected via `select` so a row rebuilds when the track changes, not on
    // every position tick — this is the one thing here that watches playback,
    // and a whole list of rows redrawing at 60Hz would be a real cost.
    final isPlaying = ref.watch(
      playbackControllerProvider.select(
        (playback) => playback.currentSong?.id == song.id,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isPlaying
            ? scheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: Row(
              children: [
                SongArtwork(
                  song: song,
                  size: _artworkSize,
                  borderRadius: 10,
                  iconSize: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (isPlaying) ...[
                            Icon(
                              Icons.graphic_eq,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (song.isVideo) ...[
                            Tooltip(
                              message: 'Video file, played as audio',
                              child: Icon(
                                Icons.movie_outlined,
                                size: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                // The title carries the weight so it reads
                                // first; everything under it steps back.
                                fontWeight: FontWeight.w600,
                                color: isPlaying
                                    ? scheme.primary
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _secondaryLine(song),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      // Collapses to nothing when the song has no vibes, so
                      // untagged rows stay two lines tall.
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: VibeChips(songId: song.id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(song.duration),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    // Tabular figures so the column of times lines up
                    // instead of jittering row to row.
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                trailing ??
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      icon: Icon(
                        song.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: song.isLiked ? scheme.primary : null,
                      ),
                      tooltip: song.isLiked ? 'Unlike' : 'Like',
                      onPressed: () => ref
                          .read(songRepositoryProvider)
                          .setLiked(song.id, !song.isLiked),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Artist and album on one line, skipping either when the scan didn't find
  /// it — "Unknown — Unknown" was noise on files with no tags.
  static String _secondaryLine(Song song) {
    const unknown = {'', '<unknown>', 'unknown'};
    final parts = [
      for (final part in [song.artist, song.album])
        if (!unknown.contains(part.trim().toLowerCase())) part,
    ];
    return parts.isEmpty ? 'Unknown artist' : parts.join(' · ');
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
