import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/color_hex.dart';
import '../../features/vibe_tagging/application/vibe_tagging_controller.dart';

/// The vibes attached to a song, as compact labeled color chips. Renders
/// nothing when the song has no vibes, so it can sit unconditionally in a
/// list tile.
class VibeChips extends ConsumerWidget {
  const VibeChips({super.key, required this.songId, this.compact = true});

  final String songId;

  /// Slimmer chips for song list tiles; `false` gives the roomier chips
  /// used on the Now Playing screen.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibes = ref.watch(vibesForSongProvider(songId));
    if (vibes.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final labelStyle = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.labelMedium;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final vibe in vibes)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 10,
              vertical: compact ? 1 : 4,
            ),
            decoration: BoxDecoration(
              color: colorFromHex(vibe.colorHex).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colorFromHex(vibe.colorHex).withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 6 : 8,
                  height: compact ? 6 : 8,
                  decoration: BoxDecoration(
                    color: colorFromHex(vibe.colorHex),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: compact ? 4 : 6),
                Text(
                  vibe.label,
                  style: labelStyle?.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
