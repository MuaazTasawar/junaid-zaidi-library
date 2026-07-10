import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/item.dart';
import '../../data/repositories/library_repository.dart';
import 'account_state.dart';

/// Owns all "My Account" data: checkouts, holds, fines, and
/// borrowing history — shared across AccountHome and its 5 pushed
/// sub-screens (see Phase 10 architecture note).
class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._repository) : super(const AccountState());

  final LibraryRepository _repository;

  /// Loads checkouts + holds + fines together — used by
  /// AccountHomeScreen to populate its 3 stat cards in one call.
  Future<void> loadOverview(int patronId) async {
    await Future.wait([
      loadCheckouts(patronId),
      loadHolds(patronId),
      loadFines(patronId),
    ]);
  }

  Future<void> loadCheckouts(int patronId) async {
    emit(state.copyWith(checkoutsStatus: SectionStatus.loading, clearCheckoutsError: true));

    try {
      final List<Checkout> checkouts = await _repository.getCheckouts(patronId);
      final List<CheckoutView> views = [];
      for (final Checkout c in checkouts) {
        final Item item = await _repository.getItem(c.itemId);
        final Biblio biblio = await _repository.getBiblio(item.biblioId);
        views.add(CheckoutView(checkout: c, item: item, biblio: biblio));
      }

      // Sort per spec: overdue → due soon → safe.
      views.sort((a, b) {
        int rank(Checkout c) => c.isOverdue ? 0 : (c.isDueSoon ? 1 : 2);
        return rank(a.checkout).compareTo(rank(b.checkout));
      });

      emit(state.copyWith(checkoutsStatus: SectionStatus.loaded, checkouts: views));
    } on LibraryException catch (e) {
      emit(state.copyWith(checkoutsStatus: SectionStatus.error, checkoutsErrorMessage: e.message));
    }
  }

  Future<void> loadHolds(int patronId) async {
    emit(state.copyWith(holdsStatus: SectionStatus.loading, clearHoldsError: true));

    try {
      final holds = await _repository.getHolds(patronId);
      final List<HoldView> views = [];
      for (final h in holds) {
        final biblio = await _repository.getBiblio(h.biblioId);
        views.add(HoldView(hold: h, biblio: biblio));
      }
      emit(state.copyWith(holdsStatus: SectionStatus.loaded, holds: views));
    } on LibraryException catch (e) {
      emit(state.copyWith(holdsStatus: SectionStatus.error, holdsErrorMessage: e.message));
    }
  }

  Future<void> cancelHold(int holdId, int patronId) async {
    try {
      await _repository.cancelHold(holdId);
      await loadHolds(patronId);
    } on LibraryException catch (e) {
      emit(state.copyWith(holdsErrorMessage: e.message));
    }
  }

  Future<void> loadFines(int patronId) async {
    emit(state.copyWith(finesStatus: SectionStatus.loading, clearFinesError: true));

    try {
      final fines = await _repository.getAccount(patronId);
      emit(state.copyWith(finesStatus: SectionStatus.loaded, fines: fines));
    } on LibraryException catch (e) {
      emit(state.copyWith(finesStatus: SectionStatus.error, finesErrorMessage: e.message));
    }
  }

  Future<void> loadHistory(int patronId) async {
    emit(state.copyWith(historyStatus: SectionStatus.loading, clearHistoryError: true));

    try {
      final List<Checkout> returned = await _repository.getBorrowingHistory(patronId);
      final List<CheckoutView> views = [];
      for (final c in returned) {
        final item = await _repository.getItem(c.itemId);
        final biblio = await _repository.getBiblio(item.biblioId);
        views.add(CheckoutView(checkout: c, item: item, biblio: biblio));
      }
      views.sort((a, b) => b.checkout.issuedate.compareTo(a.checkout.issuedate));
      emit(state.copyWith(historyStatus: SectionStatus.loaded, history: views));
    } on LibraryException catch (e) {
      emit(state.copyWith(historyStatus: SectionStatus.error, historyErrorMessage: e.message));
    }
  }

  Future<void> renewCheckout(int checkoutId, int patronId) async {
    emit(state.copyWith(
      renewingCheckoutId: checkoutId,
      clearRenewError: true,
      renewSuccess: false,
    ));

    try {
      await _repository.renewCheckout(checkoutId);
      emit(state.copyWith(renewSuccess: true, clearRenewingCheckoutId: true));
      await loadCheckouts(patronId);
    } on LibraryException catch (e) {
      emit(state.copyWith(clearRenewingCheckoutId: true, renewError: e.message));
    }
  }

  void resetRenewFlow() {
    emit(state.copyWith(renewSuccess: false, clearRenewError: true));
  }
}