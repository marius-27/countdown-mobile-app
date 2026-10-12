import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countdown_mobile_app/app.dart';
import 'package:countdown_mobile_app/repositories/local_event_repository.dart';

void main() {
  late LocalEventRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalEventRepository(await SharedPreferences.getInstance());
  });

  testWidgets('App starts on the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(CountdownApp(repository: repository));

    expect(find.text('Countdowns'), findsOneWidget);
  });

  testWidgets('Add button opens the create event screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CountdownApp(repository: repository));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Countdown'), findsOneWidget);
  });

  testWidgets('Archive button opens the archive screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CountdownApp(repository: repository));

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Past Events'), findsOneWidget);
  });
}
