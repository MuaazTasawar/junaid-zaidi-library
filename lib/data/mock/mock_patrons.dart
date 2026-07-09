import '../models/patron.dart';

/// 4 mock patrons: 3 regular COMSATS students + 1 library staff
/// member, used to demo both the patron and staff app experiences.
class MockPatrons {
  const MockPatrons._();

  static const String _branch = 'CMN';

  static final List<Patron> all = [
    const Patron(
      patronId: 1,
      borrowernumber: 20001,
      cardnumber: 'FA23-BCS-050',
      firstname: 'Ali',
      surname: 'Hassan',
      email: 'ali.hassan@comsats.edu.pk',
      categorycode: 'PT',
      branchcode: _branch,
    ),
    const Patron(
      patronId: 2,
      borrowernumber: 20002,
      cardnumber: 'FA22-BSE-114',
      firstname: 'Sara',
      surname: 'Ahmed',
      email: 'sara.ahmed@comsats.edu.pk',
      categorycode: 'PT',
      branchcode: _branch,
    ),
    const Patron(
      patronId: 3,
      borrowernumber: 20003,
      cardnumber: 'FA23-BEE-077',
      firstname: 'Usman',
      surname: 'Khan',
      email: 'usman.khan@comsats.edu.pk',
      categorycode: 'PT',
      branchcode: _branch,
    ),
    const Patron(
      patronId: 4,
      borrowernumber: 20004,
      cardnumber: 'STAFF-0001',
      firstname: 'Ayesha',
      surname: 'Raza',
      email: 'ayesha.raza@comsats.edu.pk',
      categorycode: 'STAFF',
      branchcode: _branch,
    ),
  ];

  static Patron byId(int patronId) =>
      all.firstWhere((p) => p.patronId == patronId);

  static Patron byCardnumber(String cardnumber) =>
      all.firstWhere((p) => p.cardnumber == cardnumber);
}