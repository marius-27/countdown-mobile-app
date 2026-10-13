abstract final class DateFormatters {
  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _longMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Formats [date] as `25 Dec 2026`.
  static String shortDate(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';

  /// Formats [date] as `25 December 2026`.
  static String longDate(DateTime date) =>
      '${date.day} ${_longMonths[date.month - 1]} ${date.year}';
}
