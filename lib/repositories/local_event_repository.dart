import '../models/countdown_event.dart';
import 'event_repository.dart';

class LocalEventRepository implements EventRepository {
  final List<CountdownEvent> _events = [];

  @override
  Future<List<CountdownEvent>> getEvents() async {
    return List.unmodifiable(_events);
  }

  @override
  Future<void> saveEvent(CountdownEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }
}
