import 'package:get_it/get_it.dart';

import '../../data/repositories/library_repository.dart';
import '../../data/repositories/mock_library_repository.dart';
import '../../presentation/auth/auth_cubit.dart';
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
    // Intentionally unimplemented — see library_repository.dart's
    // doc comment for the full Koha endpoint mapping this will use.
    throw UnsupportedError(
      'KohaLibraryRepository is not implemented yet. Set useMock = true in service_locator.dart.',
    );
  }

  // ── App-wide Cubits ──────────────────────────────
  // AppThemeCubit drives MaterialApp.router.themeMode; AuthCubit owns
  // session state. Both are app-wide singletons, unlike feature
  // cubits (scoped per-screen from Phase 8 onward).
  sl.registerLazySingleton<AppThemeCubit>(() => AppThemeCubit());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<LibraryRepository>()));

  // Feature cubits — HomeCubit (8), CatalogCubit (9), AccountCubit
  // (10), NotificationsCubit (11), ProfileCubit (12), OfflineCubit
  // (13), StaffCubit (14) — are registered here as each is built in
  // its phase. This file is reissued in full each time.
}