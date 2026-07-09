import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Reusable illustrated empty state (Screen 25 in the spec).
///
/// Every list-driven screen (checkouts, holds, search results,
/// notifications, fines, etc.) uses this rather than rolling its own
/// "nothing here" UI, so empty states stay visually consistent.
///
/// [icon] stands in for a bespoke illustration for now — swappable
/// for real illustration assets later without changing call sites.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.ctaLabel,
    this.onCtaPressed,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (iconColor ?? ext.slate).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: iconColor ?? ext.slate),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.lora(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ext.inkText,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.inter(fontSize: 13, color: ext.slate),
            ),
          ],
          if (ctaLabel != null && onCtaPressed != null) ...[
            const SizedBox(height: 20),
            AppButton(
              label: ctaLabel!,
              onPressed: onCtaPressed,
              variant: AppButtonVariant.outlined,
              fullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}