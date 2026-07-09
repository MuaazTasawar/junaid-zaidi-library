/// Centralized date formatting + due-status resolution, shared by
/// `DueDateStamp`, checkout/hold/history screens, and the library
/// card "Member since" line. Consolidates the local logic that
/// `DueDateStamp` carried in Phase 2 (per the note left there).
enum DueStatus { overdue, dueSoon, safe }

class DateFormatter {
  const DateFormatter._();

  static const List<String> _monthsShort = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  static const List<String> _monthsLong = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// "JUL 14" — used inside DueDateStamp.
  static String monoDate(DateTime date) {
    return '${_monthsShort[date.month - 1]} ${date.day}';
  }

  /// "Jul 14, 2026" — used in history lists, fine dates, etc.
  static String shortDate(DateTime date) {
    return '${_monthsShort[date.month - 1][0]}${_monthsShort[date.month - 1].substring(1).toLowerCase()} ${date.day}, ${date.year}';
  }

  /// "Sep 2023" — used on the library card "Member since" line.
  static String monthYear(DateTime date) {
    final String m = _monthsLong[date.month - 1];
    return '${m.substring(0, 3)} ${date.year}';
  }

  static DueStatus resolveDueStatus(DateTime dueDate) {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (due.isBefore(todayDate)) return DueStatus.overdue;
    if (!due.isAfter(todayDate.add(const Duration(days: 3)))) {
      return DueStatus.dueSoon;
    }
    return DueStatus.safe;
  }

  /// "5 days overdue" / "due in 2 days" / "due today" — used on
  /// notification cards and checkout list subtitles.
  static String relativeDueLabel(DateTime dueDate) {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final int diff = due.difference(todayDate).inDays;

    if (diff < 0) {
      final int overdueDays = -diff;
      return '$overdueDays ${overdueDays == 1 ? 'day' : 'days'} overdue';
    }
    if (diff == 0) return 'Due today';
    return 'Due in $diff ${diff == 1 ? 'day' : 'days'}';
  }
}