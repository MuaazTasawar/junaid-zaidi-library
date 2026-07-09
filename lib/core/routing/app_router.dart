import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// App-wide [GoRouter] configuration.
///
/// - Patron tabs (Home · Search · Account · Notifications · Profile)
///   live under a [StatefulShellRoute] with a custom
///   [navigatorContainerBuilder] so tab switches use [FadeTransition]
///   (per the design system spec) instead of the default un-animated
///   IndexedStack swap.
/// - Detail-style screens (book detail, staff patron/item detail) use
///   [CustomTransitionPage] with a bottom-to-top [SlideTransition].
/// - Every screen referenced below is a placeholder until its own
///   phase lands (7–14); this file is reissued in full each time a
///   route's placeholder is swapped for the real screen.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Splash', phase: 7),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Login', phase: 7),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Forgot Password', phase: 7),
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
              builder: (context, state) =>
              const _PlaceholderScreen(title: 'Home', phase: 8),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) =>
              const _PlaceholderScreen(title: 'Search', phase: 9),
              routes: [
                GoRoute(
                  path: 'results',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Search Results', phase: 9),
                ),
                GoRoute(
                  path: 'scanner',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Scanner', phase: 9),
                ),
              ],
            ),
            GoRoute(
              path: '${AppRoutes.bookDetail}/:biblioId',
              pageBuilder: (context, state) => _slideUpPage(
                child: _PlaceholderScreen(
                  title: 'Book Detail #${state.pathParameters['biblioId']}',
                  phase: 9,
                ),
              ),
            ),
            GoRoute(
              path: '${AppRoutes.subjectBrowse}/:subject',
              builder: (context, state) => _PlaceholderScreen(
                title: 'Browse: ${state.pathParameters['subject']}',
                phase: 9,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) =>
              const _PlaceholderScreen(title: 'Account', phase: 10),
              routes: [
                GoRoute(
                  path: 'checkouts',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Checkouts', phase: 10),
                ),
                GoRoute(
                  path: 'holds',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Holds', phase: 10),
                ),
                GoRoute(
                  path: 'fines',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Fines', phase: 10),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Borrowing History', phase: 10),
                ),
                GoRoute(
                  path: 'library-card',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Library Card', phase: 10),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.notifications,
              builder: (context, state) =>
              const _PlaceholderScreen(title: 'Notifications', phase: 11),
              routes: [
                GoRoute(
                  path: 'saved-searches',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Saved Searches', phase: 11),
                ),
                GoRoute(
                  path: 'preferences',
                  builder: (context, state) => const _PlaceholderScreen(
                      title: 'Notification Preferences', phase: 11),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
              const _PlaceholderScreen(title: 'Profile', phase: 12),
              routes: [
                GoRoute(
                  path: 'personalization',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Personalization', phase: 12),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Settings', phase: 12),
                ),
              ],
            ),
          ]),
        ],
      ),

      GoRoute(
        path: AppRoutes.offline,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Offline', phase: 13),
      ),

      // ── Staff ──────────────────────────────
      GoRoute(
        path: AppRoutes.staffHome,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Staff Home', phase: 14),
      ),
      GoRoute(
        path: AppRoutes.staffScanCheckout,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Staff Scan Checkout', phase: 14),
      ),
      GoRoute(
        path: AppRoutes.staffScanCheckin,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Staff Scan Checkin', phase: 14),
      ),
      GoRoute(
        path: AppRoutes.staffPatronSearch,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Staff Patron Search', phase: 14),
      ),
      GoRoute(
        path: '${AppRoutes.staffPatronAccount}/:patronId',
        pageBuilder: (context, state) => _slideUpPage(
          child: _PlaceholderScreen(
            title: 'Staff Patron #${state.pathParameters['patronId']}',
            phase: 14,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffItemSearch,
        builder: (context, state) =>
        const _PlaceholderScreen(title: 'Staff Item Search', phase: 14),
      ),
      GoRoute(
        path: '${AppRoutes.staffItemDetail}/:itemId',
        pageBuilder: (context, state) => _slideUpPage(
          child: _PlaceholderScreen(
            title: 'Staff Item #${state.pathParameters['itemId']}',
            phase: 14,
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
/// rule. Trade-off: this rebuilds the incoming branch's subtree on
/// every switch (no persistent IndexedStack), which is an acceptable
/// cost for the fade requirement at this app's scale.
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

/// Temporary stand-in for screens not yet built. Shows the intended
/// screen name and which phase will implement it, with a back button
/// when it's not a shell-tab root. Every usage above is replaced with
/// the real screen inside that screen's own phase.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.phase});

  final String title;
  final int phase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\nbuilt in Phase $phase',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}