import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/models/countdown_event.dart';

void main() {
  final fullEvent = CountdownEvent(
    id: '1',
    title: 'Japan Trip',
    targetDate: DateTime(2027, 2, 25, 8, 30),
    createdAt: DateTime(2026, 10, 12, 10),
    emoji: '✈️',
    colorValue: 0xFF2196F3,
    backgroundImagePath: '/images/japan.png',
    notificationEnabled: true,
    notificationDaysBefore: 3,
  );

  group('CountdownEvent', () {
    test('has notifications disabled by default', () {
      final event = CountdownEvent(
        id: '1',
        title: 'Birthday',
        targetDate: DateTime(2026, 12, 25),
        createdAt: DateTime(2026, 10, 12),
      );

      expect(event.notificationEnabled, isFalse);
      expect(event.notificationDaysBefore, isNull);
      expect(event.emoji, isNull);
    });

    test('keeps all fields after a JSON round trip', () {
      final restored = CountdownEvent.fromJson(fullEvent.toJson());

      expect(restored.id, fullEvent.id);
      expect(restored.title, fullEvent.title);
      expect(restored.targetDate, fullEvent.targetDate);
      expect(restored.createdAt, fullEvent.createdAt);
      expect(restored.emoji, fullEvent.emoji);
      expect(restored.colorValue, fullEvent.colorValue);
      expect(restored.backgroundImagePath, fullEvent.backgroundImagePath);
      expect(restored.notificationEnabled, isTrue);
      expect(restored.notificationDaysBefore, 3);
    });

    test('reads JSON without optional fields', () {
      final event = CountdownEvent.fromJson({
        'id': '2',
        'title': 'Graduation',
        'targetDate': '2027-06-20T00:00:00.000',
        'createdAt': '2026-10-12T00:00:00.000',
      });

      expect(event.title, 'Graduation');
      expect(event.targetDate, DateTime(2027, 6, 20));
      expect(event.notificationEnabled, isFalse);
      expect(event.colorValue, isNull);
    });

    test('copyWith changes only the given fields', () {
      final updated = fullEvent.copyWith(title: 'Tokyo Trip');

      expect(updated.title, 'Tokyo Trip');
      expect(updated.id, fullEvent.id);
      expect(updated.targetDate, fullEvent.targetDate);
      expect(updated.createdAt, fullEvent.createdAt);
      expect(updated.emoji, fullEvent.emoji);
    });

    group('isCompleted', () {
      final now = DateTime(2026, 10, 13, 12);

      CountdownEvent eventAt(DateTime targetDate) => CountdownEvent(
        id: '3',
        title: 'Exam',
        targetDate: targetDate,
        createdAt: DateTime(2026, 10, 1),
      );

      test('is false when the target date is tomorrow', () {
        final event = eventAt(now.add(const Duration(days: 1)));

        expect(event.isCompleted(now: now), isFalse);
      });

      test('is true when the target date is now', () {
        expect(eventAt(now).isCompleted(now: now), isTrue);
      });

      test('is true when the target date was yesterday', () {
        final event = eventAt(now.subtract(const Duration(days: 1)));

        expect(event.isCompleted(now: now), isTrue);
      });
    });
  });
}
