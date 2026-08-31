import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../features/playback/application/playback_controller.dart';
import 'gradient_button.dart';

/// Big "Play" and "Shuffle" header actions for folder and playlist screens:
/// play starts [songs] from the top; shuffle starts from a random track
/// with shuffle mode on.
class PlayShuffleHeader extends ConsumerWidget {
  const PlayShuffleHeader({
    super.key,
    required this.songs,
    this.sourcePlaylistId,
  });

  final List<Song> songs;
  final String? sourcePlaylistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientButton(
            icon: Icons.play_arrow,
            onPressed: songs.isEmpty
                ? null
                : () => controller.playQueue(
                    songs,
                    startIndex: 0,
                    sourcePlaylistId: sourcePlaylistId,
                  ),
            child: const Text('Play'),
          ),
          const SizedBox(width: 12),
          GradientButton(
            icon: Icons.shuffle,
            onPressed: songs.isEmpty
                ? null
                : () => controller.shuffleAndPlay(
                    songs,
                    sourcePlaylistId: sourcePlaylistId,
                  ),
            child: const Text('Shuffle'),
          ),
        ],
      ),
    );
  }
}
