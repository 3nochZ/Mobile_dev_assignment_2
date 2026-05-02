import 'package:flutter_test/flutter_test.dart';
import 'package:country_explorer/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CountryExplorerApp());

    // Verify that the app bar title is present.
    expect(find.text('Country Explorer'), findsOneWidget);
  });
}
