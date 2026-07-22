import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../routes/app_routes.dart';
import '../../playback/presentation/mini_player.dart';
import 'all_songs_tab.dart';
import 'folder_browser_tab.dart';
import 'playlists_tab.dart';

/// The app's landing screen: the whole library, three ways.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zivybb'),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.likedSongs),
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Liked songs',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Folders'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
        body: AnimatedBuilder(
          animation: library,
          builder: (context, _) {
            if (library.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return const TabBarView(
              children: [AllSongsTab(), FolderBrowserTab(), PlaylistsTab()],
            );
          },
        ),
      ),
    );
  }
}
