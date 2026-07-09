import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Entry point for the LibConnect app (Junaid Zaidi Library, COMSATS).
///
/// NOTE: Hive box registration for typed adapters, the DI container
/// (get_it/service_locator.dart), and the router are wired up in
/// Phase 6. Until then this boots Hive's raw key-value store only,
/// and `App` renders a minimal placeholder shell.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(const App());
}