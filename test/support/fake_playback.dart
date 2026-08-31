import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/features/playback/application/playback_controller.dart';

/// A [PlaybackController] that holds a fixed state and never touches audio.
///
/// The real controller builds an `AudioPlayerService` in `build()`, which
/// needs platform channels, so any widget test reaching playback state has to
/// override it. This is the first such override in the project — keep it here
/// so later screen tests can reuse it rather than each growing their own.
class FakePlaybackController extends PlaybackController {
  FakePlaybackController({this.initial = const PlaybackState()});

  final PlaybackState initial;

  @override
  PlaybackState build() => initial;

  // Transport calls are no-ops: a widget test asserts what the screen renders
  // and hands off, not what the audio engine does with it.
  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> togglePlayPause() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> restoreSession() async {}
}

/// A queue of one, playing, for screens that only need "something is on".
PlaybackState playingState(Song song) =>
    PlaybackState(queue: [song], currentIndex: 0, isPlaying: true);

Song fakeSong({String id = '1', String title = 'Test Song'}) => Song(
  id: id,
  filePath: '/music/$id.mp3',
  title: title,
  artist: 'Artist',
  album: 'Album',
  duration: const Duration(minutes: 3),
);
