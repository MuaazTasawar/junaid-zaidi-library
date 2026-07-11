import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/di/service_locator.dart';

/// Entry point for the LibConnect app (Junaid Zaidi Library, COMSATS).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Required before any zonedSchedule() call in NotificationService.
  tz_data.initializeTimeZones();
  // No reliable way to detect the device's IANA timezone name without
  // an extra plugin (flutter_timezone etc.), which isn't declared —
  // defaulting to UTC is honest and safe rather than guessing a local
  // zone; reminders will be off by the device's UTC offset until a
  // timezone-detection package is added. Flagging in code, not hiding it.
  tz.setLocalLocation(tz.getLocation('UTC'));

  await setupServiceLocator();

  runApp(const App());
}