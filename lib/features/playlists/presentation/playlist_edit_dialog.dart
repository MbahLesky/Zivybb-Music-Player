import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Result of [showPlaylistEditDialog]. [coverImagePath] is only set when the
/// user picked a *new* image this time — `null` means "leave it unchanged."
class PlaylistEditResult {
  const PlaylistEditResult({required this.name, this.coverImagePath});

  final String name;
  final String? coverImagePath;
}

/// Prompts for a playlist name, optionally with a cover-photo picker.
/// Returns `null` if the user cancels.
Future<PlaylistEditResult?> showPlaylistEditDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  bool showCoverPicker = false,
  String? currentCoverPath,
}) {
  final controller = TextEditingController(text: initialValue);
  String? pickedCoverPath = currentCoverPath;
  return showDialog<PlaylistEditResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCoverPicker)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                    );
                    if (picked != null) {
                      setState(() => pickedCoverPath = picked.path);
                    }
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: pickedCoverPath != null
                        ? FileImage(File(pickedCoverPath!))
                        : null,
                    child: pickedCoverPath == null
                        ? const Icon(Icons.add_photo_alternate_outlined)
                        : null,
                  ),
                ),
              ),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Playlist name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              PlaylistEditResult(
                name: controller.text.trim(),
                coverImagePath: pickedCoverPath == currentCoverPath
                    ? null
                    : pickedCoverPath,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
