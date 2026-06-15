import 'package:flutter_test/flutter_test.dart';
import 'package:aminsim_app/main.dart';

void main() {
  testWidgets('App renders main page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the splash screen animation and navigation to complete (3.8s delay + 0.8s transition)
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that our main navigation bar items exist.
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Al-Quran'), findsNWidgets(2)); // One in grid, one in bottom navigation
    expect(find.text('History'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
