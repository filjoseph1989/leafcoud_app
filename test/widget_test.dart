import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/main.dart';
import 'package:leaf_cloud/repositories/auth_repository.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';

void main() {
  testWidgets('LeafCloud custom login theme test', (WidgetTester tester) async {
    // Build our app with required providers.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IAuthRepository>(
            create: (_) => AuthRepository(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(
              Provider.of<IAuthRepository>(context, listen: false),
            ),
          ),
        ],
        child: const LoginApp(),
      ),
    );

    // Verify presence of custom design elements.
    expect(find.text('LeafCloud'), findsOneWidget);
    expect(find.text('Smart Hydroponics Monitoring'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Interact with form.
    await tester.enterText(find.byType(TextFormField).at(0), 'user@leafcloud.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    // Tap login.
    await tester.tap(find.text('Login'));
    
    // Settle everything.
    await tester.pumpAndSettle();

    // In a test environment, real http calls fail/return 400.
    // The AuthRepository throws an error which the Provider catches.
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
