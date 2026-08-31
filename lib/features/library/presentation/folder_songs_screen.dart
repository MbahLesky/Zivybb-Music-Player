import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/song.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../../shared/widgets/play_shuffle_header.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../playback/application/playback_controller.dart';
import '../../vibe_tagging/application/vibe_tagging_controller.dart';
import '../application/library_controller.dart';
import '../application/library_view_controller.dart';
import 'library_view_sheet.dart';

/// Songs within a single device folder, with play/shuffle-all header actions
/// and the same search, sort and filter controls every other list has.
///
/// It used to carry its own private sort and duration-filter menus, which
/// meant "sort by length" here and "sort by length" on the library were two
/// different controls with two different sets of options. It now shares
/// [libraryViewProvider] with the rest of the app.
///
/// The folder's songs are re-derived from the live library rather than kept
/// as the snapshot passed in: liking a track here, or editing its tags, has
/// to be reflected on the row that was just tapped.
class FolderSongsScreen extends ConsumerWidget {
  const FolderSongsScreen({super.key, required this.folderPath});

  final String folderPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryStreamProvider).value ?? const <Song>[];
    final folderSongs = [
      for (final song in library)
        if (p.dirname(song.filePath) == folderPath) song,
    ];

    final query = ref.watch(librarySearchQueryProvider);
    final view = ref.watch(libraryViewProvider);
    final visible = applyLibraryView(
      folderSongs,
      query: query,
      // The screen *is* the folder, so the shared folder narrowing would only
      // ever empty it — dropped here and hidden in the sheet.
      view: view.copyWith(deviceFolder: null),
      vibeTaggedSongIds: ref.watch(vibeTaggedSongIdsProvider),
      restrictToSongIds: ref.watch(libraryVibeCategoryRestrictionProvider),
    );

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: GradientAppBar(title: Text(p.basename(folderPath))),
      body: Column(
        children: [
          PlayShuffleHeader(songs: visible),
          const LibraryViewControls(
            hint: 'Search in folder',
            showFolderFilter: false,
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        folderSongs.isEmpty
                            ? 'This folder has no songs.'
                            : noMatchMessage(
                                query: query,
                                view: view.copyWith(deviceFolder: null),
                                vibeFolderName: ref.watch(
                                  libraryVibeCategoryNameProvider,
                                ),
                              ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final song = visible[index];
                      return SongListTile(
                        song: song,
                        onTap: () => ref
                            .read(playbackControllerProvider.notifier)
                            .playQueue(visible, startIndex: index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
