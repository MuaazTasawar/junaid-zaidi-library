import '../models/biblio.dart';
import '../models/checkout.dart';
import '../models/fine.dart';
import '../models/hold.dart';
import '../models/item.dart';
import '../models/patron.dart';
import '../network/koha_api_client.dart';
import 'library_repository.dart';

/// Real implementation of [LibraryRepository] against a live Koha
/// instance's REST API v1. Endpoint mapping matches the table in
/// `library_repository.dart`'s doc comment exactly.
///
/// Read the Phase 17 notes above (in the chat, not reproduced here)
/// before flipping `useMock = false` — in particular, [login]'s
/// endpoint is unlikely to work against a stock Koha install without
/// custom auth configuration on the server side.
class KohaLibraryRepository implements LibraryRepository {
  KohaLibraryRepository(this._client);

  final KohaApiClient _client;

  // ── Auth ──────────────────────────────

  @override
  Future<Patron> login({
    required String cardnumber,
    required String password,
  }) async {
    // Set credentials optimistically, then verify by making an
    // authenticated call. If the call fails, clear them so a failed
    // login attempt doesn't leave stale credentials attached to
    // subsequent unrelated requests.
    _client.setPatronCredentials(cardnumber: cardnumber, password: password);

    try {
      final dynamic result = await _client.get(
        '/patrons',
        query: {'cardnumber': cardnumber},
        auth: KohaAuthMode.patronBasic,
      );

      final List<dynamic> list = result is List ? result : [result];
      if (list.isEmpty) {
        throw const LibraryException('Invalid card number or password.');
      }

      return Patron.fromJson(list.first as Map<String, dynamic>);
    } on LibraryException {
      _client.clearPatronCredentials();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _client.clearPatronCredentials();
    _client.clearStaffToken();
  }

  // ── Patron ──────────────────────────────

  @override
  Future<Patron> getPatron(int patronId) async {
    final dynamic result = await _client.get('/patrons/$patronId');
    return Patron.fromJson(result as Map<String, dynamic>);
  }

  // ── Catalog ──────────────────────────────

  @override
  Future<List<Biblio>> searchCatalog(String query) async {
    final dynamic result = await _client.get(
      '/biblios',
      query: query.trim().isEmpty ? null : {'q': query},
    );
    return (result as List).map((e) => Biblio.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Biblio> getBiblio(int biblioId) async {
    final dynamic result = await _client.get('/biblios/$biblioId');
    return Biblio.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<Item>> getItems(int biblioId) async {
    final dynamic result = await _client.get('/biblios/$biblioId/items');
    return (result as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Item> getItem(int itemId) async {
    final dynamic result = await _client.get('/items/$itemId');
    return Item.fromJson(result as Map<String, dynamic>);
  }

  // ── Checkouts ──────────────────────────────

  @override
  Future<List<Checkout>> getCheckouts(int patronId) async {
    final dynamic result = await _client.get('/checkouts', query: {'patron_id': patronId});
    return (result as List).map((e) => Checkout.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Checkout> getCheckoutForItem(int itemId) async {
    final dynamic result = await _client.get('/checkouts', query: {'item_id': itemId});
    final List<dynamic> list = result as List;
    if (list.isEmpty) {
      throw const LibraryException('This item is not currently checked out.');
    }
    return Checkout.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Future<Checkout> renewCheckout(int checkoutId) async {
    final dynamic result = await _client.post('/checkouts/$checkoutId/renewal');
    return Checkout.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<Checkout>> getBorrowingHistory(int patronId) async {
    final dynamic result = await _client.get(
      '/checkouts',
      query: {'patron_id': patronId, 'checked_in': 1},
    );
    return (result as List).map((e) => Checkout.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Holds ──────────────────────────────

  @override
  Future<List<Hold>> getHolds(int patronId) async {
    final dynamic result = await _client.get('/holds', query: {'patron_id': patronId});
    return (result as List).map((e) => Hold.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Hold> placeHold({required int patronId, required int biblioId}) async {
    final dynamic result = await _client.post(
      '/holds',
      body: {'patron_id': patronId, 'biblio_id': biblioId},
    );
    return Hold.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<void> cancelHold(int holdId) async {
    await _client.delete('/holds/$holdId');
  }

  // ── Fines ──────────────────────────────

  @override
  Future<List<Fine>> getAccount(int patronId) async {
    // See Phase 17 note #3: this endpoint's real response shape
    // varies by Koha version/config. Handling both a flat array
    // (matching this repository's originally-specified contract) and
    // a nested {"outstanding_debits": {"lines": [...]}} shape, since
    // that's the more common real-world Koha structure — adjust here
    // if your instance returns something else entirely.
    final dynamic result = await _client.get('/patrons/$patronId/account');

    late final List<dynamic> lines;
    if (result is List) {
      lines = result;
    } else if (result is Map && result['outstanding_debits'] is Map) {
      lines = (result['outstanding_debits'] as Map)['lines'] as List<dynamic>? ?? [];
    } else {
      throw const LibraryException(
        'Unexpected response shape from /patrons/{id}/account — check KohaLibraryRepository.getAccount().',
      );
    }

    return lines.map((e) => Fine.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Staff (OAuth2) ──────────────────────────────

  @override
  Future<Checkout> staffCheckout({required int patronId, required int itemId}) async {
    final dynamic result = await _client.post(
      '/checkouts',
      body: {'patron_id': patronId, 'item_id': itemId},
      auth: KohaAuthMode.staffOAuth,
    );
    return Checkout.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<void> staffCheckin(int checkoutId) async {
    await _client.delete('/checkouts/$checkoutId', auth: KohaAuthMode.staffOAuth);
  }

  @override
  Future<List<Patron>> searchPatrons(String query) async {
    final dynamic result = await _client.get(
      '/patrons',
      query: query.trim().isEmpty ? null : {'q': query},
      auth: KohaAuthMode.staffOAuth,
    );
    return (result as List).map((e) => Patron.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    final dynamic result = await _client.get(
      '/items',
      query: query.trim().isEmpty ? null : {'q': query},
      auth: KohaAuthMode.staffOAuth,
    );
    return (result as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }
}