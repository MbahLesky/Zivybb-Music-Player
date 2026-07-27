import 'package:flutter/material.dart';

/// Gradients derived from the current [ColorScheme], so they follow the
/// user's chosen theme color and adapt to light/dark automatically instead
/// of hardcoding a palette.
class AppGradients {
  const AppGradients._();

  /// Bold two-tone gradient for app bars, primary buttons, and the Now
  /// Playing backdrop.
  static LinearGradient primary(ColorScheme scheme) {
    return LinearGradient(
      colors: [scheme.primary, scheme.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Softer gradient for cards and section backgrounds.
  static LinearGradient surface(ColorScheme scheme) {
    return LinearGradient(
      colors: [scheme.primaryContainer, scheme.surface],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
