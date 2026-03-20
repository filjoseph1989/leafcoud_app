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

    testWidgets('shows loading indicator and performs health check on Connect', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => '1.2.3.4');
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => '8080');
      when(mockConnectionService.getBaseUrl(any, any)).thenReturn('http://1.2.3.4:8080');
      when(mockConnectionService.checkHealth(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Connect'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      verify(mockConnectionService.checkHealth('1.2.3.4', '8080')).called(1);
      verify(mockConnectionService.saveConnectionSettings('1.2.3.4', '8080')).called(1);
      verify(mockApiService.baseUrl = 'http://1.2.3.4:8080').called(1);
    });

    testWidgets('shows error message on health check failure', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => null);
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => null);
      when(mockConnectionService.checkHealth(any, any)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Server IP / Hostname'), 'invalid');
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(find.text('Could not connect to server. Please check settings.'), findsOneWidget);
    });

    testWidgets('Connects to default on "Use Default" tap', (WidgetTester tester) async {
      when(mockConnectionService.getSavedIp()).thenAnswer((_) async => null);
      when(mockConnectionService.getSavedPort()).thenAnswer((_) async => null);
      when(mockConnectionService.getBaseUrl('', '')).thenReturn('http://192.168.1.7:8000');
      when(mockConnectionService.checkHealth('', '')).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Use Default'));
      await tester.pumpAndSettle();

      verify(mockConnectionService.checkHealth('', '')).called(1);
      verify(mockConnectionService.saveConnectionSettings('', '')).called(1);
      verify(mockApiService.baseUrl = 'http://192.168.1.7:8000').called(1);
    });
  });
}
