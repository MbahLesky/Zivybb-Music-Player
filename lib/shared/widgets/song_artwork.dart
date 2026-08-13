import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../../data/models/song.dart';

/// A song's album art, falling back to an icon when there is none.
///
/// Videos never reach the artwork query: their ids are namespaced (see
/// [videoSongIdPrefix]) and so aren't the numeric MediaStore.Audio ids the
/// query expects — passing one through would throw. They get a film icon
/// instead, which doubles as the badge identifying them in the player.
class SongArtwork extends StatelessWidget {
  const SongArtwork({
    super.key,
    required this.song,
    required this.size,
    this.borderRadius = 12,
    this.iconSize,
    this.fallback,
  });

  final Song song;
  final double size;
  final double borderRadius;
  final double? iconSize;

  /// Shown in place of the icon placeholder when the song has no artwork —
  /// Now Playing passes a visualizer here when the user has asked for one.
  /// Must size itself to [size]; it fills the same slot the art would.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: song.isVideo
          ? fallback ?? _placeholder(context, Icons.movie_outlined)
          : QueryArtworkWidget(
              id: int.parse(song.id),
              type: ArtworkType.AUDIO,
              artworkWidth: size,
              artworkHeight: size,
              artworkFit: BoxFit.cover,
              nullArtworkWidget:
                  fallback ?? _placeholder(context, Icons.music_note),
            ),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      color: scheme.surfaceContainerHighest,
      child: Icon(icon, size: iconSize, color: scheme.onSurfaceVariant),
    );
  }
}
