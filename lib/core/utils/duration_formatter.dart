/// Formats a [Duration] as `m:ss`, or `h:mm:ss` past the hour mark.
String formatTrackDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  final paddedSeconds = seconds.toString().padLeft(2, '0');
  if (hours == 0) return '$minutes:$paddedSeconds';

  return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
}
