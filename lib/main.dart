import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'repositories/local_event_repository.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  await NotificationService.instance.initialize();

  final repository = LocalEventRepository(preferences);
  // Refresh the widget on launch, since an event may have completed while
  // the app was closed.
  await HomeWidgetService.update(await repository.getEvents());

  runApp(CountdownApp(repository: repository));
}
