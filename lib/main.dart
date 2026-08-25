import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A manually-created container (rather than ProviderScope's own) so the
  // audio handler can be built and registered with AudioService before
  // runApp, while still sharing every provider with the rest of the app.
  final container = ProviderContainer();
  await AudioService.init(
    builder: () => container.read(audioHandlerProvider),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.lespa.zivybb.zivybb.audio',
      androidNotificationChannelName: 'Zivybb playback',
      // Must be a flat monochrome drawable. The default — mipmap/ic_launcher —
      // is an adaptive icon on Android 8+, which SystemUI cannot turn into a
      // status-bar icon: it fails to create the icon and shows no notification
      // at all.
      androidNotificationIcon: 'drawable/ic_notification',
      // Keeps the foreground service alive through pause (rather than the
      // default of stopping it) so resuming playback from the lock screen
      // never hits Android 12+'s ForegroundServiceStartNotAllowedException.
      androidStopForegroundOnPause: false,
    ),
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const ZivybbApp()),
  );
}

// TODO 1: Beat-reactive wave visualizer:
// Amplitude/beat analysis pipeline and rendering widget, performance-tuned with automatic changing in color (option in settings)

// TODO 2: Moods, rename to Vibe, be able to set multiple vibes to 1 song. Display vibes with their colors.

// TODO 3: UI polish pass, accessibility check (contrast, touch targets), full manual regression test across all screens, bug fixing.

// TODO 4: More/Full equalizer setting. (Not just defined presets)

// TODO 5: Search. Search option in home screen, folders and playlist (even when adding some to playlist)

// TODO 6: Playlist, add button in player screen to view playlist. Add options to sort the playlist by name, length, etc. Shuffle option scrambles the playlist and play from there. The use should be able to see the songs playing

// TODO 7: Player Screen, extend the screen to full the whole view. But position the Main buttons where UX will be good. Instead of shuffle and repeat, add icon buttons to go back for forward for n seconds where n is defined in settings, but default is 10 seconds. Move the shuffle and repeat buttons bellow.

// TODO 8: Removing Visualizer setting(s) from Theme

// TODO 9: Check an work on some of the state change for elements such as radio buttons, switches, and icon buttons.

// TODO 10: Have the option in settings to play videos to (but as music only)

// TODO 11: Display the mini player everywhere except in the Full Screen Player and Settings. Display it in playlist, folders, etc.

// TODO 12: Folders and Playlist should have options to search, sort and filter. They should also have a big play button to start playing from the start and a shuffle button to start playing from anywhere and shuffle.
