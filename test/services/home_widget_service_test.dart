import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/models/countdown_event.dart';
import 'package:countdown_mobile_app/services/home_widget_service.dart';

CountdownEvent _event(String id, DateTime targetDate) {
  return CountdownEvent(
    id: id,
    title: id,
    targetDate: targetDate,
    createdAt: DateTime(2026, 10, 1),
  );
}

void main() {
  final now = DateTime(2026, 10, 13, 12);

  group('HomeWidgetService.upcomingEvents', () {
    test('returns upcoming events nearest first', () {
      final events = [
        _event('christmas', DateTime(2026, 12, 25)),
        _event('halloween', DateTime(2026, 10, 31)),
      ];

      final upcoming = HomeWidgetService.upcomingEvents(events, now: now);

      expect(upcoming.map((e) => e.id), ['halloween', 'christmas']);
    });

    test('leaves out completed events', () {
      final events = [
        _event('exam', DateTime(2026, 6, 1)),
        _event('christmas', DateTime(2026, 12, 25)),
      ];

      final upcoming = HomeWidgetService.upcomingEvents(events, now: now);

      expect(upcoming.map((e) => e.id), ['christmas']);
    });

    test('keeps at most maxEvents events', () {
      final events = [
        for (var day = 1; day <= HomeWidgetService.maxEvents + 5; day++)
          _event('day-$day', DateTime(2027, 1, day)),
      ];

      final upcoming = HomeWidgetService.upcomingEvents(events, now: now);

      expect(upcoming, hasLength(HomeWidgetService.maxEvents));
      expect(upcoming.first.id, 'day-1');
    });
  });
}
