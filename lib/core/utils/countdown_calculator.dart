abstract final class CountdownCalculator {
  /// Calendar days from [now] until [targetDate], ignoring the time of day.
  ///
  /// Dates are compared in UTC so daylight saving changes don't shift the
  /// result by a day.
  static int remainingDays(DateTime targetDate, {DateTime? now}) {
    final from = now ?? DateTime.now();
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
    return end.difference(start).inDays;
  }

  /// Exact time left from [now] until [targetDate], never negative.
  ///
  /// Always recalculated from the clock instead of decremented, so the result
  /// stays correct after the app has been in the background.
  static Duration remainingDuration(DateTime targetDate, {DateTime? now}) {
    final remaining = targetDate.difference(now ?? DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String remainingDaysLabel(DateTime targetDate, {DateTime? now}) {
    final days = remainingDays(targetDate, now: now);
    if (days <= 0) return 'Today';
    if (days == 1) return '1 day remaining';
    return '$days days remaining';
  }

  /// How long ago [targetDate] passed, e.g. `9 months ago` or `1 year ago`.
  static String timeAgoLabel(DateTime targetDate, {DateTime? now}) {
    final from = now ?? DateTime.now();

    var months =
        (from.year - targetDate.year) * 12 + from.month - targetDate.month;
    if (from.day < targetDate.day) months--;

    if (months >= 12) return _plural(months ~/ 12, 'year');
    if (months >= 1) return _plural(months, 'month');

    final days = -remainingDays(targetDate, now: from);
    if (days <= 0) return 'Today';
    return _plural(days, 'day');
  }

  static String _plural(int count, String unit) =>
      count == 1 ? '1 $unit ago' : '$count ${unit}s ago';
}
