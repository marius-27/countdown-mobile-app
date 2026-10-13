import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countdown_mobile_app/app.dart';
import 'package:countdown_mobile_app/models/countdown_event.dart';
import 'package:countdown_mobile_app/repositories/local_event_repository.dart';

CountdownEvent _event(String id, String title, DateTime targetDate) {
  return CountdownEvent(
    id: id,
    title: title,
    targetDate: targetDate,
    createdAt: DateTime(2026, 10, 13),
  );
}

void main() {
  late LocalEventRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalEventRepository(await SharedPreferences.getInstance());

    // Deleting an event also cancels its reminder and refreshes the home
    // widget. Tests don't register plugins like the app does, so register the
    // Android notifications plugin and answer both plugins' channel calls.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in const [
      MethodChannel('dexterous.com/flutter/local_notifications'),
      MethodChannel('home_widget'),
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => null);
    }
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(CountdownApp(repository: repository));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state when there are no events', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('No countdowns yet'), findsOneWidget);
  });

  testWidgets('lists upcoming events with the nearest first', (tester) async {
    await repository.saveEvent(
      _event('christmas', 'Christmas', DateTime(2099, 12, 25)),
    );
    await repository.saveEvent(
      _event('new-year', 'New Year', DateTime(2099, 1, 1)),
    );

    await pumpApp(tester);

    final newYear = tester.getTopLeft(find.text('New Year'));
    final christmas = tester.getTopLeft(find.text('Christmas'));
    expect(newYear.dy, lessThan(christmas.dy));
    expect(find.text('No countdowns yet'), findsNothing);
  });

  testWidgets('does not list completed events', (tester) async {
    await repository.saveEvent(_event('exam', 'Exam', DateTime(2000, 6, 1)));
    await repository.saveEvent(
      _event('birthday', 'Birthday', DateTime(2099, 3, 14)),
    );

    await pumpApp(tester);

    expect(find.text('Birthday'), findsOneWidget);
    expect(find.text('Exam'), findsNothing);
  });

  testWidgets('a created event appears in the list', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    // Stands in for filling the form, which needs the platform date picker.
    await repository.saveEvent(
      _event('birthday', 'Birthday', DateTime(2099, 3, 14)),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Birthday'), findsOneWidget);
    expect(find.text('No countdowns yet'), findsNothing);
  });

  testWidgets('a deleted event disappears from the list', (tester) async {
    await repository.saveEvent(
      _event('birthday', 'Birthday', DateTime(2099, 3, 14)),
    );
    await pumpApp(tester);

    await tester.tap(find.text('Birthday'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Birthday'), findsNothing);
    expect(find.text('No countdowns yet'), findsOneWidget);
    expect(await repository.getEvents(), isEmpty);
  });
}
