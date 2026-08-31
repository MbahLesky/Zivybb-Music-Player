import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../vibe_tagging/application/vibe_tagging_controller.dart';
import '../application/library_controller.dart';
import '../application/library_view_controller.dart';

/// The one place any song list is narrowed and ordered.
///
/// Every list — All Songs, Liked, a device folder, a playlist — opens this
/// same sheet from [LibraryViewButton], so the options and their wording
/// never differ by screen. It edits the shared [libraryViewProvider], so a
/// choice made on one list is the choice on all of them.
class LibraryViewSheet extends ConsumerWidget {
  const LibraryViewSheet({super.key, this.showFolderFilter = true});

  /// Whether to offer the device-folder narrowing. Off for a list that is
  /// already one folder, where it could only ever empty the list.
  final bool showFolderFilter;

  static Future<void> show(
    BuildContext context, {
    bool showFolderFilter = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LibraryViewSheet(showFolderFilter: showFolderFilter),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(libraryViewProvider);
    final controller = ref.read(libraryViewProvider.notifier);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sort & filter',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (!view.isDefault)
                  TextButton(
                    onPressed: () => controller.state = const LibraryView(),
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _SectionLabel('Filter'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final option in LibraryFilterOption.values)
                  FilterChip(
                    label: Text(option.label),
                    selected: view.filters.contains(option),
                    onSelected: (_) => controller.state = view.toggling(option),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _VibeFolderFilter(),
            if (showFolderFilter) ...[
              const SizedBox(height: 8),
              const _DeviceFolderFilter(),
            ],
            const SizedBox(height: 16),
            _SectionLabel('Sort by'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final field in LibrarySortField.values)
                  ChoiceChip(
                    label: Text(field.label),
                    selected: view.sortField == field,
                    onSelected: (_) => controller.state = view.sortedBy(field),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // The direction reads in the words of the chosen field, so it is
            // never "ascending" with no clue what that means for play counts.
            SegmentedButton<SortDirection>(
              segments: [
                for (final direction in SortDirection.values)
                  ButtonSegment(
                    value: direction,
                    icon: Icon(
                      direction == SortDirection.ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 18,
                    ),
                    label: Text(view.sortField.directionLabel(direction)),
                  ),
              ],
              selected: {view.direction},
              // Marks the order as chosen, like picking a field does: a
              // playlist keeps its stored sequence until the user asks for
              // something else, and reversing is asking.
              onSelectionChanged: (selection) => controller.state = view
                  .copyWith(direction: selection.first, sortChosen: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Narrows to one vibe folder. Hidden entirely when no folders exist, rather
/// than showing a control with one useless entry in it.
class _VibeFolderFilter extends ConsumerWidget {
  const _VibeFolderFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(vibeCategoriesStreamProvider).value ?? const [];
    if (categories.isEmpty) return const SizedBox.shrink();
    final view = ref.watch(libraryViewProvider);

    return DropdownButtonFormField<String?>(
      initialValue: view.vibeCategoryId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Vibe folder',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Any folder')),
        for (final category in categories)
          DropdownMenuItem<String?>(
            value: category.id,
            child: Text(category.name),
          ),
      ],
      onChanged: (value) => ref.read(libraryViewProvider.notifier).state = view
          .copyWith(vibeCategoryId: value),
    );
  }
}

/// Narrows to one folder on the device — the "folders (sub filters)" of the
/// roadmap. Built from the library itself, so it lists exactly the folders
/// that actually hold songs.
class _DeviceFolderFilter extends ConsumerWidget {
  const _DeviceFolderFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryStreamProvider).value ?? const [];
    final folders =
        <String>{for (final song in songs) p.dirname(song.filePath)}.toList()
          ..sort(
            (a, b) => p
                .basename(a)
                .toLowerCase()
                .compareTo(p.basename(b).toLowerCase()),
          );
    if (folders.isEmpty) return const SizedBox.shrink();

    final view = ref.watch(libraryViewProvider);
    // A folder the library no longer holds (the filter narrowed it away, or
    // the song moved) would be a value with no matching item, which
    // DropdownButton asserts on.
    final selected = folders.contains(view.deviceFolder)
        ? view.deviceFolder
        : null;

    return DropdownButtonFormField<String?>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Folder',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Any folder')),
        for (final folder in folders)
          DropdownMenuItem<String?>(
            value: folder,
            child: Text(p.basename(folder), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) => ref.read(libraryViewProvider.notifier).state = view
          .copyWith(deviceFolder: value),
    );
  }
}

/// The search field and sort/filter button that sit above every song list.
///
/// One widget rather than each screen growing its own row, so All Songs, a
/// folder and a playlist all search and filter identically — which is what
/// "uniform in every page or list" asks for.
class LibraryViewControls extends ConsumerStatefulWidget {
  const LibraryViewControls({
    super.key,
    this.hint = 'Search title, artist, album',
    this.showFolderFilter = true,
  });

  final String hint;

  /// Off for a list that is already one folder, where narrowing by folder
  /// could only ever empty it.
  final bool showFolderFilter;

  @override
  ConsumerState<LibraryViewControls> createState() =>
      _LibraryViewControlsState();
}

class _LibraryViewControlsState extends ConsumerState<LibraryViewControls> {
  late final _controller = TextEditingController(
    text: ref.read(librarySearchQueryProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(librarySearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  ref.read(librarySearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                          ref.read(librarySearchQueryProvider.notifier).state =
                              '';
                        },
                      ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          LibraryViewButton(showFolderFilter: widget.showFolderFilter),
        ],
      ),
    );
  }
}

/// Names whichever of the search text and the filters are actually narrowing
/// a list, so a short list is always explained by controls the user can see.
String noMatchMessage({
  required String query,
  required LibraryView view,
  String? vibeFolderName,
}) {
  final narrowings = [
    if (query.trim().isNotEmpty) '"${query.trim()}"',
    for (final filter in LibraryFilterOption.values)
      if (view.filters.contains(filter)) '"${filter.label}"',
    if (vibeFolderName != null) 'the "$vibeFolderName" vibe folder',
    if (view.deviceFolder != null)
      'the "${p.basename(view.deviceFolder!)}" folder',
  ];
  if (narrowings.isEmpty) return 'No songs match.';
  if (narrowings.length == 1) return 'No songs match ${narrowings.first}.';
  final last = narrowings.removeLast();
  return 'No songs match ${narrowings.join(', ')} and $last.';
}

/// Opens [LibraryViewSheet], badged with how many filters are narrowing the
/// list.
///
/// The badge is the point: a list quietly hiding songs because of a filter
/// set on some other screen is confusing, and a count on the button is what
/// makes that visible without opening anything.
class LibraryViewButton extends ConsumerWidget {
  const LibraryViewButton({super.key, this.showFolderFilter = true});

  final bool showFolderFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(libraryViewProvider);
    final count = view.activeFilterCount;
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Sort & filter',
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: Icon(
          count > 0 ? Icons.filter_alt : Icons.filter_list,
          color: count > 0 ? scheme.primary : null,
        ),
      ),
      onPressed: () =>
          LibraryViewSheet.show(context, showFolderFilter: showFolderFilter),
    );
  }
}
