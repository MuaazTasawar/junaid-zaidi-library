import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Renders a book as a typographic mini-cover — NEVER a plain colored
/// block (Golden Rule #7).
///
/// Layout: a narrow colored spine on the left, and a colored body on
/// the right containing the title (Lora) and author (Inter,
/// small-caps via letter-spacing + uppercase, 70% opacity white).
///
/// Color is resolved from [subject]. This widget owns a local
/// subject→color map for now; Phase 6 will swap this out for
/// `core/utils/cover_color_resolver.dart` so the mapping lives in one
/// canonical place shared with any future non-widget consumers.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.author,
    required this.subject,
    this.width = 100,
    this.height = 140,
  });

  final String title;
  final String author;
  final String subject;
  final double width;
  final double height;

  static const Map<String, _CoverColors> _subjectColors = {
    'Computer Science': _CoverColors(Color(0xFF2F5233), Color(0xFF1F3A23)),
    'Mathematics': _CoverColors(Color(0xFF2C4A66), Color(0xFF1C324A)),
    'Literature': _CoverColors(Color(0xFF6B4226), Color(0xFF4A2D19)),
    'Physics': _CoverColors(Color(0xFF4A3B6B), Color(0xFF332A4F)),
    'Engineering': _CoverColors(Color(0xFF2F5233), Color(0xFF1F3A23)),
    'Business': _CoverColors(Color(0xFF5C4A2A), Color(0xFF3D3019)),
  };

  static const _CoverColors _defaultColors =
  _CoverColors(Color(0xFF3D4A56), Color(0xFF2A333D));

  _CoverColors get _colors => _subjectColors[subject] ?? _defaultColors;

  @override
  Widget build(BuildContext context) {
    final _CoverColors colors = _colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              color: colors.spine,
            ),
            Expanded(
              child: Container(
                color: colors.body,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.lora(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      author.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverColors {
  const _CoverColors(this.body, this.spine);
  final Color body;
  final Color spine;
}