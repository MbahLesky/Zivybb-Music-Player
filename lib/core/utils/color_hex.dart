import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` string into a [Color]. Falls back to deep purple for
/// anything malformed rather than throwing, since this only ever reads
/// values this app itself wrote.
Color colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return const Color(0xFF673AB7);
  return Color(0xFF000000 | value);
}

/// Formats a [Color] as `#RRGGBB` (alpha is dropped; this app's palette is
/// always fully opaque).
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
