import '../models/biblio.dart';
import '../models/checkout.dart';
import '../models/fine.dart';
import '../models/hold.dart';
import '../models/item.dart';
import '../models/patron.dart';

/// Single contract for all library data access. Every Cubit in
/// `presentation/` depends on this abstraction — never on
/// [MockLibraryRepository] or a future `KohaLibraryRepository`
/// directly (Golden Rule #4: no direct HTTP calls outside this
/// layer, no widget/cubit ever touches the network).
///
/// Swapping `useMock` in `core/di/service_locator.dart` from the mock
/// implementation to a real `KohaLibraryRepository` must require zero
/// changes above this layer.
///
/// Method → Koha REST endpoint mapping (for the future
/// `KohaLibraryRepository` implementation):
///
/// | Method                 | Koha endpoint                                          |
/// |-------------------------|---------------------------------------------------------|
/// | login()                 | GET  /api/v1/patrons?cardnumber= (Basic Auth)            |
/// | getPatron()              | GET  /api/v1/patrons/{patron_id}                         |
/// | searchCatalog()          | GET  /api/v1/biblios?q=                                  |
/// | getBiblio()              | GET  /api/v1/biblios/{biblio_id}                         |
/// | getItems()               | GET  /api/v1/biblios/{biblio_id}/items                   |
/// | getItem()                | GET  /api/v1/items/{item_id}                             |
/// | getCheckouts()           | GET  /api/v1/checkouts?patron_id=                        |
/// | renewCheckout()          | POST /api/v1/checkouts/{checkout_id}/renewal             |
/// | getHolds()               | GET  /api/v1/holds?patron_id=                            |
/// | placeHold()              | POST /api/v1/holds                                       |
/// | cancelHold()             | DELETE /api/v1/holds/{hold_id}                           |
/// | getAccount()             | GET  /api/v1/patrons/{patron_id}/account                 |
/// | staffCheckout()          | POST /api/v1/checkouts (staff OAuth2)                    |
/// | staffCheckin()           | DELETE /api/v1/checkouts/{checkout_id}                   |
/// | searchPatrons()          | GET  /api/v1/patrons?q=                                  |
/// | searchItems()            | GET  /api/v1/items?q=                                    |
/// | getBorrowingHistory()    | GET  /api/v1/checkouts?patron_id=&checked_in=1           |
abstract class LibraryRepository {
  /// Authenticates a patron or staff member by library card number
  /// and password. Throws [LibraryException] on invalid credentials.
  Future<Patron> login({
    required String cardnumber,
    required String password,
  });

  /// Fetches a single patron's profile by internal ID.
  Future<Patron> getPatron(int patronId);

  /// Full-text search across the catalog (title/author/subject/ISBN).
  /// An empty query returns the full catalog.
  Future<List<Biblio>> searchCatalog(String query);

  /// Fetches a single biblio (title-level record) by ID.
  Future<Biblio> getBiblio(int biblioId);

  /// Fetches all physical item copies (holdings) for a biblio.
  Future<List<Item>> getItems(int biblioId);

  /// Fetches a single physical item by its internal ID. Needed to
  /// resolve a [Checkout.itemId] (or [Hold]/staff-scan barcode) down
  /// to a concrete item without already knowing its parent biblio.
  Future<Item> getItem(int itemId);

  /// Fetches all currently active (not yet returned) checkouts for a patron.
  Future<List<Checkout>> getCheckouts(int patronId);

  /// Renews an active checkout, extending its due date. Throws
  /// [LibraryException] if the renewal limit has been reached.
  Future<Checkout> renewCheckout(int checkoutId);

  /// Fetches all active holds (ready + in-queue) for a patron.
  Future<List<Hold>> getHolds(int patronId);

  /// Places a new hold for a patron on a biblio.
  Future<Hold> placeHold({
    required int patronId,
    required int biblioId,
  });

  /// Cancels an existing hold.
  Future<void> cancelHold(int holdId);

  /// Fetches a patron's account (outstanding + paid fine line items).
  Future<List<Fine>> getAccount(int patronId);

  /// Staff-only: checks an item out to a patron by item barcode/ID.
  Future<Checkout> staffCheckout({
    required int patronId,
    required int itemId,
  });

  /// Staff-only: checks an item back in, closing its checkout.
  Future<void> staffCheckin(int checkoutId);

  /// Staff-only: searches patrons by name, card number, or email.
  Future<List<Patron>> searchPatrons(String query);

  /// Staff-only: searches items by title, barcode, ISBN, or call number.
  Future<List<Item>> searchItems(String query);

  /// Fetches a patron's returned-checkout history (borrowing history).
  Future<List<Checkout>> getBorrowingHistory(int patronId);
}

/// Thrown by [LibraryRepository] implementations for all
/// domain-level failures (invalid login, renewal limit reached,
/// item unavailable, network failure once `KohaLibraryRepository`
/// exists, etc). Cubits catch this and map [message] straight into
/// their error state for display via `ErrorState`/`AppButton` retry.
class LibraryException implements Exception {
  const LibraryException(this.message);

  final String message;

  @override
  String toString() => 'LibraryException: $message';
}