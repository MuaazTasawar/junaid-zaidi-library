import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum DueStatus { overdue, dueSoon, safe }

/// The signature "library stamp" widget: a rotated (-4deg), bordered,
/// rounded-rectangle badge showing the due date in JetBrains Mono
/// (e.g. "DUE JUL 14"), colored by how close/overdue the date is:
///
///   overdue (dueDate < today)      → stamp (red) border + text
///   due soon (dueDate <= today+3)  → gold border + text
///   safe                            → ink border + text
///
/// Animates in with a settle/bounce on first render via an
/// [AnimationController] driving scale + rotation.
///
/// Status resolution lives locally here for now; Phase 6 will route
/// it through `core/utils/date_formatter.dart` instead.
class DueDateStamp extends StatefulWidget {
  const DueDateStamp({
    super.key,
    required this.dueDate,
    this.label = 'DUE',
  });

  final DateTime dueDate;
  final String label;

  @override
  State<DueDateStamp> createState() => _DueDateStampState();
}

class _DueDateStampState extends State<DueDateStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DueStatus _resolveStatus() {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime due =
    DateTime(widget.dueDate.year, widget.dueDate.month, widget.dueDate.day);

    if (due.isBefore(todayDate)) return DueStatus.overdue;
    final DateTime soonThreshold = todayDate.add(const Duration(days: 3));
    if (!due.isAfter(soonThreshold)) return DueStatus.dueSoon;
    return DueStatus.safe;
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final DueStatus status = _resolveStatus();

    final Color color = switch (status) {
      DueStatus.overdue => ext.stamp,
      DueStatus.dueSoon => ext.gold,
      DueStatus.safe => ext.inkText,
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: -4 * 3.14159265 / 180,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${widget.label} ${_formatDate(widget.dueDate)}',
          style: AppTypography.mono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}