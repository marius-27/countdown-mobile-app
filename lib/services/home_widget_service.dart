import 'package:home_widget/home_widget.dart';

import '../models/countdown_event.dart';

/// Shares the nearest upcoming countdown with the Android home screen widget.
///
/// Values are stored as strings because target dates and ARGB colors don't
/// fit in the 32-bit ints the native side would otherwise read.
class HomeWidgetService {
  const HomeWidgetService._();

  static const String _androidProvider =
      'com.example.countdown_mobile_app.CountdownWidgetProvider';

  static const String titleKey = 'nearest_event_title';
  static const String emojiKey = 'nearest_event_emoji';
  static const String targetDateKey = 'nearest_event_target_millis';
  static const String colorKey = 'nearest_event_color';

  /// The upcoming event with the closest target date, or null if every event
  /// is already completed.
  static CountdownEvent? nearestEvent(
    List<CountdownEvent> events, {
    DateTime? now,
  }) {
    final upcoming = events.where((e) => !e.isCompleted(now: now)).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Saves the nearest upcoming event for the widget and redraws it.
  static Future<void> update(List<CountdownEvent> events) async {
    final event = nearestEvent(events);

    try {
      // Saving null removes the key, so the widget falls back to its empty
      // state when there is no upcoming event.
      await Future.wait([
        HomeWidget.saveWidgetData<String>(titleKey, event?.title),
        HomeWidget.saveWidgetData<String>(emojiKey, event?.emoji),
        HomeWidget.saveWidgetData<String>(
          targetDateKey,
          event?.targetDate.millisecondsSinceEpoch.toString(),
        ),
        HomeWidget.saveWidgetData<String>(
          colorKey,
          event?.colorValue?.toString(),
        ),
      ]);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider);
    } on Exception {
      // Platforms without a home widget (desktop, web, iOS for now) have no
      // plugin implementation; the app works the same without it.
    }
  }
}
