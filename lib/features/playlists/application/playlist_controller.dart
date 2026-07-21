import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/playlist.dart';
import '../../../data/repositories/playlist_repository.dart';

final playlistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  return ref.watch(playlistRepositoryProvider).watchPlaylists();
});

final playlistDetailProvider =
    StreamProvider.family<PlaylistWithSongs?, String>((ref, playlistId) {
      return ref
          .watch(playlistRepositoryProvider)
          .watchPlaylistWithSongs(playlistId);
    });
