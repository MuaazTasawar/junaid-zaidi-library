import 'package:equatable/equatable.dart';

/// Maps to Koha's `/api/v1/patrons/{patron_id}/account` line items
/// (Koha calls these "account lines").
///
/// Amounts are in PKR per the mock-data spec, stored as `double` to
/// match Koha's decimal account_line amounts.
class Fine extends Equatable {
  const Fine({
    required this.accountLineId,
    required this.amount,
    required this.amountoutstanding,
    required this.debitTypeCode,
    required this.description,
    required this.date,
  });

  final int accountLineId;
  final double amount;
  final double amountoutstanding;
  final String debitTypeCode;
  final String description;
  final DateTime date;

  bool get isPaid => amountoutstanding <= 0;

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      accountLineId: json['account_line_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      amountoutstanding: (json['amountoutstanding'] as num).toDouble(),
      debitTypeCode: json['debit_type_code'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_line_id': accountLineId,
      'amount': amount,
      'amountoutstanding': amountoutstanding,
      'debit_type_code': debitTypeCode,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  Fine copyWith({
    int? accountLineId,
    double? amount,
    double? amountoutstanding,
    String? debitTypeCode,
    String? description,
    DateTime? date,
  }) {
    return Fine(
      accountLineId: accountLineId ?? this.accountLineId,
      amount: amount ?? this.amount,
      amountoutstanding: amountoutstanding ?? this.amountoutstanding,
      debitTypeCode: debitTypeCode ?? this.debitTypeCode,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
    accountLineId,
    amount,
    amountoutstanding,
    debitTypeCode,
    description,
    date,
  ];
}