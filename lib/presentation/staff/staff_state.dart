import 'package:equatable/equatable.dart';

import '../../data/models/biblio.dart';
import '../../data/models/checkout.dart';
import '../../data/models/fine.dart';
import '../../data/models/hold.dart';
import '../../data/models/item.dart';
import '../../data/models/patron.dart';

enum SectionStatus { idle, loading, loaded, error }
enum ItemCondition { good, damaged, lost }

/// A single "recent activity" entry for StaffHomeScreen. Built
/// in-memory as staff perform checkouts/checkins this session — see
/// Phase 14 note: there's no Koha activity-log endpoint to fetch this
/// from, so it does not persist across app restarts.
class ActivityLogEntry extends Equatable {
  const ActivityLogEntry({
    required this.patronName,
    required this.bookTitle,
    required this.isCheckout,
    required this.timestamp,
  });

  final String patronName;
  final String bookTitle;
  final bool isCheckout;
  final DateTime timestamp;

  @override
  List<Object?> get props => [patronName, bookTitle, isCheckout, timestamp];
}

class StaffState extends Equatable {
  const StaffState({
    this.recentActivity = const [],

    // Checkout scan flow
    this.scannedPatron,
    this.scannedPatronCheckoutCount = 0,
    this.checkoutScannedItem,
    this.checkoutScannedBiblio,
    this.isConfirmingCheckout = false,
    this.checkoutError,

    // Checkin scan flow
    this.checkinScannedItem,
    this.checkinScannedBiblio,
    this.checkinPreviousCheckout,
    this.checkinPreviousPatron,
    this.checkinCondition = ItemCondition.good,
    this.isConfirmingCheckin = false,
    this.checkinSuccess = false,
    this.checkinError,

    // Patron search
    this.patronSearchStatus = SectionStatus.idle,
    this.patronResults = const [],
    this.patronCheckoutCounts = const {},
    this.patronFineBalances = const {},

    // Patron account (staff view)
    this.staffPatronAccountStatus = SectionStatus.idle,
    this.staffPatron,
    this.staffPatronCheckouts = const [],
    this.staffPatronHolds = const [],
    this.staffPatronFines = const [],
    this.forceRenewingCheckoutId,

    // Item search
    this.itemSearchStatus = SectionStatus.idle,
    this.itemResults = const [],

    // Item detail
    this.itemDetailStatus = SectionStatus.idle,
    this.detailItem,
    this.detailBiblio,
    this.detailCurrentCheckout,
    this.detailCurrentPatron,
  });

  final List<ActivityLogEntry> recentActivity;

  final Patron? scannedPatron;
  final int scannedPatronCheckoutCount;
  final Item? checkoutScannedItem;
  final Biblio? checkoutScannedBiblio;
  final bool isConfirmingCheckout;
  final String? checkoutError;

  final Item? checkinScannedItem;
  final Biblio? checkinScannedBiblio;
  final Checkout? checkinPreviousCheckout;
  final Patron? checkinPreviousPatron;
  final ItemCondition checkinCondition;
  final bool isConfirmingCheckin;
  final bool checkinSuccess;
  final String? checkinError;

  final SectionStatus patronSearchStatus;
  final List<Patron> patronResults;
  final Map<int, int> patronCheckoutCounts;
  final Map<int, double> patronFineBalances;

  final SectionStatus staffPatronAccountStatus;
  final Patron? staffPatron;
  final List<Checkout> staffPatronCheckouts;
  final List<Hold> staffPatronHolds;
  final List<Fine> staffPatronFines;
  final int? forceRenewingCheckoutId;

  final SectionStatus itemSearchStatus;
  final List<Item> itemResults;

  final SectionStatus itemDetailStatus;
  final Item? detailItem;
  final Biblio? detailBiblio;
  final Checkout? detailCurrentCheckout;
  final Patron? detailCurrentPatron;

  StaffState copyWith({
    List<ActivityLogEntry>? recentActivity,
    Patron? scannedPatron,
    bool clearScannedPatron = false,
    int? scannedPatronCheckoutCount,
    Item? checkoutScannedItem,
    bool clearCheckoutScannedItem = false,
    Biblio? checkoutScannedBiblio,
    bool? isConfirmingCheckout,
    String? checkoutError,
    bool clearCheckoutError = false,
    Item? checkinScannedItem,
    bool clearCheckinScannedItem = false,
    Biblio? checkinScannedBiblio,
    Checkout? checkinPreviousCheckout,
    Patron? checkinPreviousPatron,
    ItemCondition? checkinCondition,
    bool? isConfirmingCheckin,
    bool? checkinSuccess,
    String? checkinError,
    bool clearCheckinError = false,
    SectionStatus? patronSearchStatus,
    List<Patron>? patronResults,
    Map<int, int>? patronCheckoutCounts,
    Map<int, double>? patronFineBalances,
    SectionStatus? staffPatronAccountStatus,
    Patron? staffPatron,
    List<Checkout>? staffPatronCheckouts,
    List<Hold>? staffPatronHolds,
    List<Fine>? staffPatronFines,
    int? forceRenewingCheckoutId,
    bool clearForceRenewing = false,
    SectionStatus? itemSearchStatus,
    List<Item>? itemResults,
    SectionStatus? itemDetailStatus,
    Item? detailItem,
    Biblio? detailBiblio,
    Checkout? detailCurrentCheckout,
    Patron? detailCurrentPatron,
  }) {
    return StaffState(
      recentActivity: recentActivity ?? this.recentActivity,
      scannedPatron: clearScannedPatron ? null : (scannedPatron ?? this.scannedPatron),
      scannedPatronCheckoutCount: scannedPatronCheckoutCount ?? this.scannedPatronCheckoutCount,
      checkoutScannedItem:
      clearCheckoutScannedItem ? null : (checkoutScannedItem ?? this.checkoutScannedItem),
      checkoutScannedBiblio: checkoutScannedBiblio ?? this.checkoutScannedBiblio,
      isConfirmingCheckout: isConfirmingCheckout ?? this.isConfirmingCheckout,
      checkoutError: clearCheckoutError ? null : (checkoutError ?? this.checkoutError),
      checkinScannedItem:
      clearCheckinScannedItem ? null : (checkinScannedItem ?? this.checkinScannedItem),
      checkinScannedBiblio: checkinScannedBiblio ?? this.checkinScannedBiblio,
      checkinPreviousCheckout: checkinPreviousCheckout ?? this.checkinPreviousCheckout,
      checkinPreviousPatron: checkinPreviousPatron ?? this.checkinPreviousPatron,
      checkinCondition: checkinCondition ?? this.checkinCondition,
      isConfirmingCheckin: isConfirmingCheckin ?? this.isConfirmingCheckin,
      checkinSuccess: checkinSuccess ?? this.checkinSuccess,
      checkinError: clearCheckinError ? null : (checkinError ?? this.checkinError),
      patronSearchStatus: patronSearchStatus ?? this.patronSearchStatus,
      patronResults: patronResults ?? this.patronResults,
      patronCheckoutCounts: patronCheckoutCounts ?? this.patronCheckoutCounts,
      patronFineBalances: patronFineBalances ?? this.patronFineBalances,
      staffPatronAccountStatus: staffPatronAccountStatus ?? this.staffPatronAccountStatus,
      staffPatron: staffPatron ?? this.staffPatron,
      staffPatronCheckouts: staffPatronCheckouts ?? this.staffPatronCheckouts,
      staffPatronHolds: staffPatronHolds ?? this.staffPatronHolds,
      staffPatronFines: staffPatronFines ?? this.staffPatronFines,
      forceRenewingCheckoutId:
      clearForceRenewing ? null : (forceRenewingCheckoutId ?? this.forceRenewingCheckoutId),
      itemSearchStatus: itemSearchStatus ?? this.itemSearchStatus,
      itemResults: itemResults ?? this.itemResults,
      itemDetailStatus: itemDetailStatus ?? this.itemDetailStatus,
      detailItem: detailItem ?? this.detailItem,
      detailBiblio: detailBiblio ?? this.detailBiblio,
      detailCurrentCheckout: detailCurrentCheckout ?? this.detailCurrentCheckout,
      detailCurrentPatron: detailCurrentPatron ?? this.detailCurrentPatron,
    );
  }

  @override
  List<Object?> get props => [
    recentActivity,
    scannedPatron,
    scannedPatronCheckoutCount,
    checkoutScannedItem,
    checkoutScannedBiblio,
    isConfirmingCheckout,
    checkoutError,
    checkinScannedItem,
    checkinScannedBiblio,
    checkinPreviousCheckout,
    checkinPreviousPatron,
    checkinCondition,
    isConfirmingCheckin,
    checkinSuccess,
    checkinError,
    patronSearchStatus,
    patronResults,
    patronCheckoutCounts,
    patronFineBalances,
    staffPatronAccountStatus,
    staffPatron,
    staffPatronCheckouts,
    staffPatronHolds,
    staffPatronFines,
    forceRenewingCheckoutId,
    itemSearchStatus,
    itemResults,
    itemDetailStatus,
    detailItem,
    detailBiblio,
    detailCurrentCheckout,
    detailCurrentPatron,
  ];
}