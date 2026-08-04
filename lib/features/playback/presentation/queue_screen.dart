import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../application/playback_controller.dart';

/// What's playing now and what's up next, with drag-to-reorder and
/// swipe-free removal.
///
/// Shows the queue in its underlying order rather than shuffle order — that
/// is the order the reorder handles actually manipulate, so showing anything
/// else would make dragging feel arbitrary.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Queue'),
        actions: [
          if (playback.queue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${playback.queue.length} tracks',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.surface(theme.colorScheme),
        ),
        child: playback.queue.isEmpty
            ? const Center(child: Text('The queue is empty.'))
            : SafeArea(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: playback.queue.length,
                  onReorderItem: controller.reorderQueue,
                  itemBuilder: (context, index) {
                    final song = playback.queue[index];
                    final isCurrent = index == playback.currentIndex;

                    return ListTile(
                      key: ValueKey('${song.id}-$index'),
                      leading: isCurrent
                          ? Icon(
                              playback.isPlaying
                                  ? Icons.volume_up
                                  : Icons.pause,
                              color: theme.colorScheme.primary,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isCurrent ? theme.colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => controller.skipToIndex(index),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Remove from queue',
                            onPressed: () => controller.removeFromQueue(index),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4, right: 8),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
