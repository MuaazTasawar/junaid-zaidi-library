/// App-wide constants. This file existed as an empty stub since
/// Phase 0's project setup script but was never populated — every
/// phase up to now only needed the mock repository, which has no
/// external config to centralize. Filling it in now that
/// [KohaLibraryRepository] needs real configuration values.
class AppConstants {
  const AppConstants._();

  // ── App identity ──────────────────────────────
  static const String appName = 'LibConnect';
  static const String libraryName = 'Junaid Zaidi Library';
  static const String institutionName = 'COMSATS University Islamabad';
  static const String defaultBranchCode = 'CMN';
  static const String defaultBranchName = 'COMSATS Main Library';

  // ── Koha API configuration ──────────────────────────────
  // REQUIRED: fill these in before setting useMock = false in
  // service_locator.dart. Left empty rather than a fake-looking
  // placeholder URL, so a misconfiguration fails loudly (empty-string
  // URI parse error) instead of silently hitting a bogus host.
  //
  // Example: 'https://library.comsats.edu.pk/api/v1'
  static const String kohaBaseUrl = '';

  // OAuth2 client credentials for staff-scoped endpoints (see Phase
  // 17 note #2 on why shipping these in a mobile binary isn't secure
  // for production — fine for internal/testing builds).
  static const String kohaStaffClientId = '';
  static const String kohaStaffClientSecret = '';

  static const Duration apiTimeout = Duration(seconds: 15);
}