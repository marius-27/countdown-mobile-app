import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/app.dart';

void main() {
  testWidgets('App starts on the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownApp());

    expect(find.text('Countdowns'), findsOneWidget);
  });

  testWidgets('Add button opens the create event screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CountdownApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Countdown'), findsOneWidget);
  });

  testWidgets('Archive button opens the archive screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CountdownApp());

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Past Events'), findsOneWidget);
  });
}
