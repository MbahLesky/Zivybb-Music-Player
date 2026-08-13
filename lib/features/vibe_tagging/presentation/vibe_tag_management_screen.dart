import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_palette.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/vibe_tag.dart';
import '../../../data/repositories/vibe_tag_repository.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../playlists/application/vibe_playlist_generator.dart';
import '../application/vibe_tagging_controller.dart';
import 'vibe_category_management_screen.dart';

/// Add, rename, recolor, delete, refile, and reorder vibes. Full management —
/// including the built-in presets, which are just regular vibes once seeded.
///
/// Vibes are listed under the folder they belong to. Each folder is its own
/// [ReorderableListView] so dragging stays contained: a single list across
/// folders would let a vibe be dropped onto a heading, which has no meaning
/// when a vibe belongs to exactly one folder. Moving between folders is an
/// explicit menu action instead.
class VibeTagManagementScreen extends ConsumerWidget {
  const VibeTagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(vibeTagsStreamProvider);
    final groups = ref.watch(vibeGroupsProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Manage Vibes'),
        actions: [
          AppBarIconAction(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Manage folders',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VibeCategoryManagementScreen(),
              ),
            ),
          ),
          AppBarIconAction(
            icon: const Icon(Icons.add),
            tooltip: 'Add vibe',
            onPressed: () => _createVibe(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: tags.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No vibes yet.'));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              for (final group in groups)
                _VibeGroupSection(group: group, allGroups: groups),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load vibes: $error')),
      ),
    );
  }

  Future<void> _createVibe(BuildContext context, WidgetRef ref) async {
    final categories = ref.read(vibeCategoriesStreamProvider).value ?? const [];
    final result = await showVibeDialog(
      context,
      title: 'New vibe',
      categories: categories,
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .createVibeTag(
          result.label,
          colorToHex(result.color),
          categoryId: result.categoryId,
        );
  }
}

/// One folder's heading and the vibes filed under it.
class _VibeGroupSection extends ConsumerWidget {
  const _VibeGroupSection({required this.group, required this.allGroups});

  final VibeGroup group;

  /// Every group, so the "move to" menu can offer the other folders.
  final List<VibeGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = group.category == null
        ? theme.colorScheme.onSurfaceVariant
        : colorFromHex(group.category!.colorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Row(
            children: [
              Icon(Icons.folder_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${group.vibes.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (group.vibes.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(42, 4, 16, 4),
            child: Text(
              'Nothing filed here yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ReorderableListView.builder(
            // Nested in the outer ListView, so it must size to its children
            // and leave the scrolling to the parent.
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.vibes.length,
            onReorderItem: (oldIndex, newIndex) =>
                _reorderWithin(ref, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final tag = group.vibes[index];
              return _VibeTile(
                key: ValueKey(tag.id),
                tag: tag,
                groups: allGroups,
              );
            },
          ),
      ],
    );
  }

  /// Applies a drag inside this folder.
  ///
  /// `sortOrder` is a single sequence across every vibe, so a move inside one
  /// folder is written as a full reorder of the flattened list: folders in
  /// their own order, each one's vibes in theirs. That also repairs the order
  /// of any install whose sequence had drifted out of folder order.
  void _reorderWithin(WidgetRef ref, int oldIndex, int newIndex) {
    final reordered = [...group.vibes];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));

    final flattened = [
      for (final other in allGroups)
        ...(other.category?.id == group.category?.id ? reordered : other.vibes),
    ];
    ref
        .read(vibeTagRepositoryProvider)
        .reorderVibeTags([for (final tag in flattened) tag.id]);
  }
}

class _VibeTile extends ConsumerWidget {
  const _VibeTile({super.key, required this.tag, required this.groups});

  final VibeTag tag;
  final List<VibeGroup> groups;

  /// Stands in for "no folder" in the move-to menu.
  ///
  /// A `null` menu value cannot be used: [PopupMenuButton] cannot tell a
  /// null-valued selection from a dismissed menu, and reports both to
  /// `onCanceled` — so picking "Uncategorised" would silently do nothing.
  static const _noFolder = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The uncategorised group only exists while something is loose in it, so
    // the entry is added here rather than read off `groups`.
    final choices = <(String, String)>[
      for (final group in groups)
        if (group.category != null) (group.category!.id, group.name),
      (_noFolder, VibeCategory.uncategorisedName),
    ];
    // Falls back to "no folder" for a vibe pointing at a folder that no
    // longer exists, which is where `vibeGroupsProvider` lists it anyway.
    final currentId = choices.any((choice) => choice.$1 == tag.categoryId)
        ? tag.categoryId!
        : _noFolder;

    return ListTile(
      leading: GestureDetector(
        onTap: () => _recolor(context, ref),
        child: CircleAvatar(backgroundColor: colorFromHex(tag.colorHex)),
      ),
      title: Text(tag.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.drive_file_move_outline),
            tooltip: 'Move to folder',
            onSelected: (categoryId) => ref
                .read(vibeTagRepositoryProvider)
                .setVibeCategory(
                  tag.id,
                  categoryId == _noFolder ? null : categoryId,
                ),
            itemBuilder: (_) => [
              for (final (id, name) in choices)
                CheckedPopupMenuItem<String>(
                  value: id,
                  checked: currentId == id,
                  child: Text(name),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: () => _rename(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref),
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final result = await showVibeDialog(
      context,
      title: 'Rename vibe',
      initialLabel: tag.label,
      initialColorHex: tag.colorHex,
      showColorPicker: false,
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .renameVibeTag(tag.id, result.label);
    // The auto-generated playlist is named after the vibe, so it has to
    // follow the rename.
    await ref.read(vibePlaylistGeneratorProvider).regenerateAll();
  }

  Future<void> _recolor(BuildContext context, WidgetRef ref) async {
    final result = await showVibeDialog(
      context,
      title: 'Vibe color',
      initialLabel: tag.label,
      initialColorHex: tag.colorHex,
      showLabelField: false,
    );
    if (result == null) return;
    await ref
        .read(vibeTagRepositoryProvider)
        .recolorVibeTag(tag.id, colorToHex(result.color));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${tag.label}"?'),
        content: const Text(
          'Songs lose this vibe (any others they carry stay), and its '
          'auto-generated playlist is removed.',
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
    await ref.read(vibePlaylistGeneratorProvider).deleteVibeTag(tag.id);
  }
}

/// What a vibe dialog came back with. [categoryId] is only meaningful when
/// the dialog was shown a list of folders to choose from.
class VibeDialogResult {
  const VibeDialogResult({
    required this.label,
    required this.color,
    this.categoryId,
  });

  final String label;
  final Color color;
  final String? categoryId;
}

/// Shared name/colour(/folder) prompt, used for creating, renaming, and
/// recolouring both vibes and their folders.
Future<VibeDialogResult?> showVibeDialog(
  BuildContext context, {
  required String title,
  String initialLabel = '',
  String initialColorHex = '#FF7043',
  String labelHint = 'Vibe name',
  bool showLabelField = true,
  bool showColorPicker = true,
  List<VibeCategory> categories = const [],
  String? initialCategoryId,
}) {
  return showDialog<VibeDialogResult>(
    context: context,
    builder: (context) => _VibeDialog(
      title: title,
      initialLabel: initialLabel,
      initialColorHex: initialColorHex,
      labelHint: labelHint,
      showLabelField: showLabelField,
      showColorPicker: showColorPicker,
      categories: categories,
      initialCategoryId: initialCategoryId,
    ),
  );
}

class _VibeDialog extends StatefulWidget {
  const _VibeDialog({
    required this.title,
    required this.initialLabel,
    required this.initialColorHex,
    required this.labelHint,
    required this.showLabelField,
    required this.showColorPicker,
    required this.categories,
    required this.initialCategoryId,
  });

  final String title;
  final String initialLabel;
  final String initialColorHex;
  final String labelHint;
  final bool showLabelField;
  final bool showColorPicker;
  final List<VibeCategory> categories;
  final String? initialCategoryId;

  @override
  State<_VibeDialog> createState() => _VibeDialogState();
}

class _VibeDialogState extends State<_VibeDialog> {
  late final _labelController = TextEditingController(
    text: widget.initialLabel,
  );
  late String _colorHex = widget.initialColorHex;
  late String? _categoryId = widget.initialCategoryId;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      // Scrolls rather than overflowing: with a label field, a folder picker,
      // and a swatch grid this can outgrow a short screen, and an
      // AlertDialog's content does not scroll on its own.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLabelField)
              TextField(
                controller: _labelController,
                autofocus: true,
                decoration: InputDecoration(hintText: widget.labelHint),
              ),
            if (widget.categories.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Folder'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(VibeCategory.uncategorisedName),
                  ),
                  for (final category in widget.categories)
                    DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            ],
            if (widget.showColorPicker) ...[
              const SizedBox(height: 16),
              ColorSwatchPicker(
                selectedHex: _colorHex,
                palette: vibeColorPalette,
                allowCustom: true,
                onSelected: (color) =>
                    setState(() => _colorHex = colorToHex(color)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        GradientButton(
          onPressed: () {
            final label = _labelController.text.trim();
            if (widget.showLabelField && label.isEmpty) return;
            Navigator.of(context).pop(
              VibeDialogResult(
                label: label.isEmpty ? widget.initialLabel : label,
                color: colorFromHex(_colorHex),
                categoryId: _categoryId,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
