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

// The current roadmap. Items are marked DONE with the version that shipped
// them; what is still TODO is the remaining work, in no fixed order.

// DONE 1 (1.2.0; board fixed in 1.4.0): Add a New Feature. It's a gamification feature. First remove the equalizer button from the appbar in the playing now screen. Instead add the equalizer option in the more options (under Edit Tags). Then place the gamification icon in the appbar or the now playing screen. It works like this; When a user clicks on the button, either the interface changes to or opens gamification layout/screen opens. The interface or layout has just 3 parts. The first part displays the artwork of the music while the second part which is below the artwork displays the game. The game is like the music piano tile game. Where tiles come up based on the beats of the music. The lengths of the tiles can be based on the beats. The color of the tiles should be that of the visualizer and properties (length and others) should be based on the visualizer. Generally it's like a version of the visualizer but is clickable as the come up. Score per music should be calculated and displayed with highscore stored. The current score while playing should be displayed against the high score. As for the 3rd part, it's just the prev/pause/next buttons with the Song Title and the Score and Highscore displayed. This can be displayed above or below the artwork. (The artwork will later be used to display ads)

// TODO 2: Add a home widget

// DONE 3 (1.3.0): Swiping left or right on the now playing screen, goes to the previous or the next song. Swiping up or down, increases or reduces the volume. The swipe should be done where there aren't controls or sliders (the slider area and above)

// DONE 4 (1.3.0): Playlist Access. Right now, every song and audio in my device is been played. Even recorded voicenotes send by people in whatsapp, which is not suppose to be so. Let's fix that.

// DONE 5 (1.4.0): For sort and filter, the should be uniform in every page or list with Options to sort by Date Added, Title, Length, Artist, Album, Most Played, Least Played, Recently Played and then the option whether to sort in Ascending or Decending (reverse) order.

// DONE 6 (1.4.0): Beat-reactive wave visualizer: Some beats or some music general have low beats while some high beats, make the visualizer to reflect that, from the visualizer, I should be able to know if it's a slow song or hard song or one with hard beats. You should understand the point. Another example, as most songs end, they bars gradually drop as it starts the increase.

// DONE 7 (1.2.1): Fix the playback problem, sometimes, it's not responsive. At times, the slider doesn't work as if it's disabled, neither does the next, prev or pause buttons. This may or may not have to do with crossfade, especially crossfade for shorter songs.

// DONE 8 (1.2.1): Similar to the problem above, when a song playing starts to end, the next song starts crossfading, but when the song ends completely, instead of continuing with the song which started crossfading, it plays another song (probably the next after) entirely.

// DONE 9 (1.4.0): As the option to display the visualizer as/where the slider music track/seek bar is, what I meant was display it as a seek bar, that is the visualizer becomes the seek bar, but this option will work depending on the visualizer style. For example, Styles like bars, mirror, line, and ribbon will work well for horizontal tracks. If set them to be the seek bar; set the unplayed part to some grey color, while the played part takes the visualizer theme color. For styles, such as Radial, and Particles, use a circular seekbar; automatically, they fill the place for the artwork. It any case like that, the artwork displays in them (the circle inside). As for the bloom style, the option to set as seek bar is disabled.

// DONE 10 (1.3.0): Have an option in the now playing screen to display a minimal version of the now playing (Display on the artboard (based on user settings where or not to display), the title, prev button, pause/play, next button, next, vibe icon, and more). No album, no vibes, all. Move the add to playlist buttons, shuffle, repeat to the more options.

// DONE 11 (1.3.0): Display the mini player in settings too.

// DONE 12 (1.2.0, policy in docs/Coding-Standards.md §10.1): This may be a lot to do, so start with 1 or group them. And for each one you do, increase the version number depending on the task. But start with the new feature of gamification, which will probably be 1.2.0 or 2.0.0 and then for the other little changes and additions, increase the version number accordingly. Add this to the relevant documentation, that for any change, the version number should be updated depending on the weight of the change.
