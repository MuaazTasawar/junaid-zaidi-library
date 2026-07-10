import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_cubit.dart';
import 'presentation/theme/app_theme_cubit.dart';
import 'presentation/theme/app_theme_state.dart';

/// Root widget for the LibConnect app. Provides the app-wide
/// [AppThemeCubit] and [AuthCubit], and wires [MaterialApp.router] to
/// [AppRouter] with light/dark [ThemeData] from [AppTheme].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>(create: (_) => sl<AppThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
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
          );
        },
      ),
    );
  }
}