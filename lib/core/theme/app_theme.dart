import 'package:flutter/material.dart';

/// Visual families for the app shell and surfaces.
enum AppThemeStyle {
  aurora,
  midnight,
  sunset,
  mist;

  String get label => switch (this) {
    AppThemeStyle.aurora => 'Aurora',
    AppThemeStyle.midnight => 'Midnight',
    AppThemeStyle.sunset => 'Sunset',
    AppThemeStyle.mist => 'Mist',
  };
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required AppThemeStyle style,
  required Color seedColor,
}) {
  final baseScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  final styleColors = style.gradientColors();
  final primary = _mixColors(seedColor, styleColors.first, 0.6);
  final secondary = _mixColors(seedColor, styleColors[1], 0.45);
  final tertiary = _mixColors(seedColor, styleColors[2], 0.28);

  final surface = brightness == Brightness.dark
      ? const Color(0xFF0B1020)
      : const Color(0xFFF7F9FF);
  final surfaceContainer = brightness == Brightness.dark
      ? const Color(0xFF16233A)
      : const Color(0xFFEFF4FF);
  final elevatedSurface = brightness == Brightness.dark
      ? const Color(0xFF111827).withValues(alpha: 0.86)
      : const Color(0xFFFFFFFF).withValues(alpha: 0.82);
  final borderColor = brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.1)
      : primary.withValues(alpha: 0.14);
  final shadowColor = brightness == Brightness.dark
      ? Colors.black.withValues(alpha: 0.34)
      : Colors.black.withValues(alpha: 0.08);

  final scheme = baseScheme.copyWith(
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    tertiary: tertiary,
    surface: surface,
    onSurface: brightness == Brightness.dark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0F172A),
    surfaceContainer: surfaceContainer,
    surfaceContainerLow: surfaceContainer.withValues(alpha: 0.76),
    surfaceContainerHigh: surfaceContainer.withValues(alpha: 0.95),
    surfaceContainerHighest: elevatedSurface,
    primaryContainer: primary.withValues(alpha: 0.16),
    secondaryContainer: secondary.withValues(alpha: 0.16),
    tertiaryContainer: tertiary.withValues(alpha: 0.16),
    outlineVariant: borderColor,
  );

  final radius = BorderRadius.circular(24);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF050816)
        : const Color(0xFFF6F8FF),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: scheme.onPrimary),
    ),
    cardTheme: CardThemeData(
      color: elevatedSurface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: borderColor)),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: borderColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconColor: scheme.primary,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: borderColor)),
      backgroundColor: elevatedSurface,
      selectedColor: primary.withValues(alpha: 0.2),
      side: BorderSide(color: borderColor),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      showCheckmark: false,
    ),
    dividerTheme: DividerThemeData(color: borderColor, thickness: 0.8),
    iconTheme: IconThemeData(color: scheme.primary),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: elevatedSurface,
      filled: true,
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: primary, width: 1.4)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      thumbColor: primary,
      inactiveTrackColor: borderColor,
      overlayColor: primary.withValues(alpha: 0.12),
      valueIndicatorColor: primary,
      valueIndicatorTextStyle: TextStyle(color: scheme.onPrimary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return brightness == Brightness.dark ? Colors.white : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.4);
        }
        return borderColor;
      }),
    ),
    textTheme: ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.primary,
        backgroundColor: elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: elevatedSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    extensions: [
      AppThemePalette(
        glassSurfaceColor: elevatedSurface,
        borderColor: borderColor,
        shadowColor: shadowColor,
      ),
    ],
  );
}

extension AppThemeStyleX on AppThemeStyle {
  List<Color> gradientColors() => switch (this) {
    AppThemeStyle.aurora => const [Color(0xFF7C3AED), Color(0xFF22D3EE), Color(0xFF34D399)],
    AppThemeStyle.midnight => const [Color(0xFF4F46E5), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    AppThemeStyle.sunset => const [Color(0xFFF59E0B), Color(0xFFFB7185), Color(0xFFEC4899)],
    AppThemeStyle.mist => const [Color(0xFF14B8A6), Color(0xFF60A5FA), Color(0xFFA78BFA)],
  };
}

Color _mixColors(Color a, Color b, double amount) {
  return Color.lerp(a, b, amount) ?? a;
}

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.glassSurfaceColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color glassSurfaceColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  AppThemePalette copyWith({
    Color? glassSurfaceColor,
    Color? borderColor,
    Color? shadowColor,
  }) {
    return AppThemePalette(
      glassSurfaceColor: glassSurfaceColor ?? this.glassSurfaceColor,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AppThemePalette lerp(ThemeExtension<AppThemePalette>? other, double t) {
    if (other is! AppThemePalette) return this;
    return AppThemePalette(
      glassSurfaceColor: Color.lerp(glassSurfaceColor, other.glassSurfaceColor, t) ?? glassSurfaceColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
    );
  }
}
