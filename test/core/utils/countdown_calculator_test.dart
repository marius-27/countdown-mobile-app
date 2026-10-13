import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/core/utils/countdown_calculator.dart';

void main() {
  final now = DateTime(2026, 10, 12, 20, 17, 41);

  group('CountdownCalculator.remainingDuration', () {
    test('returns the exact time left until the target date', () {
      final target = DateTime(2026, 12, 25);

      expect(
        CountdownCalculator.remainingDuration(target, now: now),
        target.difference(now),
      );
    });

    test('returns zero when the target date is now', () {
      expect(
        CountdownCalculator.remainingDuration(now, now: now),
        Duration.zero,
      );
    });

    test('returns zero when the target date has passed', () {
      final yesterday = now.subtract(const Duration(days: 1));

      expect(
        CountdownCalculator.remainingDuration(yesterday, now: now),
        Duration.zero,
      );
    });
  });

  group('CountdownCalculator.timeAgoLabel', () {
    String label(DateTime targetDate) =>
        CountdownCalculator.timeAgoLabel(targetDate, now: now);

    test('says today for an event earlier today', () {
      expect(label(DateTime(2026, 10, 12, 9)), 'Today');
    });

    test('counts days within the first month', () {
      expect(label(DateTime(2026, 10, 11)), '1 day ago');
      expect(label(DateTime(2026, 9, 20)), '22 days ago');
    });

    test('counts whole months within the first year', () {
      expect(label(DateTime(2026, 9, 12)), '1 month ago');
      expect(label(DateTime(2026, 1, 1)), '9 months ago');
    });

    test('does not round up a month that is not complete yet', () {
      expect(label(DateTime(2026, 9, 13)), '29 days ago');
    });

    test('counts whole years', () {
      expect(label(DateTime(2025, 10, 1)), '1 year ago');
      expect(label(DateTime(2023, 6, 1)), '3 years ago');
    });
  });
}
