import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/core/utils/event_validators.dart';

void main() {
  group('EventValidators.title', () {
    test('rejects a missing title', () {
      expect(EventValidators.title(null), 'Please enter a title.');
      expect(EventValidators.title(''), 'Please enter a title.');
    });

    test('rejects a title with only spaces', () {
      expect(EventValidators.title('   '), 'Please enter a title.');
    });

    test('accepts a title', () {
      expect(EventValidators.title('Birthday'), isNull);
    });
  });

  group('EventValidators.targetDate', () {
    final now = DateTime(2026, 10, 13, 12);

    String? validate(DateTime? value) =>
        EventValidators.targetDate(value, now: now);

    test('rejects a missing date', () {
      expect(validate(null), 'Please select a date.');
    });

    test('rejects a date in the past', () {
      expect(validate(DateTime(2026, 10, 12)), 'Please select a future date.');
    });

    test('rejects the current moment', () {
      expect(validate(now), 'Please select a future date.');
    });

    test('accepts a later time today', () {
      expect(validate(DateTime(2026, 10, 13, 18)), isNull);
    });

    test('accepts a future date', () {
      expect(validate(DateTime(2026, 12, 25)), isNull);
    });
  });
}
