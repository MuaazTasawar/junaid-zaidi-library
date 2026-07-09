import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Grid card used in the "Browse by subject" section of HomeScreen
/// and as navigation entry into SubjectBrowseScreen.
///
/// Color is resolved the same way as [BookCover] (subject → body
/// color); kept as a local map here for the same reason described at
/// the top of this phase, consolidating into
/// `core/utils/cover_color_resolver.dart` in Phase 6.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    this.icon = Icons.menu_book_rounded,
  });

  final String subject;
  final VoidCallback onTap;
  final IconData icon;

  static const Map<String, Color> _subjectColors = {
    'Computer Science': Color(0xFF2F5233),
    'Mathematics': Color(0xFF2C4A66),
    'Literature': Color(0xFF6B4226),
    'Physics': Color(0xFF4A3B6B),
    'Engineering': Color(0xFF2F5233),
    'Business': Color(0xFF5C4A2A),
  };

  static const Color _defaultColor = Color(0xFF3D4A56);

  @override
  Widget build(BuildContext context) {
    final Color color = _subjectColors[subject] ?? _defaultColor;

    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                subject,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}