import 'package:flutter/material.dart';
import 'package:leaf_cloud/repositories/auth_repository.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';
import 'package:leaf_cloud/repositories/config_repository.dart';
import 'package:leaf_cloud/repositories/config_repository_interface.dart';
import 'package:leaf_cloud/repositories/iot_repository.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';
import 'package:leaf_cloud/repositories/calibration_repository.dart';
import 'package:leaf_cloud/repositories/calibration_repository_interface.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/providers/iot_provider.dart';
import 'package:leaf_cloud/providers/alert_provider.dart';
import 'package:leaf_cloud/providers/calibration_provider.dart';
import 'package:leaf_cloud/services/discovery_service.dart';
import 'package:leaf_cloud/services/notification_service.dart';
import 'package:leaf_cloud/core/auth_client.dart';
import 'package:leaf_cloud/ui/login_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service (wrapped in try-catch to prevent black screen if it fails)
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Failed to initialize NotificationService: $e');
  }

  // Start background discovery
  DiscoveryService().initDiscovery();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider<IAuthRepository>(
          create: (_) => AuthRepository(client: AuthClient()),
        ),
        Provider<IConfigRepository>(
          create: (_) => ConfigRepository(client: AuthClient()),
        ),
        Provider<IIotRepository>(
          create: (_) => IotRepository(client: AuthClient()),
        ),
        Provider<ICalibrationRepository>(
          create: (_) => CalibrationRepository(client: AuthClient()),
        ),
        // Providers
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            Provider.of<IAuthRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ConfigProvider(
            Provider.of<IConfigRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => IotProvider(
            Provider.of<IIotRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CalibrationProvider(
            Provider.of<ICalibrationRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProxyProvider<ConfigProvider, AlertProvider>(
          lazy: false,
          create: (context) => AlertProvider(
            Provider.of<IIotRepository>(context, listen: false),
            Provider.of<ConfigProvider>(context, listen: false),
          ),
          update: (context, config, previous) => previous!,
        ),
      ],
      child: const LoginApp(),
    ),
  );
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafCloud Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7A43),
          surface: const Color(0xFFF4F7F4),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEDF2ED),
      ),
      home: const LoginPage(),
    );
  }
}
