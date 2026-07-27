import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/equalizer_preset_repository.dart';
import '../../../data/repositories/mood_tag_repository.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../discovery/presentation/song_discovery_screen.dart';
import '../../playback/application/playback_controller.dart';
import '../../playlists/application/mood_playlist_generator.dart';
import '../../playlists/presentation/playlist_list_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/library_controller.dart';
import 'folder_browser_tab.dart';
import 'missing_files_screen.dart';

/// Primary landing screen: entry point to the user's local music
/// (Screens.md #2). Tabs cover All Songs, Playlists, Folders, and Liked.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(libraryControllerProvider.notifier).refresh();
      await ref.read(songRepositoryProvider).detectMissingFiles();
      await ref.read(moodTagRepositoryProvider).ensureSeeded();
      await ref.read(equalizerPresetRepositoryProvider).ensureSeeded();
      await ref.read(moodPlaylistGeneratorProvider).regenerateAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final missingCount =
        ref.watch(missingSongsStreamProvider).value?.length ?? 0;
    final library = ref.watch(libraryStreamProvider).value ?? const [];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: GradientAppBar(
          title: const Text('Zivybb'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Discover',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SongDiscoveryScreen()),
              ),
            ),
            IconButton(
              icon: Badge(
                label: Text('$missingCount'),
                isLabelVisible: missingCount > 0,
                child: const Icon(Icons.error_outline),
              ),
              tooltip: 'Missing files',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MissingFilesScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: AppRoutes.settings),
                  builder: (_) => const SettingsScreen(),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Playlists'),
              Tab(text: 'Folders'),
              Tab(text: 'Liked'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainerLow,
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(
            child: TabBarView(
              children: [
                _AllSongsTab(),
                PlaylistListScreen(),
                FolderBrowserTab(),
                _LikedSongsTab(),
              ],
            ),
          ),
        ),
        floatingActionButton: library.isEmpty
            ? null
            : GradientFab(
                icon: Icons.shuffle,
                tooltip: 'Shuffle play all',
                onPressed: () => ref
                    .read(playbackControllerProvider.notifier)
                    .shuffleAndPlay(library),
              ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }
}

class _AllSongsTab extends ConsumerWidget {
  const _AllSongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryStreamProvider);
    final scanStatus = ref.watch(libraryControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(libraryControllerProvider.notifier).refresh(),
      child: library.when(
        data: (songs) => _SongList(
          songs: songs,
          emptyMessage: scanStatus.isLoading
              ? 'Scanning your device for music…'
              : scanStatus.hasError
              ? 'Could not scan your music library. Pull down to try again.'
              : 'No songs found yet. Pull down to scan.',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load library: $error')),
      ),
    );
  }
}

class _LikedSongsTab extends ConsumerWidget {
  const _LikedSongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedSongsStreamProvider);

    return liked.when(
      data: (songs) =>
          _SongList(songs: songs, emptyMessage: 'No liked songs yet.'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load liked songs: $error')),
    );
  }
}

class _SongList extends ConsumerWidget {
  const _SongList({required this.songs, required this.emptyMessage});

  final List<Song> songs;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(emptyMessage, textAlign: TextAlign.center),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongListTile(
          song: song,
          onTap: () => ref
              .read(playbackControllerProvider.notifier)
              .playQueue(songs, startIndex: index),
        );
      },
    );
  }
}
