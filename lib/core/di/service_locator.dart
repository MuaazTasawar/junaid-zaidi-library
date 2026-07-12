import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/local/offline_queue_store.dart';
import '../../data/network/koha_api_client.dart';
import '../../data/repositories/koha_library_repository.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/mock_library_repository.dart';
import '../../presentation/account/account_cubit.dart';
import '../../presentation/auth/auth_cubit.dart';
import '../../presentation/catalog/catalog_cubit.dart';
import '../../presentation/home/home_cubit.dart';
import '../../presentation/notifications/notifications_cubit.dart';
import '../../presentation/offline/offline_cubit.dart';
import '../../presentation/profile/profile_cubit.dart';
import '../../presentation/staff/staff_cubit.dart';
import '../../presentation/theme/app_theme_cubit.dart';
import '../notifications/notification_service.dart';

final GetIt sl = GetIt.instance;

/// Global mock/real switch.
///
/// Flip to `false` only after:
///   1. Filling in `AppConstants.kohaBaseUrl` (and staff OAuth client
///      ID/secret if staff features will be used against the real
///      server).
///   2. Reading the Phase 17 notes on `login()`'s endpoint likely
///      needing adjustment for your specific Koha instance's auth
///      configuration, and `getAccount()`'s response-shape handling.
///
/// No other code in the app needs to change when you do this — that's
/// the whole point of the repository contract.
///
/// Also read directly by `SettingsScreen` (Phase 12) to show an
/// honest "mock data" vs "connected" status instead of a fabricated
/// connection indicator.
const bool useMock = true;

Future<void> setupServiceLocator() async {
  // ── Repositories ──────────────────────────────
  if (useMock) {
    sl.registerLazySingleton<LibraryRepository>(() => MockLibraryRepository());
  } else {
    sl.registerLazySingleton<http.Client>(() => http.Client());
    sl.registerLazySingleton<KohaApiClient>(
          () => KohaApiClient(httpClient: sl<http.Client>()),
    );
    sl.registerLazySingleton<LibraryRepository>(
          () => KohaLibraryRepository(sl<KohaApiClient>()),
    );
  }

  // ── Storage layers ──────────────────────────────
  sl.registerLazySingleton<OfflineQueueStore>(() => const OfflineQueueStore());

  // ── Platform services ──────────────────────────────
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // ── App-wide singletons (live for the whole app session) ──
  sl.registerLazySingleton<AppThemeCubit>(() => AppThemeCubit());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<LibraryRepository>()));
  sl.registerLazySingleton<OfflineCubit>(
        () => OfflineCubit(sl<LibraryRepository>(), sl<OfflineQueueStore>()),
  );
  sl.registerLazySingleton<ProfileCubit>(() => ProfileCubit(sl<LibraryRepository>()));

  // Multi-screen-flow singletons — shared across their pushed screen
  // groups so state survives navigation between them.
  sl.registerLazySingleton<CatalogCubit>(() => CatalogCubit(sl<LibraryRepository>()));
  sl.registerLazySingleton<AccountCubit>(() => AccountCubit(sl<LibraryRepository>()));
  sl.registerLazySingleton<NotificationsCubit>(
        () => NotificationsCubit(sl<LibraryRepository>(), sl<NotificationService>()),
  );
  sl.registerLazySingleton<StaffCubit>(() => StaffCubit(sl<LibraryRepository>()));

  // ── Feature Cubits (factories — new instance per screen visit) ──
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<LibraryRepository>()));
}