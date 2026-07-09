import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'app_theme_state.dart';

/// Manages the app's [ThemeMode] (system / light / dark), persisted in
/// Hive so the choice survives app restarts.
///
/// Registered in `core/di/service_locator.dart` (Phase 6) as a
/// lazy singleton and provided at the root via `BlocProvider` in
/// `app.dart`. Opens its own Hive box lazily so it also works
/// standalone before DI wiring lands.
class AppThemeCubit extends Cubit<AppThemeState> {
  AppThemeCubit() : super(const AppThemeState.initial()) {
    _loadSavedTheme();
  }

  static const String _boxName = 'settingsBox';
  static const String _themeModeKey = 'themeMode';

  Future<void> _loadSavedTheme() async {
    final Box box = await Hive.openBox(_boxName);
    final String? saved = box.get(_themeModeKey) as String?;

    final ThemeMode mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    emit(state.copyWith(themeMode: mode, isLoading: false));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));

    final Box box = await Hive.openBox(_boxName);
    final String value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await box.put(_themeModeKey, value);
  }

  void toggleLightDark() {
    final ThemeMode next =
    state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}