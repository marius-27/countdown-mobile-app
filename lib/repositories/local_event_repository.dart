import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/countdown_event.dart';
import 'event_repository.dart';

class LocalEventRepository implements EventRepository {
  LocalEventRepository(this._preferences);

  static const String _eventsKey = 'countdown_events';

  final SharedPreferences _preferences;

  @override
  Future<List<CountdownEvent>> getEvents() async {
    final stored = _preferences.getString(_eventsKey);
    if (stored == null) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;
    return decoded
        .map((json) => CountdownEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveEvent(CountdownEvent event) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await _writeEvents(events);
  }

  @override
  Future<void> deleteEvent(String id) async {
    final events = await getEvents();
    events.removeWhere((e) => e.id == id);
    await _writeEvents(events);
  }

  Future<void> _writeEvents(List<CountdownEvent> events) async {
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await _preferences.setString(_eventsKey, encoded);
  }
}
