import 'package:flutter/widgets.dart';

import 'core/services/simulated_audio_engine.dart';
import 'data/repositories/in_memory_song_repository.dart';
import 'data/repositories/song_repository.dart';
import 'features/library/application/library_controller.dart';
import 'features/playback/application/playback_controller.dart';

/// Creates the app's controllers and hands them to the widget tree.
///
/// State management is plain [ChangeNotifier] plus an [InheritedWidget]: the
/// app has exactly two long-lived controllers, so a package would add a
/// dependency without removing any work. Revisit if that count grows.
class AppScope extends StatefulWidget {
  const AppScope({required this.child, this.songRepository, super.key});

  final Widget child;

  /// Injection seam for tests; defaults to the in-memory library.
  final SongRepository? songRepository;

  static LibraryController libraryOf(BuildContext context) =>
      _inheritedOf(context).library;

  static PlaybackController playbackOf(BuildContext context) =>
      _inheritedOf(context).playback;

  static _AppScopeBindings _inheritedOf(BuildContext context) {
    final bindings = context
        .dependOnInheritedWidgetOfExactType<_AppScopeBindings>();
    assert(bindings != null, 'No AppScope found above this widget.');
    return bindings!;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final LibraryController _library;
  late final PlaybackController _playback;

  @override
  void initState() {
    super.initState();
    _library = LibraryController(
      repository: widget.songRepository ?? InMemorySongRepository(),
    );
    _playback = PlaybackController(engine: SimulatedAudioEngine());
    _library.load();
  }

  @override
  void dispose() {
    _playback.dispose();
    _library.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppScopeBindings(
      library: _library,
      playback: _playback,
      child: widget.child,
    );
  }
}

class _AppScopeBindings extends InheritedWidget {
  const _AppScopeBindings({
    required this.library,
    required this.playback,
    required super.child,
  });

  final LibraryController library;
  final PlaybackController playback;

  // The controllers are created once and never swapped, so dependents only
  // need to rebuild when a controller notifies, not when this widget rebuilds.
  @override
  bool updateShouldNotify(_AppScopeBindings oldWidget) => false;
}
