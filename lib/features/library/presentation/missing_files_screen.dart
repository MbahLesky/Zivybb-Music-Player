import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/missing_file_service.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';

/// Surfaces songs whose files could not be found, with the option to
/// auto-detect relocated files or drop them from the library
/// (Screens.md #14, SRS F-5.3/F-5.4).
class MissingFilesScreen extends ConsumerStatefulWidget {
  const MissingFilesScreen({super.key});

  @override
  ConsumerState<MissingFilesScreen> createState() => _MissingFilesScreenState();
}

class _MissingFilesScreenState extends ConsumerState<MissingFilesScreen> {
  bool _scanning = false;

  Future<void> _scanForMatches() async {
    setState(() => _scanning = true);
    try {
      await ref.read(missingFileServiceProvider).autoRelinkAll();
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missing = ref.watch(missingSongsStreamProvider);

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: GradientAppBar(
        title: const Text('Missing Files'),
        actions: [
          AppBarIconAction(
            icon: _scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            tooltip: 'Scan for matches',
            onPressed: _scanning ? null : _scanForMatches,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: missing.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(child: Text('No missing files.'));
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.filePath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove from library',
                  onPressed: () => ref
                      .read(songRepositoryProvider)
                      .deleteFromLibrary(song.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load: $error')),
      ),
    );
  }
}
