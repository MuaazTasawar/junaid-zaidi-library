import 'package:equatable/equatable.dart';

/// Maps to Koha's `/api/v1/patrons/{patron_id}` resource.
///
/// `categorycode` drives patron-vs-staff routing after login (per
/// LoginScreen spec: staff categorycodes route to the staff home,
/// everything else routes to the patron home).
class Patron extends Equatable {
  const Patron({
    required this.patronId,
    required this.borrowernumber,
    required this.cardnumber,
    required this.firstname,
    required this.surname,
    required this.email,
    required this.categorycode,
    required this.branchcode,
  });

  final int patronId;
  final int borrowernumber;
  final String cardnumber;
  final String firstname;
  final String surname;
  final String email;
  final String categorycode;
  final String branchcode;

  String get fullName => '$firstname $surname';

  bool get isStaff => categorycode == 'STAFF';

  factory Patron.fromJson(Map<String, dynamic> json) {
    return Patron(
      patronId: json['patron_id'] as int,
      borrowernumber: json['borrowernumber'] as int,
      cardnumber: json['cardnumber'] as String,
      firstname: json['firstname'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String? ?? '',
      categorycode: json['categorycode'] as String? ?? 'PT',
      branchcode: json['branchcode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patron_id': patronId,
      'borrowernumber': borrowernumber,
      'cardnumber': cardnumber,
      'firstname': firstname,
      'surname': surname,
      'email': email,
      'categorycode': categorycode,
      'branchcode': branchcode,
    };
  }

  Patron copyWith({
    int? patronId,
    int? borrowernumber,
    String? cardnumber,
    String? firstname,
    String? surname,
    String? email,
    String? categorycode,
    String? branchcode,
  }) {
    return Patron(
      patronId: patronId ?? this.patronId,
      borrowernumber: borrowernumber ?? this.borrowernumber,
      cardnumber: cardnumber ?? this.cardnumber,
      firstname: firstname ?? this.firstname,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      categorycode: categorycode ?? this.categorycode,
      branchcode: branchcode ?? this.branchcode,
    );
  }

  @override
  List<Object?> get props => [
    patronId,
    borrowernumber,
    cardnumber,
    firstname,
    surname,
    email,
    categorycode,
    branchcode,
  ];
}