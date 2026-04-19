import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_leafcloud_app/landing_screen.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:flutter_leafcloud_app/theme.dart';

import 'landing_screen_test.mocks.dart';

@GenerateMocks([ApiService, ConnectionService])
void main() {
  late MockApiService mockApiService;
  late MockConnectionService mockConnectionService;

  setUp(() {
    mockApiService = MockApiService();
    mockConnectionService = MockConnectionService();
    
    when(mockConnectionService.getSavedIp()).thenAnswer((_) async => '127.0.0.1');
    when(mockConnectionService.getSavedPort()).thenAnswer((_) async => '8080');
    when(mockConnectionService.getBaseUrl(any, any)).thenReturn('http://127.0.0.1:8080');
  });

  Widget createLandingScreen() {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        Provider<ConnectionService>.value(value: mockConnectionService),
      ],
      child: MaterialApp(
        theme: LeafCloudTheme.lightTheme,
        home: const LandingScreen(),
      ),
    );
  }

  testWidgets('LandingScreen displays logo and title', (WidgetTester tester) async {
    await tester.pumpWidget(createLandingScreen());
    await tester.pump(); // Handle initState

    expect(find.text('LeafCloud'), findsOneWidget);
    expect(find.text('Smart Hydroponics Monitoring'), findsOneWidget);
    expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
  });

  testWidgets('LandingScreen displays Get Started button after connection check', (WidgetTester tester) async {
    await tester.pumpWidget(createLandingScreen());
    await tester.pump(); // Finish initState _checkSavedConnection

    expect(find.text('Get Started'), findsOneWidget);
  });
}
