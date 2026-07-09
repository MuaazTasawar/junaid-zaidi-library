/// Central route path constants. No screen widget or cubit should
/// ever hardcode a route string — always reference these.
class AppRoutes {
  const AppRoutes._();

  // ── Auth ──────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // ── Patron shell branches ──────────────────────────────
  static const String home = '/home';

  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String bookDetail = '/catalog/book'; // + /:biblioId
  static const String subjectBrowse = '/catalog/subject'; // + /:subject
  static const String scanner = '/catalog/scanner';

  static const String account = '/account';
  static const String checkouts = '/account/checkouts';
  static const String holds = '/account/holds';
  static const String fines = '/account/fines';
  static const String history = '/account/history';
  static const String libraryCard = '/account/library-card';

  static const String notifications = '/notifications';
  static const String savedSearches = '/notifications/saved-searches';
  static const String notificationPrefs = '/notifications/preferences';

  static const String profile = '/profile';
  static const String personalization = '/profile/personalization';
  static const String settings = '/profile/settings';

  static const String offline = '/offline';

  // ── Staff ──────────────────────────────
  static const String staffHome = '/staff';
  static const String staffScanCheckout = '/staff/scan-checkout';
  static const String staffScanCheckin = '/staff/scan-checkin';
  static const String staffPatronSearch = '/staff/patron-search';
  static const String staffPatronAccount = '/staff/patron'; // + /:patronId
  static const String staffItemSearch = '/staff/item-search';
  static const String staffItemDetail = '/staff/item'; // + /:itemId

  static String bookDetailPath(int biblioId) => '$bookDetail/$biblioId';
  static String subjectBrowsePath(String subject) =>
      '$subjectBrowse/${Uri.encodeComponent(subject)}';
  static String staffPatronAccountPath(int patronId) =>
      '$staffPatronAccount/$patronId';
  static String staffItemDetailPath(int itemId) => '$staffItemDetail/$itemId';
}