import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../features/library/presentation/song_delete_actions.dart';
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

  /// Offers the destructive actions on long-press rather than from a
  /// permanent overflow button: they are rare, and a third control on every
  /// row would crowd out the like toggle that isn't.
  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;
    final action = await showModalBottomSheet<_SongTileAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(song.title, maxLines: 1),
              subtitle: Text(song.artist, maxLines: 1),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.playlist_remove_outlined),
              title: const Text('Remove from library'),
              subtitle: const Text('Keeps the file on your device'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_SongTileAction.removeFromLibrary),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
              title: Text(
                'Delete from device',
                style: TextStyle(color: scheme.error),
              ),
              subtitle: const Text('Deletes the file permanently'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_SongTileAction.deleteFromDevice),
            ),
          ],
        ),
      ),
    );
    // The sheet's own context is gone by now, so the confirmations below run
    // against this tile's context instead.
    if (!context.mounted || action == null) return;

    switch (action) {
      case _SongTileAction.removeFromLibrary:
        await confirmAndRemoveFromLibrary(context, ref, song);
      case _SongTileAction.deleteFromDevice:
        await confirmAndDeleteFromDevice(context, ref, song);
    }
  }

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
          onLongPress: () => _showActions(context, ref),
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

/// The choices [SongListTile]'s long-press sheet offers.
enum _SongTileAction { removeFromLibrary, deleteFromDevice }
