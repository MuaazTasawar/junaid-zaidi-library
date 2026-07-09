import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for LibConnect.
///
/// Consumed by `app.dart` (wired in Phase 6) as:
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: <driven by AppThemeCubit>,
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: AppColorExtension.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: AppColorExtension.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorExtension colors,
  }) {
    final ColorScheme colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.gold,
      onSecondary: colors.inkText,
      error: colors.stamp,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.inkText,
    )
        : ColorScheme.dark(
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.gold,
      onSecondary: colors.inkText,
      error: colors.stamp,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.inkText,
    );

    final TextTheme textTheme = AppTypography.textTheme(colors.inkText);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.inkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.lora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.inkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.slate.withOpacity(0.12)),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.slate.withOpacity(0.16),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.slate.withOpacity(0.3),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.inkText,
          side: BorderSide(color: colors.slate.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTypography.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.stamp),
        ),
        hintStyle: AppTypography.inter(color: colors.slate),
        labelStyle: AppTypography.inter(color: colors.slate),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.slate,
        selectedLabelStyle: AppTypography.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.inter(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.primary.withOpacity(0.15),
        labelStyle: AppTypography.inter(fontSize: 13, color: colors.inkText),
        side: BorderSide(color: colors.slate.withOpacity(0.25)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inkText,
        contentTextStyle: AppTypography.inter(color: colors.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}