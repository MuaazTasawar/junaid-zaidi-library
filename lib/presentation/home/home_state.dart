import 'package:equatable/equatable.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/item.dart';
import '../../data/models/patron.dart';

enum HomeStatus { loading, loaded, error }

/// View-model pairing a [Checkout] with its resolved [Item] and
/// [Biblio], so [HomeScreen] can render a [BookCover] + [DueDateStamp]
/// without doing any lookups itself (Golden Rule #2: no business
/// logic in widgets).
class BorrowedItemView extends Equatable {
  const BorrowedItemView({
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

class HomeState extends Equatable {
  const HomeState({
    required this.status,
    this.patron,
    this.borrowedItems = const [],
    this.newArrivals = const [],
    this.overdueCount = 0,
    this.errorMessage,
    this.isRenewingAll = false,
  });

  const HomeState.initial() : this(status: HomeStatus.loading);

  final HomeStatus status;
  final Patron? patron;
  final List<BorrowedItemView> borrowedItems;
  final List<Biblio> newArrivals;
  final int overdueCount;
  final String? errorMessage;
  final bool isRenewingAll;

  HomeState copyWith({
    HomeStatus? status,
    Patron? patron,
    List<BorrowedItemView>? borrowedItems,
    List<Biblio>? newArrivals,
    int? overdueCount,
    String? errorMessage,
    bool? isRenewingAll,
  }) {
    return HomeState(
      status: status ?? this.status,
      patron: patron ?? this.patron,
      borrowedItems: borrowedItems ?? this.borrowedItems,
      newArrivals: newArrivals ?? this.newArrivals,
      overdueCount: overdueCount ?? this.overdueCount,
      errorMessage: errorMessage,
      isRenewingAll: isRenewingAll ?? this.isRenewingAll,
    );
  }

  @override
  List<Object?> get props => [
    status,
    patron,
    borrowedItems,
    newArrivals,
    overdueCount,
    errorMessage,
    isRenewingAll,
  ];
}