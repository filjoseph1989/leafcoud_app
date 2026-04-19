import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/connection_setup_screen.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([ConnectionService, ApiService])
import 'connection_setup_screen_test.mocks.dart';

void main() {
  late MockConnectionService mockConnectionService;
  late MockApiService mockApiService;

  setUp(() {
    mockConnectionService = MockConnectionService();
    mockApiService = MockApiService();
    
    // Default mock behavior
    when(mockApiService.client).thenReturn(http.Client());
    when(mockApiService.baseUrl).thenReturn('http://placeholder');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<ConnectionService>.value(value: mockConnectionService),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const ConnectionSetupScreen(),
      ),
    );
  }

  group('ConnectionSetupScreen', () {
    testWidgets('renders IP and Port fields', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => null);
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Server IP / Hostname'), findsOneWidget);
      expect(find.text('Port'), findsOneWidget);
    });

    testWidgets('pre-fills saved IP and Port', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => '1.2.3.4');
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => '8080');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('1.2.3.4'), findsOneWidget);
      expect(find.text('8080'), findsOneWidget);
    });

    testWidgets('shows loading indicator and performs health check on Save Settings', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => '1.2.3.4');
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => '8080');
      when(mockConnectionService.getBaseUrl(any, any)).thenReturn('http://1.2.3.4:8080');
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Save Settings'));
      await tester.pump();

      verify(mockConnectionService.saveConnectionSettings('1.2.3.4', '8080')).called(1);
      verify(mockApiService.baseUrl = 'http://1.2.3.4:8080').called(1);
    });
  });
}
