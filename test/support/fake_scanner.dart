import 'package:zivybb/core/services/media_scanner_service.dart';
import 'package:zivybb/data/models/song.dart';

/// Stands in for the device media store so repository tests never touch a
/// platform channel.
///
/// Returns whatever it was built with, which lets a test stage an exact
/// "rescan" result — including one that deliberately omits a field, to check
/// what the cache does with a scan that comes back incomplete.
class FakeScanner implements MediaScannerService {
  FakeScanner([this.songs = const []]);

  final List<Song> songs;

  @override
  Future<bool> hasLibraryAccess() async => true;

  @override
  Future<List<Song>> scanLibrary({bool includeVideos = false}) async => songs;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
