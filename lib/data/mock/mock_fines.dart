import '../models/fine.dart';

/// Mock fines in PKR. Patron 1 (Ali Hassan) carries PKR 180
/// outstanding across two line items (exceeding the PKR 150 minimum
/// from the spec); patron 2 has one fully paid fine to demo the
/// "Paid fines" collapsed section on FinesScreen.
class MockFines {
  const MockFines._();

  static final DateTime _now = DateTime.now();

  static final List<Fine> all = [
    // Patron 1 — outstanding
    Fine(
      accountLineId: 1,
      amount: 80,
      amountoutstanding: 80,
      debitTypeCode: 'OVERDUE',
      description: 'Overdue fine — Introduction to Algorithms',
      date: _now.subtract(const Duration(days: 5)),
    ),
    Fine(
      accountLineId: 2,
      amount: 100,
      amountoutstanding: 100,
      debitTypeCode: 'OVERDUE',
      description: 'Overdue fine — Digital Design and Computer Architecture',
      date: _now.subtract(const Duration(days: 3)),
    ),

    // Patron 2 — paid
    Fine(
      accountLineId: 3,
      amount: 30,
      amountoutstanding: 0,
      debitTypeCode: 'OVERDUE',
      description: 'Overdue fine — A Tale of Two Cities',
      date: _now.subtract(const Duration(days: 40)),
    ),
  ];

  static List<Fine> outstandingByPatronId(int patronId) => all
      .where((f) => f.amountoutstanding > 0)
  // NOTE: patron linkage is resolved by MockLibraryRepository
  // (Phase 5) which maps account lines to patrons; kept flat here
  // since Koha's account_line resource doesn't carry patron_id
  // directly in the same shape used elsewhere in this file set.
      .toList();
}