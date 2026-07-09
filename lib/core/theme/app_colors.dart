import 'package:flutter/material.dart';

/// Raw hex palette for LibConnect, exactly as specified in the design
/// system. These constants are ONLY ever consumed by [AppTheme] to
/// build [ThemeData] + [AppColorExtension]. Widgets must never import
/// this file directly — always go through `Theme.of(context)` or the
/// `context.libColors` extension (see bottom of this file).
class AppColors {
  const AppColors._();

  // ── Light mode ──────────────────────────────
  static const Color lightBackground = Color(0xFFFAF6EE); // warm paper
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInkText = Color(0xFF1C2430);
  static const Color lightPrimary = Color(0xFF2F5233); // book-spine green
  static const Color lightSlate = Color(0xFF6B7280);
  static const Color lightStamp = Color(0xFFC1442D); // terracotta — overdue
  static const Color lightGold = Color(0xFFC9A227); // due-soon warning

  // ── Dark mode ──────────────────────────────
  static const Color darkBackground = Color(0xFF14181F);
  static const Color darkSurface = Color(0xFF1E2530);
  static const Color darkInkText = Color(0xFFF2EFE6);
  static const Color darkPrimary = Color(0xFF4F8059);
  static const Color darkSlate = Color(0xFF9CA3AF);
  static const Color darkStamp = Color(0xFFE2674A);
  static const Color darkGold = Color(0xFFC9A227);

  // ── Subject → cover colors (body / spine) ──────────────────────────────
  // Used exclusively by core/utils/cover_color_resolver.dart (Phase 6).
  static const Color subjectComputerScienceBody = Color(0xFF2F5233);
  static const Color subjectComputerScienceSpine = Color(0xFF1F3A23);

  static const Color subjectMathematicsBody = Color(0xFF2C4A66);
  static const Color subjectMathematicsSpine = Color(0xFF1C324A);

  static const Color subjectLiteratureBody = Color(0xFF6B4226);
  static const Color subjectLiteratureSpine = Color(0xFF4A2D19);

  static const Color subjectPhysicsBody = Color(0xFF4A3B6B);
  static const Color subjectPhysicsSpine = Color(0xFF332A4F);

  static const Color subjectEngineeringBody = Color(0xFF2F5233);
  static const Color subjectEngineeringSpine = Color(0xFF1F3A23);

  static const Color subjectBusinessBody = Color(0xFF5C4A2A);
  static const Color subjectBusinessSpine = Color(0xFF3D3019);

  static const Color subjectDefaultBody = Color(0xFF3D4A56);
  static const Color subjectDefaultSpine = Color(0xFF2A333D);
}

/// Custom [ThemeExtension] carrying the LibConnect-specific palette
/// (background / surface / inkText / primary / slate / stamp / gold)
/// that doesn't map cleanly onto Flutter's built-in [ColorScheme].
///
/// Widgets access this via `context.libColors.<field>` — never via
/// hardcoded [Color] literals (Golden Rule #3).
@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.background,
    required this.surface,
    required this.inkText,
    required this.primary,
    required this.slate,
    required this.stamp,
    required this.gold,
  });

  final Color background;
  final Color surface;
  final Color inkText;
  final Color primary;
  final Color slate;
  final Color stamp;
  final Color gold;

  static const AppColorExtension light = AppColorExtension(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    inkText: AppColors.lightInkText,
    primary: AppColors.lightPrimary,
    slate: AppColors.lightSlate,
    stamp: AppColors.lightStamp,
    gold: AppColors.lightGold,
  );

  static const AppColorExtension dark = AppColorExtension(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    inkText: AppColors.darkInkText,
    primary: AppColors.darkPrimary,
    slate: AppColors.darkSlate,
    stamp: AppColors.darkStamp,
    gold: AppColors.darkGold,
  );

  @override
  AppColorExtension copyWith({
    Color? background,
    Color? surface,
    Color? inkText,
    Color? primary,
    Color? slate,
    Color? stamp,
    Color? gold,
  }) {
    return AppColorExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      inkText: inkText ?? this.inkText,
      primary: primary ?? this.primary,
      slate: slate ?? this.slate,
      stamp: stamp ?? this.stamp,
      gold: gold ?? this.gold,
    );
  }

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inkText: Color.lerp(inkText, other.inkText, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      stamp: Color.lerp(stamp, other.stamp, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

/// Convenience accessor so widgets can write `context.libColors.stamp`
/// instead of `Theme.of(context).extension<AppColorExtension>()!.stamp`.
extension AppColorsX on BuildContext {
  AppColorExtension get libColors =>
      Theme.of(this).extension<AppColorExtension>()!;
}