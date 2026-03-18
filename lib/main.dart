import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/login_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/history_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';

import 'package:flutter_leafcloud_app/services/api_service.dart';

void main() {
  final httpClient = http.Client();
  final apiService = ApiService(
    client: httpClient,
    baseUrl: 'http://192.168.1.7:8000',
  );

  runApp(
    MultiProvider(
      providers: [
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
