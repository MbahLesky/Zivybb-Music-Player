import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/song_search.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../library/application/library_controller.dart';
import '../application/playlist_controller.dart';

/// Lets the user add library songs to a playlist (Screens.md #5: "add/remove
/// songs"), with search. Stays open after each tap so multiple songs can be
/// added.
///
/// Which songs are already in the playlist is read live rather than passed
/// in: the sheet stays open across additions, so a song just added has to
/// drop out of the list instead of sitting there re-tappable.
class AddSongsSheet extends ConsumerStatefulWidget {
  const AddSongsSheet({super.key, required this.playlistId});

  final String playlistId;

  static Future<void> show(BuildContext context, String playlistId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddSongsSheet(playlistId: playlistId),
    );
  }

  @override
  ConsumerState<AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends ConsumerState<AddSongsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryStreamProvider);
    final existingSongIds = {
      for (final song
          in ref
                  .watch(playlistDetailProvider(widget.playlistId))
                  .value
                  ?.songs ??
              const <Song>[])
        song.id,
    };

    return Padding(
      // Keeps the list visible above the on-screen keyboard while searching.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => library.when(
          data: (songs) {
            final available = songs
                .where(
                  (song) =>
                      !existingSongIds.contains(song.id) &&
                      songMatchesQuery(song, _query),
                )
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: AppSearchField(
                    hint: 'Search songs',
                    onChanged: (query) => setState(() => _query = query),
                  ),
                ),
                Expanded(
                  child: available.isEmpty
                      ? Center(
                          child: Text(
                            _query.trim().isEmpty
                                ? 'All songs are already in this playlist.'
                                : 'No songs match your search.',
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: available.length,
                          itemBuilder: (context, index) {
                            final song = available[index];
                            return ListTile(
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.add),
                              onTap: () => ref
                                  .read(playlistRepositoryProvider)
                                  .addSong(widget.playlistId, song.id),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Failed to load songs: $error')),
        ),
      ),
    );
  }
}
