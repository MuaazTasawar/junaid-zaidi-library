import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Reusable error state (Screen 26): warning icon, message, and a
/// Retry / Go home action pair. Used by every Cubit-driven screen's
/// error branch so failure UI is never hand-rolled per screen.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message,
    required this.onRetry,
    this.onGoHome,
  });

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 40, color: ext.slate),
          const SizedBox(height: 14),
          Text(
            'Something went wrong',
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
          const SizedBox(height: 20),
          AppButton(
            label: 'Retry',
            onPressed: onRetry,
            variant: AppButtonVariant.outlined,
            fullWidth: false,
          ),
          if (onGoHome != null) ...[
            const SizedBox(height: 4),
            AppButton(
              label: 'Go home',
              onPressed: onGoHome,
              variant: AppButtonVariant.text,
              fullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}