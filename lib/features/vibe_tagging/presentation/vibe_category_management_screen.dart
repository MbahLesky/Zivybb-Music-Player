import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_hex.dart';
import '../../../data/models/vibe_tag.dart';
import '../../../data/repositories/vibe_tag_repository.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../application/vibe_tagging_controller.dart';
import 'vibe_tag_management_screen.dart';

/// Add, rename, recolor, reorder, and delete the folders vibes are grouped
/// into (Mood, Place, Time, Genre, …).
///
/// Deleting a folder never deletes the vibes inside it: they fall back to
/// "Uncategorised", where they can be refiled. A folder is a way of arranging
/// vibes, and discarding one must not discard the tagging work behind them.
class VibeCategoryManagementScreen extends ConsumerWidget {
  const VibeCategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(vibeCategoriesStreamProvider);
    final groups = ref.watch(vibeGroupsProvider);

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: GradientAppBar(
        title: const Text('Vibe Folders'),
        actions: [
          AppBarIconAction(
            icon: const Icon(Icons.add),
            tooltip: 'Add folder',
            onPressed: () => _create(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: categories.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No folders yet. Add one to start grouping your vibes.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) {
              final reordered = [...items];
              reordered.insert(newIndex, reordered.removeAt(oldIndex));
              ref.read(vibeTagRepositoryProvider).reorderVibeCategories([
                for (final category in reordered) category.id,
              ]);
            },
            itemBuilder: (context, index) {
              final category = items[index];
              final count = groups
                  .firstWhere(
                    (group) => group.category?.id == category.id,
                    orElse: () => const VibeGroup(category: null, vibes: []),
                  )
                  .vibes
                  .length;

              return ListTile(
                key: ValueKey(category.id),
                leading: GestureDetector(
                  onTap: () => _recolor(context, ref, category),
                  child: CircleAvatar(
                    backgroundColor: colorFromHex(category.colorHex),
                    child: const Icon(
                      Icons.folder_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(category.name),
                subtitle: Text(count == 1 ? '1 vibe' : '$count vibes'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Rename',
                      onPressed: () => _rename(context, ref, category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _delete(context, ref, category, count),
                    ),
                    const Icon(Icons.drag_handle),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load folders: $error')),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showVibeDialog(
      context,
      title: 'New folder',
      labelHint: 'Folder name',
      initialColorHex: '#7E57C2',
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .createVibeCategory(result.label, colorToHex(result.color));
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    VibeCategory category,
  ) async {
    final result = await showVibeDialog(
      context,
      title: 'Rename folder',
      labelHint: 'Folder name',
      initialLabel: category.name,
      initialColorHex: category.colorHex,
      showColorPicker: false,
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .renameVibeCategory(category.id, result.label);
  }

  Future<void> _recolor(
    BuildContext context,
    WidgetRef ref,
    VibeCategory category,
  ) async {
    final result = await showVibeDialog(
      context,
      title: 'Folder color',
      initialLabel: category.name,
      initialColorHex: category.colorHex,
      showLabelField: false,
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .recolorVibeCategory(category.id, colorToHex(result.color));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    VibeCategory category,
    int vibeCount,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${category.name}"?'),
        content: Text(
          vibeCount == 0
              ? 'The folder is empty, so nothing else changes.'
              : 'The $vibeCount ${vibeCount == 1 ? 'vibe' : 'vibes'} inside '
                    'move to "${VibeCategory.uncategorisedName}". No song '
                    'loses a tag.',
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
    if (confirmed != true) return;
    await ref.read(vibeTagRepositoryProvider).deleteVibeCategory(category.id);
  }
}
