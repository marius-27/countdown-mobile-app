import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/countdown/countdown_screen.dart';
import 'screens/create_event/create_event_screen.dart';
import 'screens/home/home_screen.dart';

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

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
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.createEvent: (_) => const CreateEventScreen(),
        AppRoutes.countdown: (_) => const CountdownScreen(),
        AppRoutes.archive: (_) => const ArchiveScreen(),
      },
    );
  }
}
