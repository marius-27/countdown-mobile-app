import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdowns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Past events',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.archive),
          ),
        ],
      ),
      body: const Center(child: Text('No countdowns yet')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New countdown',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }
}
