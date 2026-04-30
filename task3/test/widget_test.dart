import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook_app/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CookBookApp());

    // Verify that the Recipe Detail Screen is shown by checking for a text in the sample data
    expect(find.text('Creamy Mushroom Pasta'), findsOneWidget);
  });
}
