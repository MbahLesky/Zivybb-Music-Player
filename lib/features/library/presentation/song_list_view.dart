import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../data/models/song.dart';
import '../../../shared/widgets/song_tile.dart';

/// A scrollable song list wired to playback and the liked state.
///
/// Every list of songs in the library goes through here so that tapping a
/// song, liking it, and hitting a missing file behave identically wherever the
/// list is shown.
class SongListView extends StatelessWidget {
  const SongListView({
    required this.songs,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    super.key,
  });

  final List<Song> songs;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);
    final playback = AppScope.playbackOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([library, playback]),
      builder: (context, _) {
        return ListView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            return SongTile(
              song: song,
              isCurrent: playback.currentSong?.id == song.id,
              onTap: () {
                if (song.isMissing) {
                  _reportMissing(context, song);
                  return;
                }
                playback.playQueue(songs, startIndex: index);
              },
              onToggleLiked: () async {
                playback.syncSong(await library.toggleLiked(song));
              },
            );
          },
        );
      },
    );
  }

  void _reportMissing(BuildContext context, Song song) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"${song.title}" is missing from storage.')),
      );
  }
}
