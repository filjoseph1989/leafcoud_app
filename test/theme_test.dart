import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/theme.dart';

void main() {
  testWidgets('MaterialApp applies LeafCloudTheme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LeafCloudTheme.lightTheme,
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              color: theme.colorScheme.primary,
            );
          },
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(Container)));
    expect(theme.colorScheme.primary, LeafCloudTheme.primaryColor);
    expect(theme.scaffoldBackgroundColor, LeafCloudTheme.backgroundColor);
    expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    final shape = theme.cardTheme.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(20));
  });
}
