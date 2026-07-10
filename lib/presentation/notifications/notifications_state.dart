import 'package:equatable/equatable.dart';

import '../../data/models/notification_item.dart';
import '../../data/models/saved_search.dart';

enum NotificationsStatus { idle, loading, loaded, error }
enum NotificationFilter { all, unread, alerts }

const Set<NotificationType> _alertTypes = {
  NotificationType.overdue,
  NotificationType.dueSoon,
  NotificationType.holdReady,
};

class NotificationPrefs extends Equatable {
  const NotificationPrefs({
    this.dueDateReminders = true,
    this.daysBefore = 3,
    this.holdReadyAlerts = true,
    this.overdueWarnings = true,
    this.fineNotices = true,
    this.savedSearchArrivals = true,
    this.subjectArrivals = false,
  });

  final bool dueDateReminders;
  final int daysBefore; // 1, 3, or 7
  final bool holdReadyAlerts;
  final bool overdueWarnings;
  final bool fineNotices;
  final bool savedSearchArrivals;
  final bool subjectArrivals;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      dueDateReminders: json['due_date_reminders'] as bool? ?? true,
      daysBefore: json['days_before'] as int? ?? 3,
      holdReadyAlerts: json['hold_ready_alerts'] as bool? ?? true,
      overdueWarnings: json['overdue_warnings'] as bool? ?? true,
      fineNotices: json['fine_notices'] as bool? ?? true,
      savedSearchArrivals: json['saved_search_arrivals'] as bool? ?? true,
      subjectArrivals: json['subject_arrivals'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'due_date_reminders': dueDateReminders,
      'days_before': daysBefore,
      'hold_ready_alerts': holdReadyAlerts,
      'overdue_warnings': overdueWarnings,
      'fine_notices': fineNotices,
      'saved_search_arrivals': savedSearchArrivals,
      'subject_arrivals': subjectArrivals,
    };
  }

  NotificationPrefs copyWith({
    bool? dueDateReminders,
    int? daysBefore,
    bool? holdReadyAlerts,
    bool? overdueWarnings,
    bool? fineNotices,
    bool? savedSearchArrivals,
    bool? subjectArrivals,
  }) {
    return NotificationPrefs(
      dueDateReminders: dueDateReminders ?? this.dueDateReminders,
      daysBefore: daysBefore ?? this.daysBefore,
      holdReadyAlerts: holdReadyAlerts ?? this.holdReadyAlerts,
      overdueWarnings: overdueWarnings ?? this.overdueWarnings,
      fineNotices: fineNotices ?? this.fineNotices,
      savedSearchArrivals: savedSearchArrivals ?? this.savedSearchArrivals,
      subjectArrivals: subjectArrivals ?? this.subjectArrivals,
    );
  }

  @override
  List<Object?> get props => [
    dueDateReminders,
    daysBefore,
    holdReadyAlerts,
    overdueWarnings,
    fineNotices,
    savedSearchArrivals,
    subjectArrivals,
  ];
}

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.notifications = const [],
    this.filter = NotificationFilter.all,
    this.errorMessage,
    this.savedSearchesStatus = NotificationsStatus.idle,
    this.savedSearches = const [],
    this.prefs = const NotificationPrefs(),
  });

  final NotificationsStatus status;
  final List<NotificationItem> notifications;
  final NotificationFilter filter;
  final String? errorMessage;

  final NotificationsStatus savedSearchesStatus;
  final List<SavedSearch> savedSearches;

  final NotificationPrefs prefs;

  List<NotificationItem> get visibleNotifications {
    switch (filter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.alerts:
        return notifications.where((n) => _alertTypes.contains(n.type)).toList();
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationItem>? notifications,
    NotificationFilter? filter,
    String? errorMessage,
    bool clearError = false,
    NotificationsStatus? savedSearchesStatus,
    List<SavedSearch>? savedSearches,
    NotificationPrefs? prefs,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedSearchesStatus: savedSearchesStatus ?? this.savedSearchesStatus,
      savedSearches: savedSearches ?? this.savedSearches,
      prefs: prefs ?? this.prefs,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    filter,
    errorMessage,
    savedSearchesStatus,
    savedSearches,
    prefs,
  ];
}