import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/landing_screen.dart';
import 'package:flutter_leafcloud_app/connection_setup_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/history_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/trash_notifier.dart';

import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:flutter_leafcloud_app/theme.dart';

void main() {
  final httpClient = http.Client();
  final connectionService = ConnectionService(client: httpClient);
  
  // Initialize with an empty URL, will be updated in LandingScreen or ConnectionSetupScreen
  final apiService = ApiService(
    client: httpClient,
    baseUrl: '',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ConnectionService>.value(value: connectionService),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => SensorDataNotifier(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => BucketControlNotifier(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ImageManagementNotifier(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryNotifier(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => TrashNotifier(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafCloud',
      debugShowCheckedModeBanner: false,
      theme: LeafCloudTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}
