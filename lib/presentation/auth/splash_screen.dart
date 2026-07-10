import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

/// Screen 1: shows the LibConnect logo mark + wordmark while
/// [AuthCubit] checks Hive for a saved session, then redirects to
/// Home, Staff Home, or Login accordingly. Logo fades in on entry.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    switch (state.status) {
      case AuthStatus.authenticatedPatron:
        context.go(AppRoutes.home);
      case AuthStatus.authenticatedStaff:
        context.go(AppRoutes.staffHome);
      case AuthStatus.unauthenticated:
        context.go(AppRoutes.login);
      case AuthStatus.unknown:
        break; // still checking
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: _handleAuthState,
        builder: (context, state) {
          return Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: ext.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LibConnect',
                    style: AppTypography.lora(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: ext.inkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Junaid Zaidi Library · COMSATS',
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: ext.slate,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}