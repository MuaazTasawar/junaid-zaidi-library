import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Persistent top strip shown on any screen when the device is
/// offline (driven by `connectivity_plus`, wired in Phase 13's
/// `OfflineCubit`). Shows how many actions are queued for sync.
///
/// This widget is purely presentational — it takes booleans/counts as
/// input and has no knowledge of connectivity itself, keeping
/// business logic out of the widget layer (Golden Rule #2).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.queuedActionsCount,
  });

  final int queuedActionsCount;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Container(
      width: double.infinity,
      color: ext.stamp.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: ext.stamp),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              queuedActionsCount > 0
                  ? 'No connection · $queuedActionsCount ${queuedActionsCount == 1 ? 'action' : 'actions'} queued'
                  : 'No connection',
              style: AppTypography.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ext.stamp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}