import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../application/playback_controller.dart';

/// Shows the current playback queue: reorder, remove, or jump to a track,
/// sort it, or scramble it into a fresh random order ("Up next" from the
/// Now Playing screen).
///
/// Lists the queue in its underlying order rather than shuffle order — that
/// is the order the reorder handles actually manipulate, so showing anything
/// else would make dragging feel arbitrary.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final queue = playback.queue;

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Up Next'),
        actions: [
          if (queue.isNotEmpty)
            Center(
              child: Text(
                '${queue.length} tracks',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          AppBarIconAction(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort queue',
            onPressed: queue.isEmpty ? null : () => _showSortSheet(context),
          ),
          AppBarIconAction(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Scramble queue and play',
            onPressed: queue.isEmpty
                ? null
                : () => ref
                      .read(playbackControllerProvider.notifier)
                      .scrambleQueueAndPlay(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: queue.isEmpty
          ? const Center(child: Text('Nothing queued.'))
          : ReorderableListView.builder(
              itemCount: queue.length,
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) => ref
                  .read(playbackControllerProvider.notifier)
                  .reorderQueue(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = index == playback.currentIndex;
                return Container(
                  key: ValueKey(song.id),
                  color: isCurrent
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.35)
                      : null,
                  child: SongListTile(
                    song: song,
                    onTap: () => ref
                        .read(playbackControllerProvider.notifier)
                        .playAt(index),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.equalizer,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Remove from queue',
                          onPressed: () => ref
                              .read(playbackControllerProvider.notifier)
                              .removeFromQueue(index),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (sort, label, icon) in [
              (QueueSort.title, 'Title', Icons.sort_by_alpha),
              (QueueSort.artist, 'Artist', Icons.person_outline),
              (QueueSort.duration, 'Length', Icons.timer_outlined),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ProviderScope.containerOf(
                    context,
                  ).read(playbackControllerProvider.notifier).sortQueue(sort);
                },
              ),
          ],
        ),
      ),
    );
  }
}
