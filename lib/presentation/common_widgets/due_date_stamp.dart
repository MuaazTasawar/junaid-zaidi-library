import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';

/// The signature "library stamp" widget: a rotated (-4deg), bordered,
/// rounded-rectangle badge showing the due date in JetBrains Mono
/// (e.g. "DUE JUL 14"), colored by how close/overdue the date is.
/// Animates in with a settle/bounce on first render.
///
/// Status + date formatting now delegate to [DateFormatter] — the
/// local logic this widget carried in Phase 2 has been removed
/// (Phase 6).
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

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final DueStatus status = DateFormatter.resolveDueStatus(widget.dueDate);

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
          '${widget.label} ${DateFormatter.monoDate(widget.dueDate)}',
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