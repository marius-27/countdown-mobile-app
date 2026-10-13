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
}
