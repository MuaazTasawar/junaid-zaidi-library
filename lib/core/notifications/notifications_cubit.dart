import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/notification_service.dart';
import '../../data/models/checkout.dart';
import '../../data/models/hold.dart';
import '../../data/models/notification_item.dart';
import '../../data/models/saved_search.dart';
import '../../data/repositories/library_repository.dart';
import 'notifications_state.dart';

/// Synthesizes [NotificationItem]s from checkouts (overdue / due
/// soon) and holds (ready for pickup) — there's no Koha "inbox"
/// resource to fetch — and manages saved searches + preferences,
/// all persisted in Hive since none of this is backend-owned data.
///
/// As of Phase 16, due-date reminders are scheduled for a real future
/// device time via [NotificationService.scheduleAt] (fires even if
/// the app is closed, computed as `prefs.daysBefore` days before the
/// due date at 9:00 AM local). Hold-ready and overdue alerts represent
/// states that are already true, so those still fire immediately via
/// [NotificationService.showNow] rather than being "scheduled" for a
/// future time that doesn't apply to them.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository, this._notificationService)
      : super(const NotificationsState()) {
    _loadPrefs();
  }

  final LibraryRepository _repository;
  final NotificationService _notificationService;
  static const _uuid = Uuid();

  final Set<String> _firedThisSession = {};

  static const String _notificationsBoxName = 'notificationsBox';
  static const String _readIdsKey = 'readNotificationIds';
  static const String _dismissedIdsKey = 'dismissedNotificationIds';

  static const String _savedSearchesBoxName = 'savedSearchesBox';
  static const String _savedSearchesKey = 'savedSearches';

  static const String _prefsBoxName = 'settingsBox';
  static const String _prefsKey = 'notificationPrefs';

  // ── Notifications (synthesized) ──────────────────────────────

  Future<void> loadNotifications(int patronId) async {
    emit(state.copyWith(status: NotificationsStatus.loading, clearError: true));

    try {
      final List<Checkout> checkouts = await _repository.getCheckouts(patronId);
      final List<Hold> holds = await _repository.getHolds(patronId);

      final Box box = await Hive.openBox(_notificationsBoxName);
      final Set<String> readIds =
      ((box.get(_readIdsKey) as List?)?.cast<String>() ?? []).toSet();
      final Set<String> dismissedIds =
      ((box.get(_dismissedIdsKey) as List?)?.cast<String>() ?? []).toSet();

      final Set<int> alreadyScheduled = await _notificationService.pendingIds();

      final List<NotificationItem> synthesized = [];
      final NotificationPrefs prefs = state.prefs;

      for (final c in checkouts) {
        if (c.isOverdue && prefs.overdueWarnings) {
          final id = 'overdue-${c.checkoutId}';
          if (dismissedIds.contains(id)) continue;
          synthesized.add(NotificationItem(
            id: id,
            type: NotificationType.overdue,
            title: 'Item overdue',
            body: 'A checked-out item is overdue. A fine may apply.',
            createdAt: c.dueDate,
            isRead: readIds.contains(id),
          ));
          await _fireOnce(id, 'Item overdue', 'A checked-out item is overdue.');
        } else if (c.isDueSoon && prefs.dueDateReminders) {
          final id = 'duesoon-${c.checkoutId}';
          if (dismissedIds.contains(id)) continue;
          synthesized.add(NotificationItem(
            id: id,
            type: NotificationType.dueSoon,
            title: 'Due soon',
            body: 'An item is due back within ${prefs.daysBefore} days.',
            createdAt: c.issuedate,
            isRead: readIds.contains(id),
          ));

          // Schedule the real reminder for daysBefore-days-before due
          // date at 9:00 AM, rather than firing now.
          final int notifId = id.hashCode;
          if (!alreadyScheduled.contains(notifId)) {
            final DateTime reminderTime = DateTime(
              c.dueDate.year,
              c.dueDate.month,
              c.dueDate.day - prefs.daysBefore,
              9,
            );
            await _notificationService.scheduleAt(
              id: notifId,
              title: 'Due soon',
              body: 'An item is due back on ${c.dueDate.month}/${c.dueDate.day}.',
              scheduledTime: reminderTime,
            );
          }
        }
      }

      for (final h in holds) {
        if (h.isReadyForPickup && prefs.holdReadyAlerts) {
          final id = 'holdready-${h.holdId}';
          if (dismissedIds.contains(id)) continue;
          synthesized.add(NotificationItem(
            id: id,
            type: NotificationType.holdReady,
            title: 'Hold ready',
            body: 'A held title is ready for pickup.',
            createdAt: h.waitingdate ?? DateTime.now(),
            isRead: readIds.contains(id),
            relatedBiblioId: h.biblioId,
          ));
          await _fireOnce(id, 'Hold ready', 'A held title is ready for pickup at COMSATS Main Library.');
        }
      }

      final List<SavedSearch> savedSearches = await _loadSavedSearchesFromHive();
      if (prefs.savedSearchArrivals) {
        for (final s in savedSearches.where((s) => s.alertsEnabled && s.resultCount > 0)) {
          final id = 'savedsearch-${s.id}';
          if (dismissedIds.contains(id)) continue;
          synthesized.add(NotificationItem(
            id: id,
            type: NotificationType.savedSearch,
            title: 'New titles match your search',
            body: '${s.resultCount} titles match "${s.term}"',
            createdAt: s.lastCheckedAt,
            isRead: readIds.contains(id),
          ));
        }
      }

      synthesized.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: synthesized,
        savedSearches: savedSearches,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(status: NotificationsStatus.error, errorMessage: e.message));
    }
  }

  /// Fires a real device notification for [id] at most once per app
  /// session, so re-visiting the Notifications tab doesn't re-alert
  /// for the same overdue/hold-ready item repeatedly. Only used for
  /// states that are already true "now" (overdue, hold ready) — see
  /// class doc for why due-soon uses [NotificationService.scheduleAt]
  /// instead.
  Future<void> _fireOnce(String id, String title, String body) async {
    if (_firedThisSession.contains(id)) return;
    _firedThisSession.add(id);
    await _notificationService.showNow(id: id.hashCode, title: title, body: body);
  }

  void setFilter(NotificationFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> markAllRead() async {
    final Box box = await Hive.openBox(_notificationsBoxName);
    final Set<String> readIds = state.notifications.map((n) => n.id).toSet();
    await box.put(_readIdsKey, readIds.toList());

    emit(state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    ));
  }

  Future<void> dismissNotification(String id) async {
    final Box box = await Hive.openBox(_notificationsBoxName);
    final Set<String> dismissedIds =
    ((box.get(_dismissedIdsKey) as List?)?.cast<String>() ?? []).toSet()..add(id);
    await box.put(_dismissedIdsKey, dismissedIds.toList());

    await _notificationService.cancel(id.hashCode);

    emit(state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    ));
  }

  // ── Saved searches ──────────────────────────────

  Future<List<SavedSearch>> _loadSavedSearchesFromHive() async {
    final Box box = await Hive.openBox(_savedSearchesBoxName);
    final List<dynamic> raw = (box.get(_savedSearchesKey) as List?) ?? [];
    return raw
        .map((e) => SavedSearch.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _persistSavedSearches(List<SavedSearch> searches) async {
    final Box box = await Hive.openBox(_savedSearchesBoxName);
    await box.put(_savedSearchesKey, searches.map((s) => s.toJson()).toList());
  }

  Future<void> loadSavedSearches() async {
    emit(state.copyWith(savedSearchesStatus: NotificationsStatus.loading));
    final List<SavedSearch> searches = await _loadSavedSearchesFromHive();
    emit(state.copyWith(savedSearchesStatus: NotificationsStatus.loaded, savedSearches: searches));
  }

  Future<void> addSavedSearch(String term) async {
    if (term.trim().isEmpty) return;

    int resultCount = 0;
    try {
      resultCount = (await _repository.searchCatalog(term)).length;
    } on LibraryException {
      resultCount = 0;
    }

    final SavedSearch newSearch = SavedSearch(
      id: _uuid.v4(),
      term: term.trim(),
      resultCount: resultCount,
      alertsEnabled: true,
      lastCheckedAt: DateTime.now(),
    );

    final List<SavedSearch> updated = [...state.savedSearches, newSearch];
    emit(state.copyWith(savedSearches: updated));
    await _persistSavedSearches(updated);
  }

  Future<void> toggleSavedSearchAlerts(String id) async {
    final List<SavedSearch> updated = state.savedSearches
        .map((s) => s.id == id ? s.copyWith(alertsEnabled: !s.alertsEnabled) : s)
        .toList();
    emit(state.copyWith(savedSearches: updated));
    await _persistSavedSearches(updated);
  }

  Future<void> deleteSavedSearch(String id) async {
    final List<SavedSearch> updated = state.savedSearches.where((s) => s.id != id).toList();
    emit(state.copyWith(savedSearches: updated));
    await _persistSavedSearches(updated);
  }

  // ── Preferences ──────────────────────────────

  Future<void> _loadPrefs() async {
    final Box box = await Hive.openBox(_prefsBoxName);
    final Map? raw = box.get(_prefsKey) as Map?;
    if (raw != null) {
      emit(state.copyWith(prefs: NotificationPrefs.fromJson(Map<String, dynamic>.from(raw))));
    }
  }

  Future<void> updatePrefs(NotificationPrefs prefs) async {
    emit(state.copyWith(prefs: prefs));
    final Box box = await Hive.openBox(_prefsBoxName);
    await box.put(_prefsKey, prefs.toJson());
  }
}