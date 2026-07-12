import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../repositories/library_repository.dart';

/// Which credential scheme to attach to a request.
enum KohaAuthMode {
  /// No Authorization header — for endpoints that are genuinely
  /// public in your Koha configuration, if any.
  none,

  /// HTTP Basic Auth using the currently-signed-in patron's card
  /// number + password (set via [KohaApiClient.setPatronCredentials]
  /// after a successful [KohaLibraryRepository.login]).
  patronBasic,

  /// OAuth2 client-credentials Bearer token, for staff-only
  /// endpoints (checkout/checkin, patron/item search). See Phase 17
  /// note #2 on the security tradeoff of embedding client credentials
  /// in a mobile binary.
  staffOAuth,
}

/// Thin HTTP client wrapping Koha's REST API v1. Owns credential
/// storage (in-memory only — never persisted to disk) and JSON
/// encode/decode + error mapping into [LibraryException], so
/// [KohaLibraryRepository] itself stays focused on endpoint mapping
/// rather than plumbing.
class KohaApiClient {
  KohaApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  String? _patronCardnumber;
  String? _patronPassword;

  String? _staffAccessToken;
  DateTime? _staffTokenExpiry;

  bool get hasPatronCredentials => _patronCardnumber != null && _patronPassword != null;

  void setPatronCredentials({required String cardnumber, required String password}) {
    _patronCardnumber = cardnumber;
    _patronPassword = password;
  }

  void clearPatronCredentials() {
    _patronCardnumber = null;
    _patronPassword = null;
  }

  void clearStaffToken() {
    _staffAccessToken = null;
    _staffTokenExpiry = null;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    if (AppConstants.kohaBaseUrl.isEmpty) {
      throw const LibraryException(
        'Koha server URL is not configured. Set AppConstants.kohaBaseUrl.',
      );
    }
    final Map<String, String>? stringQuery =
    query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse('${AppConstants.kohaBaseUrl}$path').replace(
      queryParameters: stringQuery,
    );
  }

  Future<Map<String, String>> _headers(KohaAuthMode mode) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    switch (mode) {
      case KohaAuthMode.none:
        break;
      case KohaAuthMode.patronBasic:
        if (!hasPatronCredentials) {
          throw const LibraryException('You are not signed in.');
        }
        final String creds =
        base64Encode(utf8.encode('$_patronCardnumber:$_patronPassword'));
        headers['Authorization'] = 'Basic $creds';
      case KohaAuthMode.staffOAuth:
        final String token = await _ensureStaffToken();
        headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<String> _ensureStaffToken() async {
    if (_staffAccessToken != null &&
        _staffTokenExpiry != null &&
        DateTime.now().isBefore(_staffTokenExpiry!)) {
      return _staffAccessToken!;
    }

    if (AppConstants.kohaStaffClientId.isEmpty ||
        AppConstants.kohaStaffClientSecret.isEmpty) {
      throw const LibraryException(
        'Staff OAuth client credentials are not configured.',
      );
    }

    final Uri uri = Uri.parse('${AppConstants.kohaBaseUrl}/oauth/token');
    final http.Response response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': AppConstants.kohaStaffClientId,
        'client_secret': AppConstants.kohaStaffClientSecret,
      },
    ).timeout(AppConstants.apiTimeout);

    if (response.statusCode != 200) {
      throw const LibraryException('Staff authentication failed.');
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;
    _staffAccessToken = data['access_token'] as String;
    final int expiresIn = data['expires_in'] as int? ?? 3600;
    // Refresh 30s early to avoid a request landing exactly at expiry.
    _staffTokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 30));

    return _staffAccessToken!;
  }

  Future<dynamic> get(
      String path, {
        Map<String, dynamic>? query,
        KohaAuthMode auth = KohaAuthMode.patronBasic,
      }) async {
    final Uri uri = _buildUri(path, query);
    final Map<String, String> headers = await _headers(auth);
    final http.Response response =
    await _http.get(uri, headers: headers).timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(
      String path, {
        Object? body,
        KohaAuthMode auth = KohaAuthMode.patronBasic,
      }) async {
    final Uri uri = _buildUri(path);
    final Map<String, String> headers = await _headers(auth);
    final http.Response response = await _http
        .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(
      String path, {
        KohaAuthMode auth = KohaAuthMode.patronBasic,
      }) async {
    final Uri uri = _buildUri(path);
    final Map<String, String> headers = await _headers(auth);
    final http.Response response =
    await _http.delete(uri, headers: headers).timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message = 'Request failed (HTTP ${response.statusCode}).';
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        message = decoded['error'].toString();
      } else if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {
      // Response body wasn't JSON — keep the generic status-code message.
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw LibraryException('Not authorized: $message');
    }
    throw LibraryException(message);
  }
}