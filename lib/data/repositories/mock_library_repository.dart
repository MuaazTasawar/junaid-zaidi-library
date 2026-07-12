import '../mock/mock_biblios.dart';
import '../mock/mock_checkouts.dart';
import '../mock/mock_fines.dart';
import '../mock/mock_holds.dart';
import '../mock/mock_items.dart';
import '../mock/mock_patrons.dart';
import '../models/biblio.dart';
import '../models/checkout.dart';
import '../models/fine.dart';
import '../models/hold.dart';
import '../models/item.dart';
import '../models/patron.dart';
import 'library_repository.dart';

/// In-memory implementation of [LibraryRepository] backed by the
/// `data/mock/` seed data. Mutates its own in-memory copies (never
/// the static `Mock*.all` lists) so repeated checkout/renew/hold
/// actions behave like a real backend across a single app session.
///
/// Every method has an artificial network delay via
/// [_simulateLatency] so loading states (shimmer) are visibly
/// exercised during development, matching real API behavior.
///
/// Fine amounts outstanding per patron are tracked via
/// [_patronFines] since Koha's real `account_line` resource (and
/// therefore our [Fine] model) has no `patron_id` field — account
/// lines are always scoped by the `/patrons/{patron_id}/account`
/// endpoint path, not by an embedded field. This map is this mock's
/// equivalent of that endpoint-level scoping.
class MockLibraryRepository implements LibraryRepository {
  MockLibraryRepository() {
    _biblios = List.of(MockBiblios.all);
    _items = List.of(MockItems.all);
    _patrons = List.of(MockPatrons.all);
    _checkouts = List.of(MockCheckouts.all);
    _holds = List.of(MockHolds.all);

    // Seed patron→fines scoping (see class doc above).
    _patronFines = {
      1: MockFines.all.where((f) => f.accountLineId == 1 || f.accountLineId == 2).toList(),
      2: MockFines.all.where((f) => f.accountLineId == 3).toList(),
      3: <Fine>[],
      4: <Fine>[],
    };

    _nextCheckoutId =
        _checkouts.map((c) => c.checkoutId).fold(0, (a, b) => a > b ? a : b) + 1;
    _nextHoldId = _holds.map((h) => h.holdId).fold(0, (a, b) => a > b ? a : b) + 1;
  }

  late List<Biblio> _biblios;
  late List<Item> _items;
  late List<Patron> _patrons;
  late List<Checkout> _checkouts;
  late List<Hold> _holds;
  late Map<int, List<Fine>> _patronFines;
  late int _nextCheckoutId;
  late int _nextHoldId;

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 500));

  // ── Auth ──────────────────────────────

  // ── Patron ──────────────────────────────
  @override
  Future<Patron> login({
    required String cardnumber,
    required String password,
  }) async {
    await _simulateLatency();

    if (password.length < 4) {
      throw const LibraryException('Password must be at least 4 characters.');
    }

    final List<Patron> matches = _patrons
        .where((p) => p.cardnumber.toLowerCase() == cardnumber.toLowerCase())
        .toList();

    if (matches.isEmpty) {
      throw const LibraryException('Invalid card number or password.');
    }

    return matches.first;
  }

  @override
  Future<void> logout() async {
    // No session state to clear in the mock — kept as a real async
    // no-op (not omitted) so the interface is satisfied identically
    // to KohaLibraryRepository's version.
  }
  @override
  Future<Patron> getPatron(int patronId) async {
    await _simulateLatency();
    return _patrons.firstWhere(
          (p) => p.patronId == patronId,
      orElse: () => throw const LibraryException('Patron not found.'),
    );
  }

  // ── Catalog ──────────────────────────────

  @override
  Future<List<Biblio>> searchCatalog(String query) async {
    await _simulateLatency();
    if (query.trim().isEmpty) return List.of(_biblios);

    final String q = query.toLowerCase();
    return _biblios
        .where((b) =>
    b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.subject.toLowerCase().contains(q) ||
        b.isbn.contains(q))
        .toList();
  }

  @override
  Future<Biblio> getBiblio(int biblioId) async {
    await _simulateLatency();
    return _biblios.firstWhere(
          (b) => b.biblioId == biblioId,
      orElse: () => throw const LibraryException('Title not found.'),
    );
  }

  @override
  Future<List<Item>> getItems(int biblioId) async {
    await _simulateLatency();
    return _items.where((i) => i.biblioId == biblioId).toList();
  }

  @override
  Future<Item> getItem(int itemId) async {
    await _simulateLatency();
    return _items.firstWhere(
          (i) => i.itemId == itemId,
      orElse: () => throw const LibraryException('Item not found.'),
    );
  }

  // ── Checkouts ──────────────────────────────

  @override
  Future<List<Checkout>> getCheckouts(int patronId) async {
    await _simulateLatency();
    return _checkouts.where((c) => c.patronId == patronId).toList();
  }

  @override
  Future<Checkout> getCheckoutForItem(int itemId) async {
    await _simulateLatency();
    return _checkouts.firstWhere(
          (c) => c.itemId == itemId,
      orElse: () => throw const LibraryException('This item is not currently checked out.'),
    );
  }

  @override
  Future<Checkout> renewCheckout(int checkoutId) async {
    await _simulateLatency();

    final int index = _checkouts.indexWhere((c) => c.checkoutId == checkoutId);
    if (index == -1) {
      throw const LibraryException('Checkout not found.');
    }

    final Checkout current = _checkouts[index];
    if (current.renewalsCount >= 3) {
      throw const LibraryException(
        'Renewal limit reached for this item. Please return it to the library.',
      );
    }

    final Checkout renewed = current.copyWith(
      dueDate: current.dueDate.add(const Duration(days: 14)),
      renewalsCount: current.renewalsCount + 1,
    );

    _checkouts[index] = renewed;
    return renewed;
  }

  @override
  Future<List<Checkout>> getBorrowingHistory(int patronId) async {
    await _simulateLatency();
    return _returnedCheckouts.where((c) => c.patronId == patronId).toList();
  }

  final List<Checkout> _returnedCheckouts = [];

  // ── Holds ──────────────────────────────

  @override
  Future<List<Hold>> getHolds(int patronId) async {
    await _simulateLatency();
    return _holds.where((h) => h.patronId == patronId).toList();
  }

  @override
  Future<Hold> placeHold({
    required int patronId,
    required int biblioId,
  }) async {
    await _simulateLatency();

    final bool alreadyHeld = _holds.any(
          (h) => h.patronId == patronId && h.biblioId == biblioId,
    );
    if (alreadyHeld) {
      throw const LibraryException('You already have a hold on this title.');
    }

    final int queueDepth =
        _holds.where((h) => h.biblioId == biblioId && !h.isReadyForPickup).length;

    final Hold hold = Hold(
      holdId: _nextHoldId++,
      patronId: patronId,
      biblioId: biblioId,
      status: 'T',
      priority: queueDepth + 1,
      waitingdate: null,
      expirationdate: DateTime.now().add(const Duration(days: 30)),
    );

    _holds.add(hold);
    return hold;
  }

  @override
  Future<void> cancelHold(int holdId) async {
    await _simulateLatency();
    _holds.removeWhere((h) => h.holdId == holdId);
  }

  // ── Fines ──────────────────────────────

  @override
  Future<List<Fine>> getAccount(int patronId) async {
    await _simulateLatency();
    return List.of(_patronFines[patronId] ?? const <Fine>[]);
  }

  // ── Staff ──────────────────────────────

  @override
  Future<Checkout> staffCheckout({
    required int patronId,
    required int itemId,
  }) async {
    await _simulateLatency();

    final int itemIndex = _items.indexWhere((i) => i.itemId == itemId);
    if (itemIndex == -1) {
      throw const LibraryException('Item not found.');
    }

    final Item item = _items[itemIndex];
    if (item.notforloan != 0) {
      throw const LibraryException('This item is not available for loan.');
    }
    if (item.onloan != null) {
      throw const LibraryException('This item is already checked out.');
    }

    final Checkout checkout = Checkout(
      checkoutId: _nextCheckoutId++,
      patronId: patronId,
      itemId: itemId,
      issuedate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      renewalsCount: 0,
    );

    _checkouts.add(checkout);
    _items[itemIndex] = item.copyWith(onloan: checkout.dueDate.toIso8601String());

    return checkout;
  }

  @override
  Future<void> staffCheckin(int checkoutId) async {
    await _simulateLatency();

    final int index = _checkouts.indexWhere((c) => c.checkoutId == checkoutId);
    if (index == -1) {
      throw const LibraryException('Checkout not found.');
    }

    final Checkout checkout = _checkouts.removeAt(index);
    _returnedCheckouts.add(checkout);

    final int itemIndex = _items.indexWhere((i) => i.itemId == checkout.itemId);
    if (itemIndex != -1) {
      _items[itemIndex] = _items[itemIndex].copyWith(onloan: null);
    }
  }

  @override
  Future<List<Patron>> searchPatrons(String query) async {
    await _simulateLatency();
    if (query.trim().isEmpty) return List.of(_patrons);

    final String q = query.toLowerCase();
    return _patrons
        .where((p) =>
    p.fullName.toLowerCase().contains(q) ||
        p.cardnumber.toLowerCase().contains(q) ||
        p.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    await _simulateLatency();
    if (query.trim().isEmpty) return List.of(_items);

    final String q = query.toLowerCase();
    return _items.where((i) {
      final Biblio biblio = _biblios.firstWhere(
            (b) => b.biblioId == i.biblioId,
        orElse: () => const Biblio(
          biblioId: -1,
          title: '',
          author: '',
          edition: '',
          isbn: '',
          subject: '',
          copyrightdate: 0,
          description: '',
        ),
      );
      return biblio.title.toLowerCase().contains(q) ||
          biblio.isbn.contains(q) ||
          i.itemcallnumber.toLowerCase().contains(q) ||
          i.itemnumber.toString().contains(q);
    }).toList();
  }
}