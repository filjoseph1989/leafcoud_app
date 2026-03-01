import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen shows loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
