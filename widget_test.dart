import 'package:flutter_test/flutter_test.dart';
import 'package:feed/main.dart'; // your app's main file

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    // Build the actual app
    await tester.pumpWidget(const SmartPoultryApp());

    // You can add more checks here if you want,
    // e.g., expect(find.text('Connexion'), findsOneWidget);
  });
}