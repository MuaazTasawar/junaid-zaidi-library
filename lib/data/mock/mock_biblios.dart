import '../models/biblio.dart';

/// 12 mock biblios spanning all 6 browsable subjects, with
/// realistic-looking titles/authors/ISBNs/call-numbers for a
/// CS/Engineering-heavy university library (COMSATS context).
///
/// `biblio_id` values here are referenced by `mock_items.dart` and
/// `mock_holds.dart` — keep these IDs stable if you extend this list.
class MockBiblios {
  const MockBiblios._();

  static final List<Biblio> all = [
    const Biblio(
      biblioId: 1,
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      edition: '3rd Edition',
      isbn: '9780262033848',
      subject: 'Computer Science',
      copyrightdate: 2009,
      description:
      'A comprehensive guide to modern algorithm design and analysis, '
          'covering sorting, graph algorithms, dynamic programming, and NP-completeness.',
    ),
    const Biblio(
      biblioId: 2,
      title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
      author: 'Robert C. Martin',
      edition: '1st Edition',
      isbn: '9780132350884',
      subject: 'Computer Science',
      copyrightdate: 2008,
      description:
      'Practical guidance on writing readable, maintainable software, '
          'with principles, patterns, and practices for professional developers.',
    ),
    const Biblio(
      biblioId: 3,
      title: 'Calculus: Early Transcendentals',
      author: 'James Stewart',
      edition: '8th Edition',
      isbn: '9781285741550',
      subject: 'Mathematics',
      copyrightdate: 2015,
      description:
      'Core undergraduate calculus text covering limits, derivatives, '
          'integrals, and series with applied engineering examples.',
    ),
    const Biblio(
      biblioId: 4,
      title: 'Linear Algebra and Its Applications',
      author: 'David C. Lay',
      edition: '5th Edition',
      isbn: '9780321982384',
      subject: 'Mathematics',
      copyrightdate: 2015,
      description:
      'Introduces vector spaces, eigenvalues, and matrix theory with '
          'applications to computer graphics and data science.',
    ),
    const Biblio(
      biblioId: 5,
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      edition: 'Classic Reprint',
      isbn: '9780141439518',
      subject: 'Literature',
      copyrightdate: 1813,
      description:
      'A classic novel of manners exploring love, class, and reputation '
          'in early 19th-century England.',
    ),
    const Biblio(
      biblioId: 6,
      title: 'A Tale of Two Cities',
      author: 'Charles Dickens',
      edition: 'Classic Reprint',
      isbn: '9780141439600',
      subject: 'Literature',
      copyrightdate: 1859,
      description:
      'Set against the backdrop of the French Revolution, a story of '
          'sacrifice and redemption across London and Paris.',
    ),
    const Biblio(
      biblioId: 7,
      title: 'University Physics with Modern Physics',
      author: 'Hugh D. Young, Roger A. Freedman',
      edition: '14th Edition',
      isbn: '9780321973610',
      subject: 'Physics',
      copyrightdate: 2016,
      description:
      'Calculus-based physics covering mechanics, thermodynamics, '
          'electromagnetism, and an introduction to modern physics.',
    ),
    const Biblio(
      biblioId: 8,
      title: 'Concepts of Physics, Part 1',
      author: 'H.C. Verma',
      edition: '2nd Edition',
      isbn: '9788177091878',
      subject: 'Physics',
      copyrightdate: 1999,
      description:
      'A rigorous problem-focused physics text popular for building '
          'strong conceptual foundations in mechanics and waves.',
    ),
    const Biblio(
      biblioId: 9,
      title: 'Digital Design and Computer Architecture',
      author: 'Sarah L. Harris, David Harris',
      edition: '2nd Edition',
      isbn: '9780123944245',
      subject: 'Engineering',
      copyrightdate: 2012,
      description:
      'Bridges digital logic design and computer architecture, building '
          'up from transistors to a working RISC-V processor.',
    ),
    const Biblio(
      biblioId: 10,
      title: 'Fundamentals of Electric Circuits',
      author: 'Charles K. Alexander, Matthew N.O. Sadiku',
      edition: '6th Edition',
      isbn: '9780078028229',
      subject: 'Engineering',
      copyrightdate: 2016,
      description:
      'Covers DC and AC circuit analysis, operational amplifiers, and '
          'introductory circuit design for electrical engineering students.',
    ),
    const Biblio(
      biblioId: 11,
      title: 'Principles of Marketing',
      author: 'Philip Kotler, Gary Armstrong',
      edition: '17th Edition',
      isbn: '9780134492513',
      subject: 'Business',
      copyrightdate: 2017,
      description:
      'Foundational marketing concepts including consumer behavior, '
          'segmentation, branding, and digital marketing strategy.',
    ),
    const Biblio(
      biblioId: 12,
      title: 'The Lean Startup',
      author: 'Eric Ries',
      edition: '1st Edition',
      isbn: '9780307887894',
      subject: 'Business',
      copyrightdate: 2011,
      description:
      'A methodology for developing businesses and products through '
          'validated learning, rapid experimentation, and iterative releases.',
    ),
  ];

  static Biblio byId(int biblioId) =>
      all.firstWhere((b) => b.biblioId == biblioId);
}