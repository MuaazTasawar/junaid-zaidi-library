import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/service_locator.dart';

/// Entry point for the LibConnect app (Junaid Zaidi Library, COMSATS).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await setupServiceLocator();

  runApp(const App());
}