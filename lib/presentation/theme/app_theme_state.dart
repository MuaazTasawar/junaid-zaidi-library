import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for [AppThemeCubit].
///
/// [themeMode] drives `MaterialApp.router(themeMode: ...)` (wired in
/// Phase 6). [isLoading] covers the brief window while the saved
/// preference is read from Hive on cold start.
class AppThemeState extends Equatable {
  const AppThemeState({
    required this.themeMode,
    required this.isLoading,
  });

  const AppThemeState.initial()
      : themeMode = ThemeMode.system,
        isLoading = true;

  final ThemeMode themeMode;
  final bool isLoading;

  AppThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, isLoading];
}