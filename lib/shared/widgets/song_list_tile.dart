import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import 'glass_card.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GlassCard(
        radius: 20,
        child: ListTile(
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${song.artist} — ${song.album}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onTap,
          trailing:
              trailing ??
              IconButton(
                icon: Icon(song.isLiked ? Icons.favorite : Icons.favorite_border),
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
