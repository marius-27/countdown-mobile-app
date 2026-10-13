import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/core/utils/countdown_calculator.dart';

void main() {
  final now = DateTime(2026, 10, 12, 20, 17, 41);

  group('CountdownCalculator.remainingDays', () {
    int days(DateTime targetDate) =>
        CountdownCalculator.remainingDays(targetDate, now: now);

    test('counts calendar days until the target date', () {
      expect(days(DateTime(2026, 10, 13, 8)), 1);
      expect(days(DateTime(2026, 12, 25)), 74);
    });

    test('ignores the time of day', () {
      // Less than 24 hours away, but on the next calendar day.
      expect(days(DateTime(2026, 10, 13, 0, 5)), 1);
      // Later today, even though hours remain.
      expect(days(DateTime(2026, 10, 12, 23, 59)), 0);
    });

    test('is not shifted by a daylight saving change', () {
      // Most of Europe moves the clocks back on 25 October 2026.
      expect(days(DateTime(2026, 10, 26)), 14);
      expect(days(DateTime(2027, 3, 29)), 168);
    });

    test('counts across a leap day', () {
      final start = DateTime(2028, 2, 28);

      expect(
        CountdownCalculator.remainingDays(DateTime(2028, 3, 1), now: start),
        2,
      );
    });

    test('is negative when the target date has passed', () {
      expect(days(DateTime(2026, 10, 11)), -1);
    });
  });

  group('CountdownCalculator.remainingDaysLabel', () {
    String label(DateTime targetDate) =>
        CountdownCalculator.remainingDaysLabel(targetDate, now: now);

    test('says today for an event later today', () {
      expect(label(DateTime(2026, 10, 12, 22)), 'Today');
    });

    test('uses the singular for one day', () {
      expect(label(DateTime(2026, 10, 13)), '1 day remaining');
    });

    test('uses the plural for several days', () {
      expect(label(DateTime(2026, 12, 25)), '74 days remaining');
    });
  });

  group('CountdownCalculator.remainingDuration', () {
    test('is positive when the target date is tomorrow', () {
      final tomorrow = now.add(const Duration(days: 1));

      expect(
        CountdownCalculator.remainingDuration(tomorrow, now: now),
        greaterThan(Duration.zero),
      );
    });

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
