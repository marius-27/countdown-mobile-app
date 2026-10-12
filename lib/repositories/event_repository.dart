import '../models/countdown_event.dart';

abstract interface class EventRepository {
  Future<List<CountdownEvent>> getEvents();

  /// Adds [event], or replaces the stored event with the same id.
  Future<void> saveEvent(CountdownEvent event);

  Future<void> deleteEvent(String id);
}
