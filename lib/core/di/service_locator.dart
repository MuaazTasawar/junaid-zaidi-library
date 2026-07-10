import 'package:get_it/get_it.dart';

import '../../data/repositories/library_repository.dart';
import '../../data/repositories/mock_library_repository.dart';
import '../../presentation/auth/auth_cubit.dart';
import '../../presentation/catalog/catalog_cubit.dart';
import '../../presentation/home/home_cubit.dart';
import '../../presentation/theme/app_theme_cubit.dart';

final GetIt sl = GetIt.instance;

/// Global mock/real switch. Flip to `false` only once a real
/// `KohaLibraryRepository` implementation exists and is registered
/// below — no other code in the app needs to change when that
/// happens (that's the whole point of the repository contract).
const bool useMock = true;

Future<void> setupServiceLocator() async {
  // ── Repositories ──────────────────────────────
  if (useMock) {
    sl.registerLazySingleton<LibraryRepository>(() => MockLibraryRepository());
  } else {
    throw UnsupportedError(
      'KohaLibraryRepository is not implemented yet. Set useMock = true in service_locator.dart.',
    );
  }

  // ── App-wide singletons (live for the whole app session) ──
  sl.registerLazySingleton<AppThemeCubit>(() => AppThemeCubit());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<LibraryRepository>()));

  // CatalogCubit is a singleton (not a factory) — see Phase 9
  // architecture note: it's shared across Search, Results, Detail,
  // Subject Browse, and Scanner so state survives push navigation
  // between those screens.
  sl.registerLazySingleton<CatalogCubit>(() => CatalogCubit(sl<LibraryRepository>()));

  // ── Feature Cubits (factories — new instance per screen visit) ──
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<LibraryRepository>()));

  // AccountCubit (10), NotificationsCubit (11), ProfileCubit (12),
  // OfflineCubit (13), StaffCubit (14) are registered here as each is
  // built in its phase. This file is reissued in full each time.
}