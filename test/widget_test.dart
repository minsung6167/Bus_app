import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('앱 스모크 테스트 — BusApp 위젯이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const BusApp());
    expect(find.byType(BusApp), findsOneWidget);
  });

  testWidgets('앱 스모크 테스트 — MaterialApp이 존재한다', (WidgetTester tester) async {
    await tester.pumpWidget(const BusApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
