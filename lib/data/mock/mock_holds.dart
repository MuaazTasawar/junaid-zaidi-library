import '../models/hold.dart';

/// 3 mock holds: 1 ready for pickup, 2 in queue (with distinct
/// priorities so the "#N in queue" badge has real numbers to show).
class MockHolds {
  const MockHolds._();

  static final DateTime _now = DateTime.now();

  static final List<Hold> all = [
    // Ready for pickup — Ali Hassan, held for "Pride and Prejudice"
    Hold(
      holdId: 1,
      patronId: 1,
      biblioId: 5,
      status: 'W', // waiting / ready for pickup
      priority: 0,
      waitingdate: _now.subtract(const Duration(days: 1)),
      expirationdate: _now.add(const Duration(days: 2)),
    ),

    // In queue — Sara Ahmed, waiting on "Introduction to Algorithms"
    Hold(
      holdId: 2,
      patronId: 2,
      biblioId: 1,
      status: 'T', // in transit / pending
      priority: 2,
      waitingdate: null,
      expirationdate: _now.add(const Duration(days: 30)),
    ),

    // In queue — Usman Khan, waiting on "Digital Design and Computer Architecture"
    Hold(
      holdId: 3,
      patronId: 3,
      biblioId: 9,
      status: 'T',
      priority: 1,
      waitingdate: null,
      expirationdate: _now.add(const Duration(days: 30)),
    ),
  ];

  static List<Hold> byPatronId(int patronId) =>
      all.where((h) => h.patronId == patronId).toList();
}