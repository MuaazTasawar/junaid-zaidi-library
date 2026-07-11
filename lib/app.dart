import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_cubit.dart';
import 'presentation/common_widgets/offline_banner.dart';
import 'presentation/offline/offline_cubit.dart';
import 'presentation/offline/offline_state.dart';
import 'presentation/theme/app_theme_cubit.dart';
import 'presentation/theme/app_theme_state.dart';

/// Root widget for the LibConnect app. Provides the app-wide
/// [AppThemeCubit], [AuthCubit], and [OfflineCubit], wires
/// [MaterialApp.router] to [AppRouter] with light/dark [ThemeData]
/// from [AppTheme], and renders [OfflineBanner] globally above every
/// screen's content via the router's `builder` — this is what makes
/// the banner "shown on any screen when offline" (Screen 24 spec)
/// without every screen needing to remember to include it.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>(create: (_) => sl<AppThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<OfflineCubit>(create: (_) => sl<OfflineCubit>()),
      ],
      child: BlocBuilder<AppThemeCubit, AppThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'LibConnect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return Column(
                children: [
                  BlocBuilder<OfflineCubit, OfflineState>(
                    builder: (context, offlineState) {
                      if (!offlineState.isOffline) return const SizedBox.shrink();
                      return SafeArea(
                        bottom: false,
                        child: OfflineBanner(
                          queuedActionsCount: offlineState.queuedActions.length,
                        ),
                      );
                    },
                  ),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}