import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/di/service_locator.dart';

/// Entry point for the LibConnect app (Junaid Zaidi Library, COMSATS).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await _initializeTimezone();

  await setupServiceLocator();

  runApp(const App());
}

/// Detects the device's real IANA timezone (e.g. "Asia/Karachi") via
/// `flutter_timezone` and sets it as the `timezone` package's local
/// location, so `NotificationService.scheduleAt()` computes reminder
/// times against the user's actual local time rather than UTC.
///
/// Falls back to UTC — logged, not silently swallowed — if detection
/// fails (e.g. an unsupported platform or a name the `timezone`
/// package's database doesn't recognize), so scheduling still works
/// rather than crashing app startup.
Future<void> _initializeTimezone() async {
  tz_data.initializeTimeZones();

  try {
    final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (e) {
    debugPrint('Timezone detection failed ($e); falling back to UTC. '
        'Due-date reminder times will be offset from local time.');
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}