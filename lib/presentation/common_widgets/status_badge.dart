import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum StatusBadgeKind {
  overdue,
  dueSoon,
  safe,
  available,
  onLoan,
  onHold,
  lost,
  ready,
  inQueue,
  returned,
  neutral,
}

/// Small pill badge used for statuses across the app: checkout status,
/// item availability, hold state, borrowing history entries, etc.
/// Color is derived from [kind] via `context.libColors` — never
/// hardcoded per call site.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.kind,
  });

  final String label;
  final StatusBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    final Color color = switch (kind) {
      StatusBadgeKind.overdue => ext.stamp,
      StatusBadgeKind.dueSoon => ext.gold,
      StatusBadgeKind.safe => ext.primary,
      StatusBadgeKind.available => ext.primary,
      StatusBadgeKind.onLoan => ext.stamp,
      StatusBadgeKind.onHold => ext.gold,
      StatusBadgeKind.lost => ext.slate,
      StatusBadgeKind.ready => ext.primary,
      StatusBadgeKind.inQueue => ext.slate,
      StatusBadgeKind.returned => ext.primary,
      StatusBadgeKind.neutral => ext.slate,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}