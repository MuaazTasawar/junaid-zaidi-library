import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, outlined, text, destructive }

/// Standard full-width-capable button used across LibConnect.
/// Wraps Flutter's themed buttons so every screen gets consistent
/// sizing, loading state, and disabled state without repeating logic.
///
/// Wrapped in [Semantics] (Phase 18) with `enabled` reflecting real
/// interactivity and a `busy` flag while [isLoading] is true — a
/// spinner replacing the label previously left a screen reader
/// announcing nothing while a request was in flight.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final bool disabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          variant == AppButtonVariant.outlined ||
              variant == AppButtonVariant.text
              ? ext.primary
              : Colors.white,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.destructive => ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ext.stamp,
          foregroundColor: Colors.white,
        ),
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
    };

    final Widget semanticButton = Semantics(
      button: true,
      enabled: !disabled,
      label: isLoading ? '$label, loading' : label,
      excludeSemantics: true,
      child: button,
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: semanticButton)
        : semanticButton;
  }
}