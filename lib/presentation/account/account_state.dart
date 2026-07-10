import 'package:equatable/equatable.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/fine.dart';
import '../../data/models/hold.dart';
import '../../data/models/item.dart';

enum SectionStatus { idle, loading, loaded, error }

/// View-model pairing a [Checkout] with its resolved [Item] and
/// [Biblio] — used by both CheckoutsScreen (active loans) and
/// HistoryScreen (returned loans), mirroring the pattern established
/// by `HomeState.BorrowedItemView` in Phase 8.
class CheckoutView extends Equatable {
  const CheckoutView({
    required this.checkout,
    required this.item,
    required this.biblio,
  });

  final Checkout checkout;
  final Item item;
  final Biblio biblio;

  @override
  List<Object?> get props => [checkout, item, biblio];
}

/// View-model pairing a [Hold] with its resolved [Biblio].
class HoldView extends Equatable {
  const HoldView({required this.hold, required this.biblio});

  final Hold hold;
  final Biblio biblio;

  @override
  List<Object?> get props => [hold, biblio];
}

class AccountState extends Equatable {
  const AccountState({
    this.checkoutsStatus = SectionStatus.idle,
    this.checkouts = const [],
    this.checkoutsErrorMessage,
    this.holdsStatus = SectionStatus.idle,
    this.holds = const [],
    this.holdsErrorMessage,
    this.finesStatus = SectionStatus.idle,
    this.fines = const [],
    this.finesErrorMessage,
    this.historyStatus = SectionStatus.idle,
    this.history = const [],
    this.historyErrorMessage,
    this.renewingCheckoutId,
    this.renewError,
    this.renewSuccess = false,
  });

  final SectionStatus checkoutsStatus;
  final List<CheckoutView> checkouts;
  final String? checkoutsErrorMessage;

  final SectionStatus holdsStatus;
  final List<HoldView> holds;
  final String? holdsErrorMessage;

  final SectionStatus finesStatus;
  final List<Fine> fines;
  final String? finesErrorMessage;

  final SectionStatus historyStatus;
  final List<CheckoutView> history;
  final String? historyErrorMessage;

  final int? renewingCheckoutId;
  final String? renewError;
  final bool renewSuccess;

  double get outstandingBalance =>
      fines.fold(0, (sum, f) => sum + f.amountoutstanding);

  List<HoldView> get readyForPickup => holds.where((h) => h.hold.isReadyForPickup).toList();
  List<HoldView> get inQueue => holds.where((h) => !h.hold.isReadyForPickup).toList();

  AccountState copyWith({
    SectionStatus? checkoutsStatus,
    List<CheckoutView>? checkouts,
    String? checkoutsErrorMessage,
    bool clearCheckoutsError = false,
    SectionStatus? holdsStatus,
    List<HoldView>? holds,
    String? holdsErrorMessage,
    bool clearHoldsError = false,
    SectionStatus? finesStatus,
    List<Fine>? fines,
    String? finesErrorMessage,
    bool clearFinesError = false,
    SectionStatus? historyStatus,
    List<CheckoutView>? history,
    String? historyErrorMessage,
    bool clearHistoryError = false,
    int? renewingCheckoutId,
    bool clearRenewingCheckoutId = false,
    String? renewError,
    bool clearRenewError = false,
    bool? renewSuccess,
  }) {
    return AccountState(
      checkoutsStatus: checkoutsStatus ?? this.checkoutsStatus,
      checkouts: checkouts ?? this.checkouts,
      checkoutsErrorMessage:
      clearCheckoutsError ? null : (checkoutsErrorMessage ?? this.checkoutsErrorMessage),
      holdsStatus: holdsStatus ?? this.holdsStatus,
      holds: holds ?? this.holds,
      holdsErrorMessage: clearHoldsError ? null : (holdsErrorMessage ?? this.holdsErrorMessage),
      finesStatus: finesStatus ?? this.finesStatus,
      fines: fines ?? this.fines,
      finesErrorMessage: clearFinesError ? null : (finesErrorMessage ?? this.finesErrorMessage),
      historyStatus: historyStatus ?? this.historyStatus,
      history: history ?? this.history,
      historyErrorMessage:
      clearHistoryError ? null : (historyErrorMessage ?? this.historyErrorMessage),
      renewingCheckoutId:
      clearRenewingCheckoutId ? null : (renewingCheckoutId ?? this.renewingCheckoutId),
      renewError: clearRenewError ? null : (renewError ?? this.renewError),
      renewSuccess: renewSuccess ?? this.renewSuccess,
    );
  }

  @override
  List<Object?> get props => [
    checkoutsStatus,
    checkouts,
    checkoutsErrorMessage,
    holdsStatus,
    holds,
    holdsErrorMessage,
    finesStatus,
    fines,
    finesErrorMessage,
    historyStatus,
    history,
    historyErrorMessage,
    renewingCheckoutId,
    renewError,
    renewSuccess,
  ];
}