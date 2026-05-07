import 'package:flutter_test/flutter_test.dart';
import 'package:bus_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BusApp());
    expect(find.byType(BusApp), findsOneWidget);
  });
}
