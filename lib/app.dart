import 'package:flutter/material.dart';

/// Root widget for the LibConnect app.
///
/// This is a temporary placeholder shell for Phase 0. It will be
/// replaced in Phase 6 with:
///   - MaterialApp.router using go_router (app_router.dart)
///   - ThemeData from core/theme/app_theme.dart (light + dark)
///   - ThemeMode driven by AppThemeCubit (presentation/theme/)
///   - MultiBlocProvider wiring from core/di/service_locator.dart
///
/// Kept intentionally minimal here so the project compiles and runs
/// standalone at the end of every phase.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LibConnect',
      debugShowCheckedModeBanner: false,
      home: _BootstrapPlaceholder(),
    );
  }
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2F5233),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'LibConnect',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C2430),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Junaid Zaidi Library · COMSATS',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}