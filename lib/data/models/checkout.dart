import 'package:equatable/equatable.dart';

/// Maps to Koha's `/api/v1/checkouts` resource.
class Checkout extends Equatable {
  const Checkout({
    required this.checkoutId,
    required this.patronId,
    required this.itemId,
    required this.dueDate,
    required this.issuedate,
    required this.renewalsCount,
  });

  final int checkoutId;
  final int patronId;
  final int itemId;
  final DateTime dueDate;
  final DateTime issuedate;
  final int renewalsCount;

  bool get isOverdue => dueDate.isBefore(DateTime.now());

  bool get isDueSoon {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !due.isBefore(todayDate) &&
        !due.isAfter(todayDate.add(const Duration(days: 3)));
  }

  factory Checkout.fromJson(Map<String, dynamic> json) {
    return Checkout(
      checkoutId: json['checkout_id'] as int,
      patronId: json['patron_id'] as int,
      itemId: json['item_id'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      issuedate: DateTime.parse(json['issuedate'] as String),
      renewalsCount: json['renewals_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkout_id': checkoutId,
      'patron_id': patronId,
      'item_id': itemId,
      'due_date': dueDate.toIso8601String(),
      'issuedate': issuedate.toIso8601String(),
      'renewals_count': renewalsCount,
    };
  }

  Checkout copyWith({
    int? checkoutId,
    int? patronId,
    int? itemId,
    DateTime? dueDate,
    DateTime? issuedate,
    int? renewalsCount,
  }) {
    return Checkout(
      checkoutId: checkoutId ?? this.checkoutId,
      patronId: patronId ?? this.patronId,
      itemId: itemId ?? this.itemId,
      dueDate: dueDate ?? this.dueDate,
      issuedate: issuedate ?? this.issuedate,
      renewalsCount: renewalsCount ?? this.renewalsCount,
    );
  }

  @override
  List<Object?> get props =>
      [checkoutId, patronId, itemId, dueDate, issuedate, renewalsCount];
}