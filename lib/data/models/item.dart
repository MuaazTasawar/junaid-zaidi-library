import 'package:equatable/equatable.dart';

/// Maps to Koha's `/api/v1/biblios/{biblio_id}/items` /
/// `/api/v1/items` resource — a physical copy of a [Biblio].
///
/// `notforloan`: Koha convention — 0 means loanable, any non-zero
/// code means restricted (e.g. reference-only, damaged, lost).
/// `onloan`: null when available, else the due date ISO string.
class Item extends Equatable {
  const Item({
    required this.itemId,
    required this.itemnumber,
    required this.biblioId,
    required this.holdingbranch,
    required this.location,
    required this.itemcallnumber,
    required this.notforloan,
    required this.onloan,
  });

  final int itemId;
  final int itemnumber;
  final int biblioId;
  final String holdingbranch;
  final String location;
  final String itemcallnumber;
  final int notforloan;
  final String? onloan;

  bool get isAvailable => notforloan == 0 && onloan == null;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'] as int,
      itemnumber: json['itemnumber'] as int,
      biblioId: json['biblio_id'] as int,
      holdingbranch: json['holdingbranch'] as String? ?? '',
      location: json['location'] as String? ?? '',
      itemcallnumber: json['itemcallnumber'] as String? ?? '',
      notforloan: json['notforloan'] as int? ?? 0,
      onloan: json['onloan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'itemnumber': itemnumber,
      'biblio_id': biblioId,
      'holdingbranch': holdingbranch,
      'location': location,
      'itemcallnumber': itemcallnumber,
      'notforloan': notforloan,
      'onloan': onloan,
    };
  }

  Item copyWith({
    int? itemId,
    int? itemnumber,
    int? biblioId,
    String? holdingbranch,
    String? location,
    String? itemcallnumber,
    int? notforloan,
    String? onloan,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      itemnumber: itemnumber ?? this.itemnumber,
      biblioId: biblioId ?? this.biblioId,
      holdingbranch: holdingbranch ?? this.holdingbranch,
      location: location ?? this.location,
      itemcallnumber: itemcallnumber ?? this.itemcallnumber,
      notforloan: notforloan ?? this.notforloan,
      onloan: onloan ?? this.onloan,
    );
  }

  @override
  List<Object?> get props => [
    itemId,
    itemnumber,
    biblioId,
    holdingbranch,
    location,
    itemcallnumber,
    notforloan,
    onloan,
  ];
}