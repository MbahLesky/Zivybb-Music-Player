/// The 8px spacing grid defined in the brand guide.
///
/// [xs] is the only sub-8 value and is reserved for tight inline gaps such as
/// icon-to-label spacing.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Standard horizontal padding for screen content.
  static const double screenHorizontal = 16;

  /// Corner radius for cards and other elevated surfaces.
  static const double cardRadius = 12;

  /// Minimum tap target, per the accessibility rules in the brand guide.
  static const double minTouchTarget = 48;
}
