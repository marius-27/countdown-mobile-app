import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../models/countdown_event.dart';
import '../../repositories/event_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final EventRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CountdownEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final now = DateTime.now();
    final events = await widget.repository.getEvents();
    if (!mounted) return;

    setState(() {
      _events = events.where((e) => e.targetDate.isAfter(now)).toList();
      _isLoading = false;
    });
  }

  Future<void> _openCreateEvent() async {
    await Navigator.pushNamed(context, AppRoutes.createEvent);
    await _loadEvents();
  }

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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New countdown',
        onPressed: _openCreateEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_events.isEmpty) {
      return const Center(child: Text('No countdowns yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return ListTile(title: Text(event.title));
      },
    );
  }
}
