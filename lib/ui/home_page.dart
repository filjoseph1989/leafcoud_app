import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/providers/iot_provider.dart';
import 'package:leaf_cloud/ui/config_list_page.dart';
import 'package:leaf_cloud/ui/dashboard_screen.dart';
import 'package:leaf_cloud/ui/history_screen.dart';
import 'package:leaf_cloud/ui/alerts_screen.dart';
import 'package:leaf_cloud/ui/calibration_screen.dart';
import 'package:leaf_cloud/ui/register_page.dart';
import 'package:leaf_cloud/ui/profile_page.dart';
import 'package:leaf_cloud/ui/live_telemetry_screen.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';
import 'package:leaf_cloud/providers/alert_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeafCloud'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
        actions: [
          Consumer<AlertProvider>(
            builder: (context, alertProvider, child) {
              final hasActiveAlert = alertProvider.alerts.values.any((status) => status.hasAlert);
              return IconButton(
                icon: Icon(
                  hasActiveAlert ? Icons.notifications_active : Icons.notifications,
                  color: hasActiveAlert ? Colors.amber[300] : Colors.white,
                ),
                tooltip: 'Nutrient Alerts',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AlertsScreen()),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: () async {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              
              final configProvider = context.read<ConfigProvider>();
              await configProvider.fetchConfigs();
              final activeConfig = configProvider.activeConfig;
              if (activeConfig != null && context.mounted) {
                await context.read<IotProvider>().fetchDashboard(activeConfig.id!);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4E7A43),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.eco, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'LeafCloud',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Smart Hydroponics',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Color(0xFF4E7A43)),
              title: const Text('Nutrient Alerts'),
              subtitle: const Text('Top-up instructions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF4E7A43)),
              title: const Text('Reading History'),
              subtitle: const Text('Photos & sensor trends'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bolt, color: Color(0xFF4E7A43)),
              title: const Text('Live Readings'),
              subtitle: const Text('Real-time sensor logs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiveTelemetryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4E7A43)),
              title: const Text('Reservoir Settings'),
              subtitle: const Text('Manage reservoir and fertilizers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigListPage()),
                );
              },
            ),
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.compass_calibration, color: Color(0xFF4E7A43)),
                title: const Text('Sensor Calibration'),
                subtitle: const Text('Calibrate pH and EC sensors'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalibrationScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF4E7A43)),
                title: const Text('Add New User'),
                subtitle: const Text('Register a new user account'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.account_circle, color: Color(0xFF4E7A43)),
              title: const Text('My Profile'),
              subtitle: const Text('Manage name, email, and password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: const DashboardScreen(),
    );
  }
}
