import 'package:flutter/material.dart';

import '../../data/models/mood_tag.dart';

/// A pill showing a song's mood.
///
/// The dot carries the mood color and the text carries the meaning, so the tag
/// is still readable without relying on color alone.
class MoodChip extends StatelessWidget {
  const MoodChip({required this.tag, this.onTap, super.key});

  final MoodTag tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: tag.color.withValues(alpha: 0.16),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tag.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(tag.label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
