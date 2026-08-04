import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/backup_repository.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../playlists/application/mood_playlist_generator.dart';

/// Back up or restore playlists, liked songs, mood tags, and settings
/// (Screens.md #13, SRS F-5.1/F-5.2).
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _busy = false;

  Future<void> _backUpNow() async {
    setState(() => _busy = true);
    try {
      await ref.read(backupRepositoryProvider).createBackup();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(String backupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This adds back the playlists, liked songs, and mood tags from '
          'this backup, and applies its settings. It won\'t remove anything '
          'you\'ve added since.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(backupRepositoryProvider).restoreBackup(backupId);
      await ref.read(moodPlaylistGeneratorProvider).regenerateAll();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup restored.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backups = ref.watch(backupsStreamProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: Text('Backup & Restore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              onPressed: _busy ? null : _backUpNow,
              icon: Icons.backup,
              child: const Text('Back Up Now'),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: backups.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(child: Text('No backups yet.'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(_formatTimestamp(entry.createdAt)),
                      subtitle: const Text('Tap Export to keep a copy'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _busy ? null : () => _restore(entry.id),
                            child: const Text('Restore'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.ios_share),
                            tooltip: 'Export backup',
                            onPressed: _busy ? null : () => _export(entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete backup',
                            onPressed: _busy
                                ? null
                                : () => ref
                                      .read(backupRepositoryProvider)
                                      .deleteBackup(entry.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Failed to load backups: $error')),
            ),
          ),
        ],
      ),
    );
  }

  /// Hands the backup file to Android's share sheet.
  ///
  /// Backups otherwise live in app-private storage, which Android wipes on
  /// uninstall — exporting is what makes them survive reinstalling the app
  /// or moving to a new phone (SRS F-5.1).
  Future<void> _export(BackupEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);
    final file = File(entry.filePath);
    if (!await file.exists()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('That backup file is missing.')),
      );
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(entry.filePath, mimeType: 'application/json')],
        subject: 'Zivybb backup ${_formatTimestamp(entry.createdAt)}',
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)} '
        '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }
}
