import 'package:flutter/material.dart';

/// Canonical subject → color mapping for book covers and subject
/// cards. This is the single source of truth referenced by
/// `BookCover` and `SubjectCard` (both updated this phase to delegate
/// here instead of carrying their own local maps, per the note left
/// in Phase 2).
class CoverColors {
  const CoverColors(this.body, this.spine);
  final Color body;
  final Color spine;
}

class CoverColorResolver {
  const CoverColorResolver._();

  static const Map<String, CoverColors> _bySubject = {
    'Computer Science': CoverColors(Color(0xFF2F5233), Color(0xFF1F3A23)),
    'Mathematics': CoverColors(Color(0xFF2C4A66), Color(0xFF1C324A)),
    'Literature': CoverColors(Color(0xFF6B4226), Color(0xFF4A2D19)),
    'Physics': CoverColors(Color(0xFF4A3B6B), Color(0xFF332A4F)),
    'Engineering': CoverColors(Color(0xFF2F5233), Color(0xFF1F3A23)),
    'Business': CoverColors(Color(0xFF5C4A2A), Color(0xFF3D3019)),
  };

  static const CoverColors _defaultColors =
  CoverColors(Color(0xFF3D4A56), Color(0xFF2A333D));

  /// Full body+spine pair, used by [BookCover].
  static CoverColors resolve(String subject) =>
      _bySubject[subject] ?? _defaultColors;

  /// Single accent color, used by [SubjectCard] and subject tag pills.
  static Color accentFor(String subject) => resolve(subject).body;

  static const List<String> browsableSubjects = [
    'Computer Science',
    'Mathematics',
    'Literature',
    'Physics',
    'Engineering',
    'Business',
  ];
}