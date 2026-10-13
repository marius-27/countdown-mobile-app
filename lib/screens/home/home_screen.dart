import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../models/countdown_event.dart';
import '../../repositories/event_repository.dart';
import '../../widgets/countdown_event_card.dart';
import '../../widgets/empty_countdown_state.dart';

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
      _events = events.where((e) => !e.isCompleted(now: now)).toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
      _isLoading = false;
    });
  }

  Future<void> _openCreateEvent() async {
    await Navigator.pushNamed(context, AppRoutes.createEvent);
    await _loadEvents();
  }

  Future<void> _openCountdown(CountdownEvent event) async {
    await Navigator.pushNamed(context, AppRoutes.countdown, arguments: event);
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
      return const EmptyCountdownState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: _events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = _events[index];
        return CountdownEventCard(
          event: event,
          onTap: () => _openCountdown(event),
        );
      },
    );
  }
}
