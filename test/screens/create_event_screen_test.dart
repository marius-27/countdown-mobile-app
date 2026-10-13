import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countdown_mobile_app/repositories/local_event_repository.dart';
import 'package:countdown_mobile_app/screens/create_event/create_event_screen.dart';

void main() {
  late LocalEventRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalEventRepository(await SharedPreferences.getInstance());
  });

  Future<void> pumpScreen(WidgetTester tester) {
    // A tall screen keeps the whole form built, so every field is validated.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(home: CreateEventScreen(repository: repository)),
    );
  }

  Future<void> tapCreate(WidgetTester tester) async {
    await tester.tap(find.text('CREATE'));
    await tester.pump();
  }

  testWidgets('shows errors when the form is empty', (tester) async {
    await pumpScreen(tester);

    await tapCreate(tester);

    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(find.text('Please select a date.'), findsOneWidget);
  });

  testWidgets('does not save an event that fails validation', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Birthday');
    await tapCreate(tester);

    expect(find.text('Please enter a title.'), findsNothing);
    expect(find.text('Please select a date.'), findsOneWidget);
    expect(await repository.getEvents(), isEmpty);
  });
}
