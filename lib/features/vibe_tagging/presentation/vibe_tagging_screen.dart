import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_hex.dart';
import '../../../data/models/song.dart';
import '../../../data/models/vibe_tag.dart';
import '../../../data/repositories/vibe_tag_repository.dart';
import '../../playlists/application/vibe_playlist_generator.dart';
import '../application/vibe_tagging_controller.dart';

/// Assigns or clears a song's vibes (Screens.md #7).
///
/// A song can carry any number of vibes: each chip toggles independently,
/// and its auto-generated playlist follows immediately. Chips are grouped
/// under their folder, so a long vibe list stays readable.
///
/// The chip area scrolls and the sheet is height-capped. It used to be a
/// bare [Column] in a default-height sheet, which overflowed the moment the
/// vibe list outgrew the sheet — and with folders adding headings, and users
/// free to add as many vibes as they like, it always eventually does.
class VibeTaggingSheet extends ConsumerWidget {
  const VibeTaggingSheet({super.key, required this.song});

  final Song song;

  /// How much of the screen the sheet may take before its contents scroll.
  static const _maxHeightFraction = 0.85;

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet<void>(
      context: context,
      // Without this the sheet is capped at half the screen and cannot grow
      // to the height asked for below.
      isScrollControlled: true,
      builder: (_) => VibeTaggingSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibeTags = ref.watch(vibeTagsStreamProvider);
    final groups = ref.watch(vibeGroupsProvider);
    final selectedIds =
        ref.watch(vibeIdsForSongProvider(song.id)).value ?? const <String>{};
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFraction,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The heading stays put while the chips scroll under it, so it is
            // always clear which song is being tagged.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vibes for "${song.title}"',
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick as many as fit.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: vibeTags.when(
                data: (tags) => tags.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Text('No vibes yet — add some in Settings.'),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          for (final group in groups)
                            if (group.vibes.isNotEmpty)
                              _VibeGroupSection(
                                group: group,
                                songId: song.id,
                                selectedIds: selectedIds,
                              ),
                        ],
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Text('Failed to load vibes: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One folder's heading and its chips.
class _VibeGroupSection extends ConsumerWidget {
  const _VibeGroupSection({
    required this.group,
    required this.songId,
    required this.selectedIds,
  });

  final VibeGroup group;
  final String songId;
  final Set<String> selectedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final headingColor = group.category == null
        ? theme.colorScheme.onSurfaceVariant
        : colorFromHex(group.category!.colorHex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: headingColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.name.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in group.vibes)
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
                      await repository.addVibeToSong(songId, tag.id);
                    } else {
                      await repository.removeVibeFromSong(songId, tag.id);
                    }
                    await ref
                        .read(vibePlaylistGeneratorProvider)
                        .regenerateAll();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
