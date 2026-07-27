import 'package:flutter/material.dart';

/// Curated set of seed colors offered on the Theme Customization screen
/// (Screens.md #12). Kept small and deliberately picked rather than a full
/// color wheel, matching the "customizable but simple" scope of Version 1.
const themePalette = <Color>[
  Color(0xFF673AB7), // Deep purple (default)
  Color(0xFF3F51B5), // Indigo
  Color(0xFF2196F3), // Blue
  Color(0xFF009688), // Teal
  Color(0xFF4CAF50), // Green
  Color(0xFFFFC107), // Amber
  Color(0xFFFF9800), // Orange
  Color(0xFFF44336), // Red
  Color(0xFFE91E63), // Pink
  Color(0xFF795548), // Brown
];

/// Palette offered when picking a mood tag's color — brighter and more
/// varied than [themePalette] since moods benefit from being visually
/// distinct from one another at a glance.
const moodColorPalette = <Color>[
  Color(0xFFFF7043), // Energetic (orange)
  Color(0xFF4FC3F7), // Chill (light blue)
  Color(0xFFFFCA28), // Happy (yellow)
  Color(0xFF5C6BC0), // Sad (indigo)
  Color(0xFFE53935), // Angry (red)
  Color(0xFF66BB6A), // Relaxed (green)
  Color(0xFFAB47BC), // Purple
  Color(0xFF26A69A), // Teal
  Color(0xFFEC407A), // Pink
  Color(0xFF8D6E63), // Brown
];
