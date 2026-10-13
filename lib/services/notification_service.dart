import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/countdown_event.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'countdown_reminders';
  static const String _channelName = 'Countdown reminders';
  static const String _channelDescription =
      'Reminders before your countdown events.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Notification details shared by every countdown reminder.
  static const NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Reminders are only scheduled on Android and iOS; the plugin can't
  /// schedule notifications on desktop or web.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Does nothing on unsupported platforms, which also makes the other
  /// methods no-ops there.
  Future<void> initialize() async {
    if (_initialized || !isSupported) return;

    // Scheduled notifications need the device's time zone so reminders fire
    // at the chosen local time.
    tz.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Permission is asked for separately, when the user turns a reminder on.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Schedules the event's reminder, if it has one enabled and its time is
  /// still in the future.
  Future<void> scheduleEventReminder(CountdownEvent event) async {
    if (!_initialized) return;
    final reminderAt = reminderDate(event);
    final now = tz.TZDateTime.now(tz.local);
    if (reminderAt == null || !reminderAt.isAfter(now)) return;

    final emoji = event.emoji;
    await _plugin.zonedSchedule(
      notificationId(event.id),
      emoji == null ? event.title : '$emoji ${event.title}',
      _reminderBody(event.notificationDaysBefore!),
      reminderAt,
      details,
      // Inexact alarms don't need the exact alarm permission and are still
      // delivered within a few minutes of the chosen time.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: event.id,
    );
  }

  /// Removes the event's pending reminder, if any.
  Future<void> cancelEventReminder(String eventId) async {
    if (!_initialized) return;
    await _plugin.cancel(notificationId(eventId));
  }

  /// When the reminder for [event] should fire, or null if it has none.
  static tz.TZDateTime? reminderDate(CountdownEvent event) {
    final daysBefore = event.notificationDaysBefore;
    final minutes = event.notificationTimeMinutes;
    if (!event.notificationEnabled || daysBefore == null || minutes == null) {
      return null;
    }

    final target = event.targetDate;
    return tz.TZDateTime(
      tz.local,
      target.year,
      target.month,
      target.day - daysBefore,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  /// A stable notification id for an event, so its reminder can later be
  /// cancelled or replaced. Event ids are too large for the plugin's 32-bit
  /// ids, and [String.hashCode] isn't guaranteed to stay the same between app
  /// runs, so this uses a 31-bit FNV-1a hash.
  static int notificationId(String eventId) {
    var hash = 0x811c9dc5;
    for (final unit in eventId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  static String _reminderBody(int daysBefore) => daysBefore == 1
      ? 'Happening tomorrow!'
      : 'Happening in $daysBefore days!';

  /// Asks the user to allow notifications. Returns whether they are allowed.
  ///
  /// Only Android 13+ and iOS show a prompt; older Android versions allow
  /// notifications by default. Once the user has answered, the system returns
  /// the saved answer without prompting again.
  Future<bool> requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.requestNotificationsPermission() ?? false;
      case TargetPlatform.iOS:
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      default:
        return false;
    }
  }
}
