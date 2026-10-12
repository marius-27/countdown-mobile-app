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

  /// Formats [date] as `25 Dec 2026`.
  static String shortDate(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
}
