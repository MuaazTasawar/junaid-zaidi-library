import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/item.dart';
import '../../data/models/patron.dart';
import '../../data/repositories/library_repository.dart';
import 'staff_state.dart';

/// Owns all staff-facing flows: scan-checkout, scan-checkin, patron
/// search + account, item search + detail, and the session-only
/// recent-activity log (see Phase 14 notes).
class StaffCubit extends Cubit<StaffState> {
  StaffCubit(this._repository) : super(const StaffState());

  final LibraryRepository _repository;

  void _logActivity({required String patronName, required String bookTitle, required bool isCheckout}) {
    final List<ActivityLogEntry> updated = [
      ActivityLogEntry(
        patronName: patronName,
        bookTitle: bookTitle,
        isCheckout: isCheckout,
        timestamp: DateTime.now(),
      ),
      ...recentActivity,
    ].take(5).toList();
    emit(state.copyWith(recentActivity: updated));
  }

  List<ActivityLogEntry> get recentActivity => state.recentActivity;

  // ── Scan checkout (2-step) ──────────────────────────────

  Future<void> scanPatronForCheckout(String cardOrQuery) async {
    emit(state.copyWith(clearCheckoutError: true));
    try {
      final List<Patron> matches = await _repository.searchPatrons(cardOrQuery);
      if (matches.isEmpty) {
        emit(state.copyWith(checkoutError: 'No patron found for that card number.'));
        return;
      }
      final Patron patron = matches.first;
      final checkouts = await _repository.getCheckouts(patron.patronId);
      emit(state.copyWith(
        scannedPatron: patron,
        scannedPatronCheckoutCount: checkouts.length,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(checkoutError: e.message));
    }
  }

  Future<void> scanItemForCheckout(String barcodeOrQuery) async {
    emit(state.copyWith(clearCheckoutError: true));
    try {
      final List<Item> matches = await _repository.searchItems(barcodeOrQuery);
      if (matches.isEmpty) {
        emit(state.copyWith(checkoutError: 'No item found for that barcode.'));
        return;
      }
      final Item item = matches.first;
      final Biblio biblio = await _repository.getBiblio(item.biblioId);
      emit(state.copyWith(checkoutScannedItem: item, checkoutScannedBiblio: biblio));
    } on LibraryException catch (e) {
      emit(state.copyWith(checkoutError: e.message));
    }
  }

  Future<void> confirmCheckout() async {
    final patron = state.scannedPatron;
    final item = state.checkoutScannedItem;
    final biblio = state.checkoutScannedBiblio;
    if (patron == null || item == null || biblio == null) return;

    emit(state.copyWith(isConfirmingCheckout: true, clearCheckoutError: true));
    try {
      await _repository.staffCheckout(patronId: patron.patronId, itemId: item.itemId);
      _logActivity(patronName: patron.fullName, bookTitle: biblio.title, isCheckout: true);
      emit(state.copyWith(isConfirmingCheckout: false));
      resetCheckoutFlow();
    } on LibraryException catch (e) {
      emit(state.copyWith(isConfirmingCheckout: false, checkoutError: e.message));
    }
  }

  void resetCheckoutFlow() {
    emit(state.copyWith(
      clearScannedPatron: true,
      clearCheckoutScannedItem: true,
      scannedPatronCheckoutCount: 0,
      clearCheckoutError: true,
    ));
  }

  // ── Scan checkin ──────────────────────────────

  Future<void> scanItemForCheckin(String barcodeOrQuery) async {
    emit(state.copyWith(clearCheckinError: true, checkinSuccess: false));
    try {
      final List<Item> matches = await _repository.searchItems(barcodeOrQuery);
      if (matches.isEmpty) {
        emit(state.copyWith(checkinError: 'No item found for that barcode.'));
        return;
      }
      final Item item = matches.first;
      final Biblio biblio = await _repository.getBiblio(item.biblioId);

      Checkout? previousCheckout;
      Patron? previousPatron;
      try {
        previousCheckout = await _repository.getCheckoutForItem(item.itemId);
        previousPatron = await _repository.getPatron(previousCheckout.patronId);
      } on LibraryException {
        // Not currently checked out — fine, checkin screen will show
        // "not currently on loan" via the null previousCheckout.
      }

      emit(state.copyWith(
        checkinScannedItem: item,
        checkinScannedBiblio: biblio,
        checkinPreviousCheckout: previousCheckout,
        checkinPreviousPatron: previousPatron,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(checkinError: e.message));
    }
  }

  void setCheckinCondition(ItemCondition condition) {
    emit(state.copyWith(checkinCondition: condition));
  }

  Future<void> confirmCheckin() async {
    final checkout = state.checkinPreviousCheckout;
    final biblio = state.checkinScannedBiblio;
    final patron = state.checkinPreviousPatron;
    if (checkout == null || biblio == null) return;

    emit(state.copyWith(isConfirmingCheckin: true, clearCheckinError: true));
    try {
      await _repository.staffCheckin(checkout.checkoutId);
      _logActivity(
        patronName: patron?.fullName ?? 'Unknown patron',
        bookTitle: biblio.title,
        isCheckout: false,
      );
      emit(state.copyWith(isConfirmingCheckin: false, checkinSuccess: true));
    } on LibraryException catch (e) {
      emit(state.copyWith(isConfirmingCheckin: false, checkinError: e.message));
    }
  }

  void resetCheckinFlow() {
    emit(const StaffState().copyWith(recentActivity: state.recentActivity));
  }

  // ── Patron search ──────────────────────────────

  Future<void> searchPatrons(String query) async {
    emit(state.copyWith(patronSearchStatus: SectionStatus.loading));
    try {
      final List<Patron> results = await _repository.searchPatrons(query);

      final Map<int, int> counts = {};
      final Map<int, double> balances = {};
      for (final p in results) {
        final checkouts = await _repository.getCheckouts(p.patronId);
        final fines = await _repository.getAccount(p.patronId);
        counts[p.patronId] = checkouts.length;
        balances[p.patronId] = fines.fold(0, (sum, f) => sum + f.amountoutstanding);
      }

      emit(state.copyWith(
        patronSearchStatus: SectionStatus.loaded,
        patronResults: results,
        patronCheckoutCounts: counts,
        patronFineBalances: balances,
      ));
    } on LibraryException {
      emit(state.copyWith(patronSearchStatus: SectionStatus.error));
    }
  }

  // ── Staff patron account ──────────────────────────────

  Future<void> loadStaffPatronAccount(int patronId) async {
    emit(state.copyWith(staffPatronAccountStatus: SectionStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getPatron(patronId),
        _repository.getCheckouts(patronId),
        _repository.getHolds(patronId),
        _repository.getAccount(patronId),
      ]);

      emit(state.copyWith(
        staffPatronAccountStatus: SectionStatus.loaded,
        staffPatron: results[0] as Patron,
        staffPatronCheckouts: results[1] as List<Checkout>,
        staffPatronHolds: results[2] as List,
        staffPatronFines: results[3] as List,
      ));
    } on LibraryException {
      emit(state.copyWith(staffPatronAccountStatus: SectionStatus.error));
    }
  }

  Future<void> forceRenew(int checkoutId, int patronId) async {
    emit(state.copyWith(forceRenewingCheckoutId: checkoutId));
    try {
      await _repository.renewCheckout(checkoutId);
    } on LibraryException {
      // Staff force-renew still respects the renewal limit in this
      // mock; a real Koha staff override would bypass it server-side.
    }
    emit(state.copyWith(clearForceRenewing: true));
    await loadStaffPatronAccount(patronId);
  }

  // ── Item search ──────────────────────────────

  Future<void> searchItems(String query) async {
    emit(state.copyWith(itemSearchStatus: SectionStatus.loading));
    try {
      final List<Item> results = await _repository.searchItems(query);
      emit(state.copyWith(itemSearchStatus: SectionStatus.loaded, itemResults: results));
    } on LibraryException {
      emit(state.copyWith(itemSearchStatus: SectionStatus.error));
    }
  }

  // ── Item detail ──────────────────────────────

  Future<void> loadItemDetail(int itemId) async {
    emit(state.copyWith(itemDetailStatus: SectionStatus.loading));
    try {
      final Item item = await _repository.getItem(itemId);
      final Biblio biblio = await _repository.getBiblio(item.biblioId);

      Checkout? checkout;
      Patron? patron;
      try {
        checkout = await _repository.getCheckoutForItem(itemId);
        patron = await _repository.getPatron(checkout.patronId);
      } on LibraryException {
        // Not checked out — fine.
      }

      emit(state.copyWith(
        itemDetailStatus: SectionStatus.loaded,
        detailItem: item,
        detailBiblio: biblio,
        detailCurrentCheckout: checkout,
        detailCurrentPatron: patron,
      ));
    } on LibraryException {
      emit(state.copyWith(itemDetailStatus: SectionStatus.error));
    }
  }
}