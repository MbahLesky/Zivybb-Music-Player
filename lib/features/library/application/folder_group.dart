import '../../../data/models/song.dart';

/// The songs found in one device folder, for the folder browser.
class FolderGroup {
  const FolderGroup({
    required this.path,
    required this.name,
    required this.songs,
  });

  final String path;
  final String name;
  final List<Song> songs;

  /// Combined running time of the folder, shown as its subtitle.
  Duration get totalDuration =>
      songs.fold(Duration.zero, (total, song) => total + song.duration);
}
