import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_cubit.dart';
import 'presentation/common_widgets/offline_banner.dart';
import 'presentation/offline/offline_cubit.dart';
import 'presentation/offline/offline_state.dart';
import 'presentation/profile/profile_cubit.dart';
import 'presentation/profile/profile_state.dart';
import 'presentation/theme/app_theme_cubit.dart';
import 'presentation/theme/app_theme_state.dart';

/// Root widget for the LibConnect app. Provides the app-wide
/// [AppThemeCubit], [AuthCubit], [OfflineCubit], and [ProfileCubit];
/// wires [MaterialApp.router] to [AppRouter] with light/dark
/// [ThemeData] from [AppTheme]; renders [OfflineBanner] globally
/// above every screen's content; and (Phase 15) applies the user's
/// font-size preference from [PersonalizationScreen] app-wide via
/// [MediaQuery]'s text scaler, so "Small/Medium/Large" actually
/// affects every screen rather than only being stored and ignored.
class App extends StatelessWidget {
  const App({super.key});

  static const Map<FontSizeOption, double> _textScaleFactors = {
    FontSizeOption.small: 0.9,
    FontSizeOption.medium: 1.0,
    FontSizeOption.large: 1.2,
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>(create: (_) => sl<AppThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<OfflineCubit>(create: (_) => sl<OfflineCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
      ],
      child: BlocBuilder<AppThemeCubit, AppThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (previous, current) => previous.fontSize != current.fontSize,
            builder: (context, profileState) {
              return MaterialApp.router(
                title: 'LibConnect',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.themeMode,
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  final double scale = _textScaleFactors[profileState.fontSize] ?? 1.0;

                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                    ),
                    child: Column(
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
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}