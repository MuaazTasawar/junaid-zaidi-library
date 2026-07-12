import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/utils/cover_color_resolver.dart';

/// Grid card used in the "Browse by subject" section of HomeScreen
/// and as navigation entry into SubjectBrowseScreen.
///
/// Color resolved via [CoverColorResolver.accentFor].
///
/// Wrapped in [Semantics] (Phase 18) as a tappable button with the
/// subject name as its label — without this, a screen reader reads
/// only the icon (silent) and the text label separately rather than
/// announcing "Computer Science, button" as one navigable element.
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

  @override
  Widget build(BuildContext context) {
    final Color color = CoverColorResolver.accentFor(subject);

    return Semantics(
      button: true,
      label: '$subject, browse subject',
      child: Material(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: ExcludeSemantics(
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
        ),
      ),
    );
  }
}