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
    return tester.pumpWidget(
      MaterialApp(home: CreateEventScreen(repository: repository)),
    );
  }

  Future<void> tapCreate(WidgetTester tester) async {
    // The button sits below the customization options, out of view on the
    // default 800x600 test screen. Scrolling to it moves the title and date
    // fields out of view, so this also checks they are still validated.
    final create = find.text('CREATE');
    await tester.ensureVisible(create);
    await tester.pumpAndSettle();
    await tester.tap(create);
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
    // Close the keyboard like a user would; a focused field keeps scrolling
    // itself back into view, which would hide the CREATE button again.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tapCreate(tester);

    expect(find.text('Please enter a title.'), findsNothing);
    expect(find.text('Please select a date.'), findsOneWidget);
    expect(await repository.getEvents(), isEmpty);
  });
}
