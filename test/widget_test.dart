import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_mobile_app/app.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownApp());

    expect(find.text('Countdown'), findsOneWidget);
  });
}
