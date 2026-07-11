import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/utils/cover_color_resolver.dart';

/// Renders a book as a typographic mini-cover — NEVER a plain colored
/// block (Golden Rule #7).
///
/// Layout: a narrow colored spine on the left, and a colored body on
/// the right containing the title (Lora) and author (Inter,
/// small-caps via letter-spacing + uppercase, 70% opacity white).
///
/// Wrapped in [Semantics] (Phase 15) so screen readers announce "Book
/// cover: {title} by {author}" as one unit instead of reading the
/// title and author Text widgets as two disconnected fragments.
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

  @override
  Widget build(BuildContext context) {
    final CoverColors colors = CoverColorResolver.resolve(subject);

    return Semantics(
      label: 'Book cover: $title by $author',
      image: true,
      child: ExcludeSemantics(
        child: ClipRRect(
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
        ),
      ),
    );
  }
}