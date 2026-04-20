import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/trash_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/trash_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/trash_item_info.dart';

import 'trash_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    when(mockApiService.baseUrl).thenReturn('http://test.com');
  });

  testWidgets('TrashScreen shows loading and then items', (WidgetTester tester) async {
    final items = [
      TrashItemInfo(
        id: 1,
        filename: 'img1.jpg',
        reason: 'low_greenness',
        metricValue: 10.0,
        timestamp: DateTime.now(),
      ),
    ];

    final completer = Completer<List<TrashItemInfo>>();
    when(mockApiService.getTrashItems(skip: 0, limit: 20))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TrashNotifier(apiService: mockApiService),
        child: const MaterialApp(home: TrashScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(items);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Trash'), findsOneWidget);
    expect(find.text('img1.jpg'), findsOneWidget);
    expect(find.text('Reason: low_greenness'), findsOneWidget);
  });

  testWidgets('TrashScreen shows error Snackbar on failure', (WidgetTester tester) async {
    when(mockApiService.getTrashItems(skip: 0, limit: 20))
        .thenThrow(Exception('Failed to load trash'));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TrashNotifier(apiService: mockApiService),
        child: const MaterialApp(home: TrashScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Exception: Failed to load trash'), findsOneWidget);
  });
}
