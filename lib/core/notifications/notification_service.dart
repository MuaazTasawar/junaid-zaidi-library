import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications`. Initialized once
/// in `service_locator.dart` and used by [NotificationsCubit] to fire
/// real local notifications.
///
/// Supports both immediate delivery ([showNow]) and true
/// background-time delivery via [scheduleAt] (`zonedSchedule`). Exact
/// times are computed against `tz.local`, which `main.dart` sets from
/// the device's real IANA timezone via `flutter_timezone` (falling
/// back to UTC if detection fails).
///
/// Uses the fully-named-argument API — the installed
/// flutter_local_notifications version requires `settings:`,
/// `id:`, `notificationDetails:`, `scheduledDate:`, etc. as named
/// parameters rather than positional ones.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'libconnect_alerts';
  static const String _channelName = 'LibConnect Alerts';
  static const String _channelDescription =
      'Due date reminders, hold-ready alerts, overdue warnings, and fine notices.';

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Fires a notification immediately. Used for states that are
  /// already true right now (overdue, hold ready) — see
  /// [NotificationsCubit] for why "due soon" uses [scheduleAt]
  /// instead of this.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Schedules a notification for a real future device time — fires
  /// even if the app is closed, unlike [showNow]. If [scheduledTime]
  /// is already in the past, this falls back to firing 2 seconds from
  /// now rather than silently dropping it (e.g. a due-date reminder
  /// computed for "3 days before" a due date that's already overdue).
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await init();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime target = tz.TZDateTime.from(scheduledTime, tz.local);
    if (target.isBefore(now)) {
      target = now.add(const Duration(seconds: 2));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: target,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Returns the IDs of notifications currently pending delivery —
  /// used by [NotificationsCubit] to avoid re-scheduling a due-date
  /// reminder that's already queued.
  Future<Set<int>> pendingIds() async {
    final List<PendingNotificationRequest> pending =
    await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).toSet();
  }
}