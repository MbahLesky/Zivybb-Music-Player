import 'package:flutter/material.dart';

/// Visual families for the app shell and surfaces.
enum AppThemeStyle {
  aurora,
  midnight,
  sunset,
  mist,
  vivid,
  bloom,
  glass,
  minimal;

  String get label => switch (this) {
    AppThemeStyle.aurora => 'Aurora',
    AppThemeStyle.midnight => 'Midnight',
    AppThemeStyle.sunset => 'Sunset',
    AppThemeStyle.mist => 'Mist',
    AppThemeStyle.vivid => 'Vivid',
    AppThemeStyle.bloom => 'Bloom',
    AppThemeStyle.glass => 'Glass',
    AppThemeStyle.minimal => 'Minimal',
  };

  String get description => switch (this) {
    AppThemeStyle.aurora => 'Soft gradients with a dreamy glow.',
    AppThemeStyle.midnight => 'Deep blue tones for a cinematic shell.',
    AppThemeStyle.sunset => 'Warm, energetic hues with a richer contrast.',
    AppThemeStyle.mist => 'Cool pastel tones with airy surfaces.',
    AppThemeStyle.vivid => 'Bold, saturated colors with a punchy feel.',
    AppThemeStyle.bloom => 'Balanced, clean colors that feel bright and airy.',
    AppThemeStyle.glass =>
      'Glass-like surfaces with extra blur and translucency.',
    AppThemeStyle.minimal => 'Clean, low-noise surfaces with a calm layout.',
  };
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required AppThemeStyle style,
  required Color seedColor,
}) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final styleColors = style.gradientColors();
  final primary = _mixColors(seedColor, styleColors.first, 0.6);
  final secondary = _mixColors(seedColor, styleColors[1], 0.45);
  final tertiary = _mixColors(seedColor, styleColors[2], 0.28);
  final isMinimal = style == AppThemeStyle.minimal;
  final isGlass = style == AppThemeStyle.glass;

  final surface = brightness == Brightness.dark
      ? (isMinimal ? const Color(0xFF090B12) : const Color(0xFF0B1020))
      : (isMinimal ? const Color(0xFFF8FAFC) : const Color(0xFFF7F9FF));
  final surfaceContainer = brightness == Brightness.dark
      ? (isMinimal ? const Color(0xFF121726) : const Color(0xFF16233A))
      : (isMinimal ? const Color(0xFFF1F5F9) : const Color(0xFFEFF4FF));
  final elevatedSurface = brightness == Brightness.dark
      ? const Color(0xFF111827).withValues(alpha: 0.86)
      : const Color(0xFFFFFFFF).withValues(alpha: 0.82);
  final borderColor = brightness == Brightness.dark
      ? (isMinimal
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.1))
      : (isMinimal
            ? primary.withValues(alpha: 0.16)
            : primary.withValues(alpha: 0.14));
  final shadowColor = brightness == Brightness.dark
      ? Colors.black.withValues(alpha: isMinimal ? 0.2 : 0.34)
      : Colors.black.withValues(alpha: isMinimal ? 0.06 : 0.08);

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

  final radius = BorderRadius.circular(
    isGlass
        ? 28
        : isMinimal
        ? 18
        : 24,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    visualDensity: VisualDensity.compact,
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minVerticalPadding: 6,
      minLeadingWidth: 24,
      iconColor: scheme.primary,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: borderColor),
      ),
      backgroundColor: elevatedSurface,
      selectedColor: primary.withValues(alpha: 0.2),
      side: BorderSide(color: borderColor),
      // The colour is not optional here. A ChipThemeData.labelStyle replaces
      // the Material default outright rather than merging with it (see
      // RawChip's `chipTheme.labelStyle ?? chipDefaults.labelStyle`), so
      // leaving it off dropped the default onSurfaceVariant and left chip
      // text inheriting whatever ambient style it happened to sit under —
      // which rendered it near-white, and invisible, in light mode.
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      secondaryLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 18),
      showCheckmark: false,
    ),
    dividerTheme: DividerThemeData(color: borderColor, thickness: 0.8),
    iconTheme: IconThemeData(color: scheme.primary),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: elevatedSurface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
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
        surfaceOpacity: style.surfaceOpacity,
        blurSigma: style.blurSigma,
      ),
    ],
  );
}

extension AppThemeStyleX on AppThemeStyle {
  List<Color> gradientColors() => switch (this) {
    AppThemeStyle.aurora => const [
      Color(0xFF7C3AED),
      Color(0xFF22D3EE),
      Color(0xFF34D399),
    ],
    AppThemeStyle.midnight => const [
      Color(0xFF4F46E5),
      Color(0xFF0EA5E9),
      Color(0xFF38BDF8),
    ],
    AppThemeStyle.sunset => const [
      Color(0xFFF59E0B),
      Color(0xFFFB7185),
      Color(0xFFEC4899),
    ],
    AppThemeStyle.mist => const [
      Color(0xFF14B8A6),
      Color(0xFF60A5FA),
      Color(0xFFA78BFA),
    ],
    AppThemeStyle.vivid => const [
      Color(0xFF8B5CF6),
      Color(0xFFF43F5E),
      Color(0xFFF59E0B),
    ],
    AppThemeStyle.bloom => const [
      Color(0xFF10B981),
      Color(0xFF34D399),
      Color(0xFFF9A8D4),
    ],
    AppThemeStyle.glass => const [
      Color(0xFF818CF8),
      Color(0xFF22D3EE),
      Color(0xFF67E8F9),
    ],
    AppThemeStyle.minimal => const [
      Color(0xFF64748B),
      Color(0xFF94A3B8),
      Color(0xFFE2E8F0),
    ],
  };

  double get surfaceOpacity => switch (this) {
    AppThemeStyle.glass => 0.72,
    AppThemeStyle.minimal => 0.92,
    AppThemeStyle.vivid => 0.84,
    _ => 0.8,
  };

  double get blurSigma => switch (this) {
    AppThemeStyle.glass => 24,
    AppThemeStyle.minimal => 0,
    _ => 16,
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
    required this.surfaceOpacity,
    required this.blurSigma,
  });

  final Color glassSurfaceColor;
  final Color borderColor;
  final Color shadowColor;
  final double surfaceOpacity;
  final double blurSigma;

  @override
  AppThemePalette copyWith({
    Color? glassSurfaceColor,
    Color? borderColor,
    Color? shadowColor,
    double? surfaceOpacity,
    double? blurSigma,
  }) {
    return AppThemePalette(
      glassSurfaceColor: glassSurfaceColor ?? this.glassSurfaceColor,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  AppThemePalette lerp(ThemeExtension<AppThemePalette>? other, double t) {
    if (other is! AppThemePalette) return this;
    return AppThemePalette(
      glassSurfaceColor:
          Color.lerp(glassSurfaceColor, other.glassSurfaceColor, t) ??
          glassSurfaceColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      surfaceOpacity: (1 - t) * surfaceOpacity + t * other.surfaceOpacity,
      blurSigma: (1 - t) * blurSigma + t * other.blurSigma,
    );
  }
}
