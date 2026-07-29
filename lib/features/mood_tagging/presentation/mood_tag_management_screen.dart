import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_palette.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/mood_tag.dart';
import '../../../data/repositories/mood_tag_repository.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/color_swatch_picker.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../playlists/application/mood_playlist_generator.dart';
import '../application/mood_tagging_controller.dart';

/// Add, rename, recolor, delete, and reorder mood tags. Full management —
/// including the built-in presets, which are just regular tags once seeded.
class MoodTagManagementScreen extends ConsumerWidget {
  const MoodTagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(moodTagsStreamProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Manage Moods'),
        actions: [
          AppBarIconAction(
            icon: const Icon(Icons.add),
            tooltip: 'Add mood',
            onPressed: () => _createMood(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: tags.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No mood tags yet.'));
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) {
              final reordered = [...items];
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, moved);
              ref
                  .read(moodTagRepositoryProvider)
                  .reorderMoodTags(reordered.map((tag) => tag.id).toList());
            },
            itemBuilder: (context, index) {
              final tag = items[index];
              return ListTile(
                key: ValueKey(tag.id),
                leading: GestureDetector(
                  onTap: () => _recolor(context, ref, tag),
                  child: CircleAvatar(
                    backgroundColor: colorFromHex(tag.colorHex),
                  ),
                ),
                title: Text(tag.label),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Rename',
                      onPressed: () => _rename(context, ref, tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _delete(context, ref, tag),
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
            Center(child: Text('Failed to load mood tags: $error')),
      ),
    );
  }

  Future<void> _createMood(BuildContext context, WidgetRef ref) async {
    final result = await _showMoodDialog(context, title: 'New mood');
    if (result == null) return;
    await ref
        .read(moodTagRepositoryProvider)
        .createMoodTag(result.label, colorToHex(result.color));
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, MoodTag tag) async {
    final result = await _showMoodDialog(
      context,
      title: 'Rename mood',
      initialLabel: tag.label,
      initialColorHex: tag.colorHex,
      showColorPicker: false,
    );
    if (result == null) return;
    await ref
        .read(moodTagRepositoryProvider)
        .renameMoodTag(tag.id, result.label);
  }

  Future<void> _recolor(
    BuildContext context,
    WidgetRef ref,
    MoodTag tag,
  ) async {
    final result = await _showMoodDialog(
      context,
      title: 'Mood color',
      initialLabel: tag.label,
      initialColorHex: tag.colorHex,
      showLabelField: false,
    );
    if (result == null) return;
    await ref
        .read(moodTagRepositoryProvider)
        .recolorMoodTag(tag.id, colorToHex(result.color));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MoodTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${tag.label}"?'),
        content: const Text(
          'Songs tagged with this mood become untagged, and its '
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
    await ref.read(moodPlaylistGeneratorProvider).deleteMoodTag(tag.id);
  }

  Future<_MoodDialogResult?> _showMoodDialog(
    BuildContext context, {
    required String title,
    String initialLabel = '',
    String initialColorHex = '#FF7043',
    bool showLabelField = true,
    bool showColorPicker = true,
  }) {
    return showDialog<_MoodDialogResult>(
      context: context,
      builder: (context) => _MoodDialog(
        title: title,
        initialLabel: initialLabel,
        initialColorHex: initialColorHex,
        showLabelField: showLabelField,
        showColorPicker: showColorPicker,
      ),
    );
  }
}

class _MoodDialogResult {
  const _MoodDialogResult({required this.label, required this.color});

  final String label;
  final Color color;
}

class _MoodDialog extends StatefulWidget {
  const _MoodDialog({
    required this.title,
    required this.initialLabel,
    required this.initialColorHex,
    required this.showLabelField,
    required this.showColorPicker,
  });

  final String title;
  final String initialLabel;
  final String initialColorHex;
  final bool showLabelField;
  final bool showColorPicker;

  @override
  State<_MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<_MoodDialog> {
  late final _labelController = TextEditingController(
    text: widget.initialLabel,
  );
  late String _colorHex = widget.initialColorHex;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabelField)
            TextField(
              controller: _labelController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Mood name'),
            ),
          if (widget.showLabelField && widget.showColorPicker)
            const SizedBox(height: 16),
          if (widget.showColorPicker)
            ColorSwatchPicker(
              selectedHex: _colorHex,
              palette: moodColorPalette,
              onSelected: (color) =>
                  setState(() => _colorHex = colorToHex(color)),
            ),
        ],
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
              _MoodDialogResult(
                label: label.isEmpty ? widget.initialLabel : label,
                color: colorFromHex(_colorHex),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
