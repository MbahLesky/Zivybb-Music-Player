import '../../core/constants/mood_tags.dart';
import '../models/song.dart';

/// A fixed, in-memory library used until the device scanner lands.
///
/// This exists so the UI can be built and reviewed before permission handling
/// and the media query are wired up (Development Plan, Week 1 Day 2). None of
/// these paths point at real files — nothing here should outlive the scanner.
abstract final class SampleSongDataSource {
  static List<Song> load() {
    return const [
      Song(
        id: '1',
        filePath: '/storage/emulated/0/Music/Late Nights/Neon Rain.mp3',
        title: 'Neon Rain',
        artist: 'Vela Mori',
        album: 'Late Nights',
        duration: Duration(minutes: 3, seconds: 42),
        moodTagId: 'chill',
        isLiked: true,
      ),
      Song(
        id: '2',
        filePath: '/storage/emulated/0/Music/Late Nights/Slow Signal.mp3',
        title: 'Slow Signal',
        artist: 'Vela Mori',
        album: 'Late Nights',
        duration: Duration(minutes: 4, seconds: 15),
        moodTagId: 'chill',
      ),
      Song(
        id: '3',
        filePath: '/storage/emulated/0/Music/Late Nights/Afterglow.mp3',
        title: 'Afterglow',
        artist: 'Vela Mori',
        album: 'Late Nights',
        duration: Duration(minutes: 5, seconds: 3),
        moodTagId: 'sad',
      ),
      Song(
        id: '4',
        filePath: '/storage/emulated/0/Music/Workout/Redline.mp3',
        title: 'Redline',
        artist: 'Kito Sound',
        album: 'Pulse',
        duration: Duration(minutes: 2, seconds: 58),
        moodTagId: 'energetic',
        isLiked: true,
      ),
      Song(
        id: '5',
        filePath: '/storage/emulated/0/Music/Workout/Overdrive.mp3',
        title: 'Overdrive',
        artist: 'Kito Sound',
        album: 'Pulse',
        duration: Duration(minutes: 3, seconds: 21),
        moodTagId: 'energetic',
      ),
      Song(
        id: '6',
        filePath: '/storage/emulated/0/Music/Workout/Ignition.mp3',
        title: 'Ignition',
        artist: 'Bassline Theory',
        album: 'Kickstart',
        duration: Duration(minutes: 4, seconds: 6),
        moodTagId: 'energetic',
      ),
      Song(
        id: '7',
        filePath: '/storage/emulated/0/Music/Focus/Paper Planes.mp3',
        title: 'Paper Planes',
        artist: 'Anara',
        album: 'Long Form',
        duration: Duration(minutes: 6, seconds: 30),
        moodTagId: 'focus',
        isLiked: true,
      ),
      Song(
        id: '8',
        filePath: '/storage/emulated/0/Music/Focus/Static Fields.mp3',
        title: 'Static Fields',
        artist: 'Anara',
        album: 'Long Form',
        duration: Duration(minutes: 7, seconds: 12),
        moodTagId: 'focus',
      ),
      Song(
        id: '9',
        filePath: '/storage/emulated/0/Music/Focus/Low Tide.mp3',
        title: 'Low Tide',
        artist: 'Hollow Coast',
        album: 'Drift',
        duration: Duration(minutes: 5, seconds: 47),
        moodTagId: 'chill',
      ),
      Song(
        id: '10',
        filePath: '/storage/emulated/0/Download/Untitled Demo.mp3',
        title: 'Untitled Demo',
        artist: 'Unknown artist',
        album: 'Unknown album',
        duration: Duration(minutes: 1, seconds: 54),
      ),
      Song(
        id: '11',
        filePath: '/storage/emulated/0/Download/Voice Memo 04.m4a',
        title: 'Voice Memo 04',
        artist: 'Unknown artist',
        album: 'Unknown album',
        duration: Duration(seconds: 48),
      ),
      // Kept in the list to exercise the missing-file treatment in the UI.
      Song(
        id: '12',
        filePath: '/storage/emulated/0/Music/Late Nights/Ghost Track.mp3',
        title: 'Ghost Track',
        artist: 'Vela Mori',
        album: 'Late Nights',
        duration: Duration(minutes: 3, seconds: 9),
        moodTagId: 'sad',
        isMissing: true,
      ),
    ];
  }

  /// Guards against a mood id in the sample data drifting from the presets.
  static bool get moodIdsAreValid => load()
      .where((song) => song.moodTagId != null)
      .every((song) => MoodTags.byId(song.moodTagId) != null);
}
