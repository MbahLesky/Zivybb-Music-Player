import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

/// Edit a song's metadata (Screens.md #9, SRS F-6.1).
///
/// Edits Zivybb's cache, not the audio file's own tags — see
/// [SongRepository.updateMetadata] for why the edit still sticks across
/// future library scans.
class TagEditorScreen extends ConsumerStatefulWidget {
  const TagEditorScreen({super.key, required this.song});

  final Song song;

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  late final _titleController = TextEditingController(text: widget.song.title);
  late final _artistController = TextEditingController(
    text: widget.song.artist,
  );
  late final _albumController = TextEditingController(text: widget.song.album);
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref
        .read(songRepositoryProvider)
        .updateMetadata(
          widget.song.id,
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          album: _albumController.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Edit Tags'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _albumController,
              decoration: const InputDecoration(labelText: 'Album'),
            ),
          ],
        ),
      ),
    );
  }
}
