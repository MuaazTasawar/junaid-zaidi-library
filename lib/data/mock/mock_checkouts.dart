import '../models/checkout.dart';

/// 9 mock checkouts — 3 per patron (patrons 1–3 from
/// `mock_patrons.dart`), each patron getting exactly one overdue, one
/// due-soon, and one safe checkout, per the mock-data spec.
///
/// Dates are computed relative to `DateTime.now()` at app-run time so
/// the overdue/due-soon/safe classification always demos correctly
/// regardless of when the app is opened.
class MockCheckouts {
  const MockCheckouts._();

  static final DateTime _now = DateTime.now();

  static final List<Checkout> all = [
    // ── Patron 1 — Ali Hassan ──────────────────────────────
    Checkout(
      checkoutId: 1,
      patronId: 1,
      itemId: 101, // Introduction to Algorithms
      issuedate: _now.subtract(const Duration(days: 35)),
      dueDate: _now.subtract(const Duration(days: 5)), // overdue
      renewalsCount: 0,
    ),
    Checkout(
      checkoutId: 2,
      patronId: 1,
      itemId: 103, // Clean Code
      issuedate: _now.subtract(const Duration(days: 12)),
      dueDate: _now.add(const Duration(days: 2)), // due soon
      renewalsCount: 1,
    ),
    Checkout(
      checkoutId: 3,
      patronId: 1,
      itemId: 104, // Calculus: Early Transcendentals
      issuedate: _now.subtract(const Duration(days: 4)),
      dueDate: _now.add(const Duration(days: 10)), // safe
      renewalsCount: 0,
    ),

    // ── Patron 2 — Sara Ahmed ──────────────────────────────
    Checkout(
      checkoutId: 4,
      patronId: 2,
      itemId: 106, // Pride and Prejudice
      issuedate: _now.subtract(const Duration(days: 17)),
      dueDate: _now.subtract(const Duration(days: 3)), // overdue
      renewalsCount: 0,
    ),
    Checkout(
      checkoutId: 5,
      patronId: 2,
      itemId: 107, // A Tale of Two Cities
      issuedate: _now.subtract(const Duration(days: 13)),
      dueDate: _now.add(const Duration(days: 1)), // due soon
      renewalsCount: 0,
    ),
    Checkout(
      checkoutId: 6,
      patronId: 2,
      itemId: 108, // University Physics
      issuedate: _now.subtract(const Duration(days: 2)),
      dueDate: _now.add(const Duration(days: 14)), // safe
      renewalsCount: 0,
    ),

    // ── Patron 3 — Usman Khan ──────────────────────────────
    Checkout(
      checkoutId: 7,
      patronId: 3,
      itemId: 110, // Digital Design and Computer Architecture
      issuedate: _now.subtract(const Duration(days: 21)),
      dueDate: _now.subtract(const Duration(days: 7)), // overdue
      renewalsCount: 2,
    ),
    Checkout(
      checkoutId: 8,
      patronId: 3,
      itemId: 111, // Fundamentals of Electric Circuits
      issuedate: _now.subtract(const Duration(days: 11)),
      dueDate: _now.add(const Duration(days: 3)), // due soon
      renewalsCount: 0,
    ),
    Checkout(
      checkoutId: 9,
      patronId: 3,
      itemId: 112, // Principles of Marketing
      issuedate: _now.subtract(const Duration(days: 1)),
      dueDate: _now.add(const Duration(days: 20)), // safe
      renewalsCount: 0,
    ),
  ];

  static List<Checkout> byPatronId(int patronId) =>
      all.where((c) => c.patronId == patronId).toList();
}