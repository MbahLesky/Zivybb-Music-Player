import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_hex.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/vibe_tag_repository.dart';
import '../../playlists/application/vibe_playlist_generator.dart';
import '../application/vibe_tagging_controller.dart';

/// Assigns or clears a song's vibes (Screens.md #7).
///
/// A song can carry any number of vibes: each chip toggles independently,
/// and its auto-generated playlist follows immediately.
class VibeTaggingSheet extends ConsumerWidget {
  const VibeTaggingSheet({super.key, required this.song});

  final Song song;

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => VibeTaggingSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibeTags = ref.watch(vibeTagsStreamProvider);
    final selectedIds =
        ref.watch(vibeIdsForSongProvider(song.id)).value ?? const <String>{};

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vibes for "${song.title}"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Pick as many as fit.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            vibeTags.when(
              data: (tags) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    FilterChip(
                      label: Text(tag.label),
                      avatar: CircleAvatar(
                        backgroundColor: colorFromHex(tag.colorHex),
                        radius: 8,
                      ),
                      selected: selectedIds.contains(tag.id),
                      selectedColor: colorFromHex(
                        tag.colorHex,
                      ).withValues(alpha: 0.28),
                      onSelected: (selected) async {
                        final repository = ref.read(vibeTagRepositoryProvider);
                        if (selected) {
                          await repository.addVibeToSong(song.id, tag.id);
                        } else {
                          await repository.removeVibeFromSong(song.id, tag.id);
                        }
                        await ref
                            .read(vibePlaylistGeneratorProvider)
                            .regenerateAll();
                      },
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Failed to load vibes: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
