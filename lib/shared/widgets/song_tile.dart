import 'package:flutter/material.dart';

import '../../core/constants/mood_tags.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../data/models/song.dart';
import 'album_art.dart';

/// One song in a list, in whichever list it appears.
class SongTile extends StatelessWidget {
  const SongTile({
    required this.song,
    required this.onTap,
    this.onToggleLiked,
    this.isCurrent = false,
    super.key,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onToggleLiked;

  /// Whether this song is the one loaded in the player.
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = MoodTags.byId(song.moodTagId);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: AlbumArt(seed: song.id),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isCurrent ? theme.colorScheme.primary : null,
          fontWeight: isCurrent ? FontWeight.w600 : null,
        ),
      ),
      subtitle: Row(
        children: [
          if (mood != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: mood.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (song.isMissing) ...[
            const Icon(Icons.error_outline, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              song.isMissing ? 'File not found' : song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: song.isMissing
                  ? theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    )
                  : theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTrackDuration(song.duration),
            style: theme.textTheme.bodySmall,
          ),
          if (onToggleLiked != null)
            IconButton(
              onPressed: onToggleLiked,
              icon: Icon(
                song.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: song.isLiked ? theme.colorScheme.secondary : null,
              ),
              tooltip: song.isLiked ? 'Remove from Liked' : 'Add to Liked',
            ),
        ],
      ),
    );
  }
}
