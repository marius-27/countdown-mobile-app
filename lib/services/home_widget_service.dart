import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../models/countdown_event.dart';

/// Shares the upcoming countdowns with the Android home screen widget.
///
/// The widget shows the first event whose target date is still ahead, so when
/// the nearest event completes while the app is closed it moves on to the
/// next one by itself.
class HomeWidgetService {
  const HomeWidgetService._();

  static const String _androidProvider =
      'com.example.countdown_mobile_app.CountdownWidgetProvider';

  /// Key of the JSON list read by CountdownWidgetProvider.kt.
  static const String upcomingEventsKey = 'upcoming_events';

  /// More than enough for the widget to keep moving on between app launches,
  /// while keeping the shared data small.
  static const int maxEvents = 20;

  /// Upcoming events, nearest first, limited to [maxEvents].
  static List<CountdownEvent> upcomingEvents(
    List<CountdownEvent> events, {
    DateTime? now,
  }) {
    final upcoming = events.where((e) => !e.isCompleted(now: now)).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return upcoming.take(maxEvents).toList();
  }

  /// Saves the upcoming events for the widget and redraws it.
  static Future<void> update(List<CountdownEvent> events) async {
    final data = jsonEncode([
      for (final event in upcomingEvents(events))
        {
          'title': event.title,
          'emoji': event.emoji,
          'targetMillis': event.targetDate.millisecondsSinceEpoch,
          'color': event.colorValue,
        },
    ]);

    try {
      await HomeWidget.saveWidgetData<String>(upcomingEventsKey, data);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider);
    } on Exception {
      // Platforms without a home widget (desktop, web, iOS for now) have no
      // plugin implementation; the app works the same without it.
    }
  }
}
