import '../models/item.dart';

/// 15 mock items (physical copies) mapped to the 12 biblios in
/// `mock_biblios.dart`. Branch is COMSATS Main Library throughout.
///
/// Coverage:
///   - 9 items currently on loan (feeds `mock_checkouts.dart`)
///   - 4 items available now
///   - 1 item marked not-for-loan (reference-only)
///   - 1 item marked lost (status badge demo in staff item search)
class MockItems {
  const MockItems._();

  static const String _branch = 'CMN';

  static final List<Item> all = [
    // Biblio 1 — Introduction to Algorithms
    const Item(
      itemId: 101,
      itemnumber: 1001,
      biblioId: 1,
      holdingbranch: _branch,
      location: 'Floor 2 · Section C · Shelf 4',
      itemcallnumber: 'QA76.6 .C662 2009',
      notforloan: 0,
      onloan: null, // set on loan via checkout below (kept null here; status resolved from Checkout)
    ),
    const Item(
      itemId: 102,
      itemnumber: 1002,
      biblioId: 1,
      holdingbranch: _branch,
      location: 'Floor 2 · Section C · Shelf 4',
      itemcallnumber: 'QA76.6 .C662 2009',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 2 — Clean Code
    const Item(
      itemId: 103,
      itemnumber: 1003,
      biblioId: 2,
      holdingbranch: _branch,
      location: 'Floor 2 · Section C · Shelf 5',
      itemcallnumber: 'QA76.76.D47 M395 2008',
      notforloan: 0,
      onloan: null,
    ),
    const Item(
      itemId: 115,
      itemnumber: 1015,
      biblioId: 2,
      holdingbranch: _branch,
      location: 'Floor 2 · Section C · Shelf 5',
      itemcallnumber: 'QA76.76.D47 M395 2008',
      notforloan: 4, // lost
      onloan: null,
    ),

    // Biblio 3 — Calculus: Early Transcendentals
    const Item(
      itemId: 104,
      itemnumber: 1004,
      biblioId: 3,
      holdingbranch: _branch,
      location: 'Floor 1 · Section A · Shelf 2',
      itemcallnumber: 'QA303.2 .S74 2015',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 4 — Linear Algebra and Its Applications
    const Item(
      itemId: 105,
      itemnumber: 1005,
      biblioId: 4,
      holdingbranch: _branch,
      location: 'Floor 1 · Section A · Shelf 3',
      itemcallnumber: 'QA184.2 .L39 2015',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 5 — Pride and Prejudice
    const Item(
      itemId: 106,
      itemnumber: 1006,
      biblioId: 5,
      holdingbranch: _branch,
      location: 'Floor 3 · Section L · Shelf 1',
      itemcallnumber: 'PR4034 .P7 2002',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 6 — A Tale of Two Cities
    const Item(
      itemId: 107,
      itemnumber: 1007,
      biblioId: 6,
      holdingbranch: _branch,
      location: 'Floor 3 · Section L · Shelf 1',
      itemcallnumber: 'PR4571 .A1 2003',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 7 — University Physics
    const Item(
      itemId: 108,
      itemnumber: 1008,
      biblioId: 7,
      holdingbranch: _branch,
      location: 'Floor 2 · Section P · Shelf 2',
      itemcallnumber: 'QC21.3 .Y68 2016',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 8 — Concepts of Physics
    const Item(
      itemId: 109,
      itemnumber: 1009,
      biblioId: 8,
      holdingbranch: _branch,
      location: 'Floor 2 · Section P · Shelf 2',
      itemcallnumber: 'QC23 .V47 1999',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 9 — Digital Design and Computer Architecture
    const Item(
      itemId: 110,
      itemnumber: 1010,
      biblioId: 9,
      holdingbranch: _branch,
      location: 'Floor 2 · Section E · Shelf 1',
      itemcallnumber: 'TK7888.4 .H377 2012',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 10 — Fundamentals of Electric Circuits
    const Item(
      itemId: 111,
      itemnumber: 1011,
      biblioId: 10,
      holdingbranch: _branch,
      location: 'Floor 2 · Section E · Shelf 2',
      itemcallnumber: 'TK454 .A44 2016',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 11 — Principles of Marketing
    const Item(
      itemId: 112,
      itemnumber: 1012,
      biblioId: 11,
      holdingbranch: _branch,
      location: 'Floor 1 · Section B · Shelf 6',
      itemcallnumber: 'HF5415 .K625 2017',
      notforloan: 0,
      onloan: null,
    ),

    // Biblio 12 — The Lean Startup
    const Item(
      itemId: 113,
      itemnumber: 1013,
      biblioId: 12,
      holdingbranch: _branch,
      location: 'Floor 1 · Section B · Shelf 7',
      itemcallnumber: 'HD62.5 .R545 2011',
      notforloan: 0,
      onloan: null,
    ),
    const Item(
      itemId: 114,
      itemnumber: 1014,
      biblioId: 12,
      holdingbranch: _branch,
      location: 'Floor 1 · Reference Desk',
      itemcallnumber: 'HD62.5 .R545 2011 REF',
      notforloan: 1, // reference-only, not for loan
      onloan: null,
    ),
  ];

  static Item byId(int itemId) => all.firstWhere((i) => i.itemId == itemId);

  static List<Item> byBiblioId(int biblioId) =>
      all.where((i) => i.biblioId == biblioId).toList();
}