import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';
import '../application/mood_tagging_controller.dart';

/// Assigns or clears a song's mood/energy label (Screens.md #7).
///
/// Tapping a selected chip again clears the tag; tapping a different chip
/// replaces it — a song has at most one mood tag.
class MoodTaggingSheet extends ConsumerWidget {
  const MoodTaggingSheet({super.key, required this.song});

  final Song song;

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => MoodTaggingSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodTags = ref.watch(moodTagsStreamProvider);
    // Re-derive the live mood tag rather than trusting `song`, which may be
    // a stale snapshot from the playback queue.
    final currentMoodTagId =
        ref.watch(songStreamProvider(song.id)).value?.moodTagId ??
        song.moodTagId;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tag "${song.title}"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            moodTags.when(
              data: (tags) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    ChoiceChip(
                      label: Text(tag.label),
                      selected: currentMoodTagId == tag.id,
                      onSelected: (selected) => ref
                          .read(songRepositoryProvider)
                          .setMoodTag(song.id, selected ? tag.id : null),
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Failed to load mood tags: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
