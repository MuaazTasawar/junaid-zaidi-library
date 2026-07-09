import 'package:equatable/equatable.dart';

/// LibConnect-side notification model (Screen 18). Not a direct Koha
/// resource — it's synthesized client-side from checkouts, holds, and
/// saved searches by `NotificationsCubit` (Phase 11), so field naming
/// here follows Dart convention rather than the Koha snake_case rule
/// (Golden Rule #6 applies only to Koha resource models).
enum NotificationType {
  overdue,
  holdReady,
  dueSoon,
  savedSearch,
  checkoutConfirmed,
}

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.relatedBiblioId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final int? relatedBiblioId;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => NotificationType.checkoutConfirmed,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      relatedBiblioId: json['related_biblio_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'related_biblio_id': relatedBiblioId,
    };
  }

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    int? relatedBiblioId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedBiblioId: relatedBiblioId ?? this.relatedBiblioId,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, title, body, createdAt, isRead, relatedBiblioId];
}