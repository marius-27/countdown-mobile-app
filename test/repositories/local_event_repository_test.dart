import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countdown_mobile_app/models/countdown_event.dart';
import 'package:countdown_mobile_app/repositories/local_event_repository.dart';

CountdownEvent _event(
  String id, {
  String title = 'Birthday',
  DateTime? targetDate,
}) {
  return CountdownEvent(
    id: id,
    title: title,
    targetDate: targetDate ?? DateTime(2026, 12, 25, 12),
    createdAt: DateTime(2026, 10, 12),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<LocalEventRepository> createRepository() async {
    return LocalEventRepository(await SharedPreferences.getInstance());
  }

  test('starts with no events', () async {
    final repository = await createRepository();

    expect(await repository.getEvents(), isEmpty);
  });

  test('saves a new event', () async {
    final repository = await createRepository();

    await repository.saveEvent(_event('1'));

    final events = await repository.getEvents();
    expect(events, hasLength(1));
    expect(events.single.title, 'Birthday');
  });

  test('replaces an event with the same id', () async {
    final repository = await createRepository();

    await repository.saveEvent(_event('1'));
    await repository.saveEvent(_event('1', title: 'Wedding'));

    final events = await repository.getEvents();
    expect(events, hasLength(1));
    expect(events.single.title, 'Wedding');
  });

  test('deletes an event', () async {
    final repository = await createRepository();

    await repository.saveEvent(_event('1'));
    await repository.saveEvent(_event('2'));
    await repository.deleteEvent('1');

    final events = await repository.getEvents();
    expect(events.map((e) => e.id), ['2']);
  });

  test('events remain saved after the app restarts', () async {
    final repository = await createRepository();
    await repository.saveEvent(_event('1'));

    // A new repository reads the same storage, like after a restart.
    final restarted = await createRepository();

    final events = await restarted.getEvents();
    expect(events.single.id, '1');
    expect(events.single.targetDate, DateTime(2026, 12, 25, 12));
  });

  test('returns only completed events as archived, newest first', () async {
    final repository = await createRepository();
    final now = DateTime(2026, 10, 13, 12);

    await repository.saveEvent(
      _event('exam', targetDate: DateTime(2025, 10, 1)),
    );
    await repository.saveEvent(
      _event('new-year', targetDate: DateTime(2026, 1, 1)),
    );
    await repository.saveEvent(
      _event('birthday', targetDate: DateTime(2026, 12, 25)),
    );

    final archived = await repository.getArchivedEvents(now: now);
    expect(archived.map((e) => e.id), ['new-year', 'exam']);
  });
}
