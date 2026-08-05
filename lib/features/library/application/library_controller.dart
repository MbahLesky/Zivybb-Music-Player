import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';
import '../../settings/application/settings_controller.dart';

/// The cached local library, updated live as the cache changes.
final libraryStreamProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchLibrary();
});

/// Songs the user has marked as liked/favorite.
final likedSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchLikedSongs();
});

/// Triggers (and reports the status of) a device library scan.
class LibraryController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final includeVideos =
        ref.read(settingsStreamProvider).value?.includeVideos ?? false;
    state = await AsyncValue.guard(
      () => ref
          .read(songRepositoryProvider)
          .refreshFromDevice(includeVideos: includeVideos),
    );
  }
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, AsyncValue<void>>(
      LibraryController.new,
    );
