import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../playback/application/playback_controller.dart';
import '../../../shared/widgets/mini_player.dart';
import '../application/library_controller.dart';

/// Primary landing screen: entry point to the user's local music.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(libraryControllerProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryStreamProvider);
    final scanStatus = ref.watch(libraryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zivybb')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(libraryControllerProvider.notifier).refresh(),
        child: library.when(
          data: (songs) => _LibraryList(songs: songs, scanStatus: scanStatus),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Failed to load library: $error')),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

class _LibraryList extends ConsumerWidget {
  const _LibraryList({required this.songs, required this.scanStatus});

  final List<Song> songs;
  final AsyncValue<void> scanStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                scanStatus.isLoading
                    ? 'Scanning your device for music…'
                    : scanStatus.hasError
                    ? 'Could not access your music library.\n${scanStatus.error}'
                    : 'No songs found yet. Pull down to scan.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text('${song.artist} — ${song.album}'),
          onTap: () => ref
              .read(playbackControllerProvider.notifier)
              .playQueue(songs, startIndex: index),
        );
      },
    );
  }
}
