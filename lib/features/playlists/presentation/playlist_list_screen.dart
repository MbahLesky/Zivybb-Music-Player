import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/playlist.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/glass_card.dart';
import '../application/playlist_controller.dart';
import 'playlist_detail_screen.dart';
import 'playlist_edit_dialog.dart';

/// Shows all user-created playlists plus auto-generated vibe playlists,
/// as a grid of cover-art cards (Screens.md #4), searchable by
/// name. Embedded as a tab within the Library shell.
class PlaylistListScreen extends ConsumerStatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  ConsumerState<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends ConsumerState<PlaylistListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsStreamProvider);

    return playlists.when(
      data: (allItems) {
        final normalizedQuery = _query.trim().toLowerCase();
        final items = normalizedQuery.isEmpty
            ? allItems
            : allItems
                  .where(
                    (playlist) =>
                        playlist.name.toLowerCase().contains(normalizedQuery),
                  )
                  .toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: AppSearchField(
                  hint: 'Search playlists',
                  onChanged: (query) => setState(() => _query = query),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return _CreatePlaylistCard(
                      onTap: () => _createPlaylist(context, ref),
                    );
                  }
                  final playlist = items[index - 1];
                  return _PlaylistCard(
                    playlist: playlist,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PlaylistDetailScreen(playlistId: playlist.id),
                      ),
                    ),
                    onEdit: () => _editPlaylist(context, ref, playlist),
                    onDelete: () => _confirmDelete(context, ref, playlist),
                  );
                }, childCount: items.length + 1),
              ),
            ),
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      allItems.isEmpty
                          ? 'No playlists yet — tap + to create one.'
                          : 'No playlists match your search.',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load playlists: $error')),
    );
  }

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final result = await showPlaylistEditDialog(context, title: 'New playlist');
    if (result != null && result.name.isNotEmpty) {
      await ref.read(playlistRepositoryProvider).createPlaylist(result.name);
    }
  }

  Future<void> _editPlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final result = await showPlaylistEditDialog(
      context,
      title: 'Edit playlist',
      initialValue: playlist.name,
      showCoverPicker: true,
      currentCoverPath: playlist.coverImagePath,
    );
    if (result == null) return;

    final repository = ref.read(playlistRepositoryProvider);
    if (result.name.isNotEmpty && result.name != playlist.name) {
      await repository.renamePlaylist(playlist.id, result.name);
    }
    if (result.coverImagePath != null) {
      await repository.setCoverImage(playlist.id, result.coverImagePath!);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${playlist.name}"?'),
        content: const Text(
          'This removes the playlist. Your songs stay in your library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(playlistRepositoryProvider).deletePlaylist(playlist.id);
    }
  }
}

class _CreatePlaylistCard extends StatelessWidget {
  const _CreatePlaylistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: scheme.primary),
            const SizedBox(height: 8),
            Text('Create playlist', style: TextStyle(color: scheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final coverPath = playlist.coverImagePath;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: coverPath != null
                        ? Image.file(File(coverPath), fit: BoxFit.cover)
                        : Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              playlist.isAutoGenerated
                                  ? Icons.auto_awesome
                                  : Icons.queue_music,
                              size: 40,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  if (!playlist.isAutoGenerated)
                    Positioned(
                      top: 4,
                      right: 4,
                      // Scrimmed, because this sits over whatever cover the
                      // user picked as well as over the pale placeholder —
                      // against which a bare white icon disappeared in light
                      // mode. A dark disc keeps it legible over both.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.38),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                playlist.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
