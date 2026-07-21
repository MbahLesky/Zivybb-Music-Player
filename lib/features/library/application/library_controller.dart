import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/media_scanner_service.dart';
import '../../../data/datasources/app_database.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final mediaScannerServiceProvider = Provider<MediaScannerService>(
  (ref) => MediaScannerService(),
);

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(
    database: ref.watch(appDatabaseProvider),
    scanner: ref.watch(mediaScannerServiceProvider),
  );
});

/// The cached local library, updated live as the cache changes.
final libraryStreamProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchLibrary();
});

/// Triggers (and reports the status of) a device library scan.
class LibraryController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(songRepositoryProvider).refreshFromDevice(),
    );
  }
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, AsyncValue<void>>(
      LibraryController.new,
    );
