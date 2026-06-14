// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:aminsim_app/main.dart';

void main() {
  testWidgets('App renders main page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our main navigation bar items exist.
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Al-Quran'), findsNWidgets(2));
  });
}
