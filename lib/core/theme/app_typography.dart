import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography for LibConnect.
///
///   Display / titles → Lora (serif), weight 600
///   Body / UI         → Inter (sans), weight 400/500
///   Mono elements      → JetBrains Mono (call numbers, barcodes,
///                        due dates, balances, card numbers)
///
/// Widgets should pull styles from `Theme.of(context).textTheme` where
/// possible, and use the named helpers below (`AppTypography.mono`,
/// etc.) for the mono/display styles that don't have a direct
/// TextTheme slot.
class AppTypography {
  const AppTypography._();

  // ── Display / Lora ──────────────────────────────
  static TextStyle lora({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // ── Body / Inter ──────────────────────────────
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ── Mono / JetBrains Mono ──────────────────────────────
  // Used for: call numbers, barcodes, due dates, balances, card numbers.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Builds a full [TextTheme] for the given base ink color, mixing
  /// Lora (display/headline/title) with Inter (body/label).
  static TextTheme textTheme(Color inkColor) {
    return TextTheme(
      displayLarge: lora(fontSize: 32, color: inkColor),
      displayMedium: lora(fontSize: 28, color: inkColor),
      displaySmall: lora(fontSize: 24, color: inkColor),
      headlineLarge: lora(fontSize: 22, color: inkColor),
      headlineMedium: lora(fontSize: 20, color: inkColor),
      headlineSmall: lora(fontSize: 18, color: inkColor),
      titleLarge: lora(fontSize: 18, color: inkColor),
      titleMedium: lora(fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
      titleSmall: inter(fontSize: 14, fontWeight: FontWeight.w600, color: inkColor),
      bodyLarge: inter(fontSize: 16, color: inkColor),
      bodyMedium: inter(fontSize: 14, color: inkColor),
      bodySmall: inter(fontSize: 12, color: inkColor),
      labelLarge: inter(fontSize: 14, fontWeight: FontWeight.w500, color: inkColor),
      labelMedium: inter(fontSize: 12, fontWeight: FontWeight.w500, color: inkColor),
      labelSmall: inter(fontSize: 11, fontWeight: FontWeight.w500, color: inkColor),
    );
  }
}