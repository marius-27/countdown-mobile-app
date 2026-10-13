import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  Future<void> initialize() async {
    if (_initialized) return;

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
