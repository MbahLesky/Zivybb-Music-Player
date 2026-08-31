import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/library_source_filter.dart';
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

/// Every folder on the device holding audio, with its track count, whether
/// the current filter admits it or not. Feeds the Library Sources screen.
///
/// Auto-disposing because it reads the device rather than the cache: the
/// listing should be taken fresh each time that screen is opened rather than
/// held for the life of the app.
final deviceFoldersProvider =
    FutureProvider.autoDispose<List<({String path, int trackCount})>>((ref) {
      return ref.watch(songRepositoryProvider).deviceFolders();
    });

/// Triggers (and reports the status of) a device library scan.
class LibraryController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final settings = ref.read(settingsStreamProvider).value;
    state = await AsyncValue.guard(
      () => ref
          .read(songRepositoryProvider)
          .refreshFromDevice(
            includeVideos: settings?.includeVideos ?? false,
            filter:
                settings?.librarySourceFilter ?? const LibrarySourceFilter(),
          ),
    );
  }
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, AsyncValue<void>>(
      LibraryController.new,
    );
