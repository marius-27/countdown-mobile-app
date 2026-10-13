import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'models/countdown_event.dart';
import 'repositories/event_repository.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/countdown/countdown_screen.dart';
import 'screens/create_event/create_event_screen.dart';
import 'screens/home/home_screen.dart';

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key, required this.repository});

  final EventRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => HomeScreen(repository: repository),
        AppRoutes.createEvent: (_) => CreateEventScreen(repository: repository),
        AppRoutes.editEvent: (context) => CreateEventScreen(
          repository: repository,
          event: ModalRoute.of(context)!.settings.arguments as CountdownEvent,
        ),
        AppRoutes.countdown: (context) => CountdownScreen(
          event: ModalRoute.of(context)!.settings.arguments as CountdownEvent,
        ),
        AppRoutes.archive: (_) => const ArchiveScreen(),
      },
    );
  }
}
