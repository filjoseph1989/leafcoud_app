import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/connection_setup_screen.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

@GenerateMocks([ConnectionService])
import 'connection_setup_screen_test.mocks.dart';

void main() {
  late MockConnectionService mockService;

  setUp(() {
    mockService = MockConnectionService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Provider<ConnectionService>.value(
        value: mockService,
        child: const ConnectionSetupScreen(),
      ),
    );
  }

  group('ConnectionSetupScreen', () {
    testWidgets('renders IP and Port fields', (WidgetTester tester) async {
      when(mockService.getSavedIp()).thenAnswer((_) async => null);
      when(mockService.getSavedPort()).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Server IP / Hostname'), findsOneWidget);
      expect(find.text('Port'), findsOneWidget);
    });

    testWidgets('pre-fills saved IP and Port', (WidgetTester tester) async {
      when(mockService.getSavedIp()).thenAnswer((_) async => '1.2.3.4');
      when(mockService.getSavedPort()).thenAnswer((_) async => '8080');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('1.2.3.4'), findsOneWidget);
      expect(find.text('8080'), findsOneWidget);
    });

    testWidgets('shows loading indicator and performs health check on Connect', (WidgetTester tester) async {
      when(mockService.getSavedIp()).thenAnswer((_) async => '1.2.3.4');
      when(mockService.getSavedPort()).thenAnswer((_) async => '8080');
      when(mockService.checkHealth(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Connect'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      verify(mockService.checkHealth('1.2.3.4', '8080')).called(1);
      verify(mockService.saveConnectionSettings('1.2.3.4', '8080')).called(1);
    });

    testWidgets('shows error message on health check failure', (WidgetTester tester) async {
      when(mockService.getSavedIp()).thenAnswer((_) async => null);
      when(mockService.getSavedPort()).thenAnswer((_) async => null);
      when(mockService.checkHealth(any, any)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Server IP / Hostname'), 'invalid');
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(find.text('Could not connect to server. Please check settings.'), findsOneWidget);
    });

    testWidgets('Connects to default on "Use Default" tap', (WidgetTester tester) async {
      when(mockService.getSavedIp()).thenAnswer((_) async => null);
      when(mockService.getSavedPort()).thenAnswer((_) async => null);
      when(mockService.checkHealth('', '')).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Use Default'));
      await tester.pumpAndSettle();

      verify(mockService.checkHealth('', '')).called(1);
      verify(mockService.saveConnectionSettings('', '')).called(1);
    });
  });
}
