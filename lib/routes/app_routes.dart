import 'package:flutter/widgets.dart';

import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/liked_songs_screen.dart';
import '../features/playback/presentation/now_playing_screen.dart';

/// Every named route in the app, in one place.
abstract final class AppRoutes {
  static const library = '/';
  static const likedSongs = '/liked';
  static const nowPlaying = '/now-playing';

  static Map<String, WidgetBuilder> get routes => {
    library: (_) => const LibraryScreen(),
    likedSongs: (_) => const LikedSongsScreen(),
    nowPlaying: (_) => const NowPlayingScreen(),
  };
}
