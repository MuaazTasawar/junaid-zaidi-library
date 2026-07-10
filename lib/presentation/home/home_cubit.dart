import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/item.dart';
import '../../data/models/patron.dart';
import '../../data/repositories/library_repository.dart';
import 'home_state.dart';

/// Loads everything HomeScreen needs: the patron's active checkouts
/// (resolved into [BorrowedItemView]s via [LibraryRepository.getItem]
/// + [LibraryRepository.getBiblio]), an overdue count for the alert
/// banner, and a "new arrivals" slice of the catalog sorted by
/// copyright year.
///
/// All repository calls and cross-referencing (checkout → item →
/// biblio) happen here, never in the widget tree.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState.initial());

  final LibraryRepository _repository;

  Future<void> loadHome(Patron patron) async {
    emit(state.copyWith(status: HomeStatus.loading, patron: patron));

    try {
      final List<Checkout> checkouts =
      await _repository.getCheckouts(patron.patronId);

      final List<BorrowedItemView> borrowed = [];
      for (final Checkout checkout in checkouts) {
        final Item item = await _repository.getItem(checkout.itemId);
        final Biblio biblio = await _repository.getBiblio(item.biblioId);
        borrowed.add(
          BorrowedItemView(checkout: checkout, item: item, biblio: biblio),
        );
      }

      final int overdueCount = checkouts.where((c) => c.isOverdue).length;

      final List<Biblio> allBiblios = await _repository.searchCatalog('');
      final List<Biblio> newArrivals = List.of(allBiblios)
        ..sort((a, b) => b.copyrightdate.compareTo(a.copyrightdate));

      emit(state.copyWith(
        status: HomeStatus.loaded,
        borrowedItems: borrowed,
        newArrivals: newArrivals.take(8).toList(),
        overdueCount: overdueCount,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.message));
    }
  }

  /// Renews every overdue or due-soon checkout in one pass, for the
  /// "Renew All" quick action. Renewals that individually fail (e.g.
  /// limit reached) are skipped silently in this pass; the next
  /// screen visit will surface them as still-overdue in the list.
  Future<void> renewAll() async {
    final Patron? patron = state.patron;
    if (patron == null) return;

    emit(state.copyWith(isRenewingAll: true));

    final List<BorrowedItemView> toRenew = state.borrowedItems
        .where((b) => b.checkout.isOverdue || b.checkout.isDueSoon)
        .toList();

    for (final BorrowedItemView view in toRenew) {
      try {
        await _repository.renewCheckout(view.checkout.checkoutId);
      } on LibraryException {
        // Skip — surfaced on next full reload via loadHome().
      }
    }

    emit(state.copyWith(isRenewingAll: false));
    await loadHome(patron);
  }
}