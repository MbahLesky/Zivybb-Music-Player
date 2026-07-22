import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for Zivybb.
///
/// Both modes are defined from the same structure so a custom accent color
/// added later gets an appropriate counterpart in each mode rather than being
/// hardcoded to one brightness.
abstract final class AppTheme {
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: AppColors.warning,
      onError: Colors.black,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: surface,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: textPrimary,
          fontWeight: FontWeight.w400,
        ),
        subtitleTextStyle: TextStyle(fontSize: 13, color: textSecondary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: textSecondary.withValues(alpha: 0.3),
        thumbColor: primary,
        trackHeight: 3,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.15),
        space: 1,
      ),
    );
  }

  /// The type scale from the brand guide, mapped onto Material's slots.
  static TextTheme _textTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      // Display — Now Playing track title.
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      // Title — screen titles, playlist names.
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Body — song titles in lists, general copy.
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      // Caption — artist/album secondary text, timestamps.
      bodySmall: TextStyle(fontSize: 13, color: textSecondary),
      // Label — buttons, tags, chips.
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
    );
  }
}
