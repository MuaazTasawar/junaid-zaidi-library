import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/account/account_home_screen.dart';
import '../../presentation/account/checkouts_screen.dart';
import '../../presentation/account/fines_screen.dart';
import '../../presentation/account/history_screen.dart';
import '../../presentation/account/holds_screen.dart';
import '../../presentation/account/library_card_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/splash_screen.dart';
import '../../presentation/catalog/book_detail_screen.dart';
import '../../presentation/catalog/scanner_screen.dart';
import '../../presentation/catalog/search_results_screen.dart';
import '../../presentation/catalog/search_screen.dart';
import '../../presentation/catalog/subject_browse_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/notifications/notification_prefs_screen.dart';
import '../../presentation/notifications/notifications_screen.dart';
import '../../presentation/notifications/saved_searches_screen.dart';
import '../../presentation/offline/offline_screen.dart';
import '../../presentation/profile/personalization_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/settings_screen.dart';
import '../../presentation/staff/staff_home_screen.dart';
import '../../presentation/staff/staff_item_detail_screen.dart';
import '../../presentation/staff/staff_item_search_screen.dart';
import '../../presentation/staff/staff_patron_account_screen.dart';
import '../../presentation/staff/staff_patron_search_screen.dart';
import '../../presentation/staff/staff_scan_checkin_screen.dart';
import '../../presentation/staff/staff_scan_checkout_screen.dart';
import 'app_routes.dart';

/// App-wide [GoRouter] configuration. Every route now points at its
/// real screen — Phase 14 was the last content phase. Phase 15
/// (Polish) refines animations/transitions/accessibility across these
/// screens rather than adding new routes.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Patron shell (bottom nav) ──────────────────────────────
      StatefulShellRoute(
        builder: (context, state, navigationShell) => navigationShell,
        navigatorContainerBuilder: (context, navigationShell, children) {
          return _AppShell(navigationShell: navigationShell, children: children);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
              routes: [
                GoRoute(
                  path: 'results',
                  builder: (context, state) => SearchResultsScreen(
                    initialQuery: state.uri.queryParameters['q'] ?? '',
                  ),
                ),
                GoRoute(
                  path: 'scanner',
                  builder: (context, state) => const ScannerScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '${AppRoutes.bookDetail}/:biblioId',
              pageBuilder: (context, state) => _slideUpPage(
                child: BookDetailScreen(
                  biblioId: int.parse(state.pathParameters['biblioId']!),
                ),
              ),
            ),
            GoRoute(
              path: '${AppRoutes.subjectBrowse}/:subject',
              builder: (context, state) => SubjectBrowseScreen(
                subject: Uri.decodeComponent(state.pathParameters['subject']!),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) => const AccountHomeScreen(),
              routes: [
                GoRoute(
                  path: 'checkouts',
                  builder: (context, state) => const CheckoutsScreen(),
                ),
                GoRoute(
                  path: 'holds',
                  builder: (context, state) => const HoldsScreen(),
                ),
                GoRoute(
                  path: 'fines',
                  builder: (context, state) => const FinesScreen(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const HistoryScreen(),
                ),
                GoRoute(
                  path: 'library-card',
                  builder: (context, state) => const LibraryCardScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.notifications,
              builder: (context, state) => const NotificationsScreen(),
              routes: [
                GoRoute(
                  path: 'saved-searches',
                  builder: (context, state) => const SavedSearchesScreen(),
                ),
                GoRoute(
                  path: 'preferences',
                  builder: (context, state) => const NotificationPrefsScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'personalization',
                  builder: (context, state) => const PersonalizationScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),

      GoRoute(
        path: AppRoutes.offline,
        builder: (context, state) => const OfflineScreen(),
      ),

      // ── Staff ──────────────────────────────
      GoRoute(
        path: AppRoutes.staffHome,
        builder: (context, state) => const StaffHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffScanCheckout,
        builder: (context, state) => const StaffScanCheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffScanCheckin,
        builder: (context, state) => const StaffScanCheckinScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffPatronSearch,
        builder: (context, state) => const StaffPatronSearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.staffPatronAccount}/:patronId',
        pageBuilder: (context, state) => _slideUpPage(
          child: StaffPatronAccountScreen(
            patronId: int.parse(state.pathParameters['patronId']!),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffItemSearch,
        builder: (context, state) => const StaffItemSearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.staffItemDetail}/:itemId',
        pageBuilder: (context, state) => _slideUpPage(
          child: StaffItemDetailScreen(
            itemId: int.parse(state.pathParameters['itemId']!),
          ),
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _slideUpPage({required Widget child}) {
    return CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

/// Bottom-nav shell for the 5 patron tabs. Tab switches fade rather
/// than snap, per the design system's `Tab switches: FadeTransition`
/// rule.
class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey<int>(navigationShell.currentIndex),
          child: children[navigationShell.currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}