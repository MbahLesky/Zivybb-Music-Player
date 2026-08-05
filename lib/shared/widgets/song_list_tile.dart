import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import 'glass_card.dart';
import 'vibe_chips.dart';

/// A song row used across the Library, Liked Songs, Playlist Detail, and
/// Folder Browser screens.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GlassCard(
        radius: 18,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          minLeadingWidth: 24,
          title: Row(
            children: [
              if (song.isVideo) ...[
                Tooltip(
                  message: 'Video file, played as audio',
                  child: Icon(
                    Icons.movie_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${song.artist} — ${song.album}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Collapses to nothing when the song has no vibes, so
              // untagged rows keep their original height.
              VibeChips(songId: song.id),
            ],
          ),
          onTap: onTap,
          trailing:
              trailing ??
              IconButton(
                icon: Icon(
                  song.isLiked ? Icons.favorite : Icons.favorite_border,
                ),
                tooltip: song.isLiked ? 'Unlike' : 'Like',
                onPressed: () => ref
                    .read(songRepositoryProvider)
                    .setLiked(song.id, !song.isLiked),
              ),
        ),
      ),
    );
  }
}
