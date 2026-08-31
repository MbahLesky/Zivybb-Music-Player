import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/equalizer_preset_repository.dart';
import '../../../data/repositories/vibe_tag_repository.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../../shared/widgets/zivybb_logo.dart';
import '../../discovery/presentation/song_discovery_screen.dart';
import '../../playback/application/playback_controller.dart';
import '../../playlists/application/vibe_playlist_generator.dart';
import '../../playlists/presentation/playlist_list_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../vibe_tagging/application/vibe_tagging_controller.dart';
import '../application/library_controller.dart';
import '../application/library_view_controller.dart';
import 'folder_browser_tab.dart';
import 'library_view_sheet.dart';
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
      // Restored first, and from the cached library rather than a fresh
      // device scan, so the mini player is back within a frame or two
      // instead of after a full rescan.
      await ref.read(playbackControllerProvider.notifier).restoreSession();
      await ref.read(libraryControllerProvider.notifier).refresh();
      // Strictly after the library scan's own permission prompt, and never
      // from main(): permission_handler rejects a request made while another
      // is still in flight, so firing this at startup raced the media prompt
      // and was the request that tended to lose — leaving Android 13+ with no
      // permission to post the playback notification and no second ask.
      await _requestNotificationPermission();
      await ref.read(songRepositoryProvider).detectMissingFiles();
      await ref.read(vibeTagRepositoryProvider).ensureSeeded();
      await ref.read(equalizerPresetRepositoryProvider).ensureSeeded();
      await ref.read(vibePlaylistGeneratorProvider).regenerateAll();
    });
  }

  /// Asks for POST_NOTIFICATIONS (Android 13+), which the playback
  /// notification and its lock-screen controls cannot appear without.
  ///
  /// Best-effort by design: playback itself works either way, so a refusal
  /// is not worth blocking the library on. Only ever prompts when the
  /// permission is still undecided — `request()` on a permanently denied
  /// permission returns immediately without a dialog, and re-asking every
  /// launch would be noise.
  Future<void> _requestNotificationPermission() async {
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } on MissingPluginException {
      // No permission plugin on this platform (or in tests).
    } on PlatformException {
      // Nothing actionable — the notification simply won't appear.
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingCount =
        ref.watch(missingSongsStreamProvider).value?.length ?? 0;
    final library = ref.watch(libraryStreamProvider).value ?? const [];
    // The shuffle button honours whatever the user has filtered down to, so
    // "shuffle all" never silently reaches past a search they can see.
    final shuffleable = applyLibraryView(
      library,
      query: ref.watch(librarySearchQueryProvider),
      view: ref.watch(libraryViewProvider),
      vibeTaggedSongIds: ref.watch(vibeTaggedSongIdsProvider),
      restrictToSongIds: ref.watch(libraryVibeCategoryRestrictionProvider),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: GradientAppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ZivybbLogo(size: 28),
              const SizedBox(width: 10),
              const Text('Zivybb'),
            ],
          ),
          actions: [
            AppBarIconAction(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Discover',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SongDiscoveryScreen()),
              ),
            ),
            AppBarIconAction(
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
            AppBarIconAction(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: AppRoutes.settings),
                  builder: (_) => const SettingsScreen(),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surfaceContainerLow,
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: TabBar(
                        dividerHeight: 0,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                        indicatorSize: TabBarIndicatorSize.tab,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        indicator: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                        labelColor: theme.colorScheme.onPrimaryContainer,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        labelStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Songs'),
                          Tab(text: 'Playlists'),
                          Tab(text: 'Folders'),
                          Tab(text: 'Liked'),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          _AllSongsTab(),
                          PlaylistListScreen(),
                          FolderBrowserTab(),
                          _LikedSongsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: shuffleable.isEmpty
            ? null
            : GradientFab(
                icon: Icons.shuffle,
                tooltip: 'Shuffle play all',
                onPressed: () => ref
                    .read(playbackControllerProvider.notifier)
                    .shuffleAndPlay(shuffleable),
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

/// A searchable, sortable song list — the shared body of the Songs and Liked
/// tabs. Both share one search query and sort order, so switching tabs keeps
/// whatever view the user set up.
class _SongList extends ConsumerWidget {
  const _SongList({required this.songs, required this.emptyMessage});

  /// The unfiltered list; search and sort are applied here.
  final List<Song> songs;

  /// Shown when [songs] itself is empty (as opposed to being filtered empty,
  /// which gets a "no matches" message instead).
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(librarySearchQueryProvider);
    final view = ref.watch(libraryViewProvider);
    final visible = applyLibraryView(
      songs,
      query: query,
      view: view,
      vibeTaggedSongIds: ref.watch(vibeTaggedSongIdsProvider),
      restrictToSongIds: ref.watch(libraryVibeCategoryRestrictionProvider),
    );
    final folderName = ref.watch(libraryVibeCategoryNameProvider);

    return Column(
      children: [
        const LibraryViewControls(),
        Expanded(
          child: visible.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          songs.isEmpty
                              ? emptyMessage
                              : noMatchMessage(
                                  query: query,
                                  view: view,
                                  vibeFolderName: folderName,
                                ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
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
    );
  }
}
