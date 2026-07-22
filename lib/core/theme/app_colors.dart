import 'package:flutter/material.dart';

/// The shipped default palette, per `docs/Interface-Design-Brand-Guide.md`.
///
/// User-selected themes replace the accent roles at runtime. The warning role
/// is deliberately excluded from theming so a missing file always reads the
/// same way regardless of the palette the user picked.
abstract final class AppColors {
  // Zivybb Dark — adaptive-mode base.
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkPrimary = Color(0xFF7C4DFF);
  static const darkSecondary = Color(0xFFFF6E6E);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFFA0A0A0);

  // Zivybb Light — adaptive daytime base.
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF6B3FD9);
  static const lightSecondary = Color(0xFFE85A5A);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6B6B6B);

  // Shared status colors — not themeable.
  static const success = Color(0xFF4CD97B);
  static const warning = Color(0xFFFFB020);
}
