import 'package:flutter/material.dart';

import '../../models/countdown_event.dart';
import '../../repositories/event_repository.dart';
import '../../services/home_widget_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/archived_event_card.dart';
import '../../widgets/delete_confirmation_dialog.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key, required this.repository});

  final EventRepository repository;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<CountdownEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await widget.repository.getArchivedEvents();
    if (!mounted) return;

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _deleteEvent(CountdownEvent event) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: event.title,
    );
    if (!confirmed) return;

    await NotificationService.instance.cancelEventReminder(event.id);
    await widget.repository.deleteEvent(event.id);
    await HomeWidgetService.update(await widget.repository.getEvents());
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Events')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_events.isEmpty) {
      return const _EmptyArchiveState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = _events[index];
        return ArchivedEventCard(
          event: event,
          onDelete: () => _deleteEvent(event),
        );
      },
    );
  }
}

class _EmptyArchiveState extends StatelessWidget {
  const _EmptyArchiveState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No past events', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Finished countdowns will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
