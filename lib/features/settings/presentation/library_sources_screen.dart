import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/app_settings.dart';
import '../../../data/models/library_source_filter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../library/application/library_controller.dart';
import '../application/settings_controller.dart';

/// Chooses which of the device's audio files Zivybb treats as music
/// (Screens.md #11 ▸ Library).
///
/// A media store holds voice notes, call recordings and ringtones alongside
/// the actual music, and every one of them used to end up in the library and
/// in shuffle. This screen is where that is dialled in: a length floor, a
/// name-based guess at folders that don't hold music, and a switch per
/// folder that overrides both.
///
/// Every change rescans, because a filter that doesn't take effect until
/// some later scan reads as a broken switch.
class LibrarySourcesScreen extends ConsumerWidget {
  const LibrarySourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final filter = settings.librarySourceFilter;
    final folders = ref.watch(deviceFoldersProvider);
    final isScanning = ref.watch(libraryControllerProvider).isLoading;

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Library sources'),
        actions: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
      body: Container(
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Decide what counts as music. Anything switched off here is '
                'left out of the library, playlists and shuffle.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.filter_alt_outlined),
                      title: const Text('Skip non-music folders'),
                      subtitle: const Text(
                        'Leave out chat apps, recordings, ringtones and '
                        'alarms, going by the folder name',
                      ),
                      value: filter.autoExcludeNonMusicFolders,
                      onChanged: (enabled) => _apply(
                        ref,
                        filter.copyWith(autoExcludeNonMusicFolders: enabled),
                      ),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.timer_outlined),
                      title: Text('Minimum track length'),
                      subtitle: Text(
                        'Shorter clips are voice notes, not songs',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final choice
                              in LibrarySourceFilter.minimumDurationChoices)
                            ChoiceChip(
                              label: Text(_durationLabel(choice)),
                              selected: filter.minimumDuration == choice,
                              onSelected: (selected) {
                                if (!selected) return;
                                _apply(
                                  ref,
                                  filter.copyWith(minimumDuration: choice),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Folders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              folders.when(
                data: (list) => list.isEmpty
                    ? const GlassCard(
                        child: ListTile(
                          title: Text('No audio folders found on this device.'),
                        ),
                      )
                    : GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final folder in list)
                              _FolderTile(
                                path: folder.path,
                                trackCount: folder.trackCount,
                                filter: filter,
                                onChanged: (included) => _apply(
                                  ref,
                                  filter.withFolder(
                                    folder.path,
                                    included: included,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Could not read the device folders'),
                    subtitle: Text('$error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Persists [filter] and rescans, so the library on screen matches the
  /// switch the user just flipped.
  Future<void> _apply(WidgetRef ref, LibrarySourceFilter filter) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .setLibrarySourceFilter(filter);
    await ref.read(libraryControllerProvider.notifier).refresh();
  }

  static String _durationLabel(Duration duration) =>
      duration == Duration.zero ? 'No limit' : '${duration.inSeconds}s';
}

/// One folder row: its name, where it is, how much audio it holds, and
/// whether the library takes it.
class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.path,
    required this.trackCount,
    required this.filter,
    required this.onChanged,
  });

  final String path;
  final int trackCount;
  final LibrarySourceFilter filter;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final included = filter.allowsFolder(path);
    final byRule =
        !included &&
        !filter.isUserChoice(path) &&
        LibrarySourceFilter.looksLikeNonMusic(path);

    return SwitchListTile(
      title: Text(
        p.basename(path),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        byRule
            ? '$trackCount file${trackCount == 1 ? '' : 's'} · skipped as '
                  'non-music'
            : '$trackCount file${trackCount == 1 ? '' : 's'} · $path',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: included,
      onChanged: onChanged,
    );
  }
}
