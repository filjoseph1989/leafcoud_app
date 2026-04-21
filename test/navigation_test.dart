import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/dashboard_screen.dart';
import 'package:flutter_leafcloud_app/trash_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/trash_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

import 'navigation_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    when(mockApiService.baseUrl).thenReturn('http://test.com');
    when(mockApiService.fetchSensorData()).thenAnswer((_) async => SensorData(status: 'ok', timestamp: DateTime.now()));
    when(mockApiService.getTrashItems(skip: 0, limit: 20)).thenAnswer((_) async => []);
  });

  testWidgets('Navigation to TrashScreen from Dashboard drawer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SensorDataNotifier(apiService: mockApiService),
          ),
          ChangeNotifierProvider(
            create: (_) => TrashNotifier(apiService: mockApiService),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Open drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    // Find and tap Trash item
    final trashItem = find.text('Trash');
    expect(trashItem, findsOneWidget);
    await tester.tap(trashItem);
    await tester.pumpAndSettle();

    // Verify TrashScreen is shown
    expect(find.byType(TrashScreen), findsOneWidget);
  });
}
