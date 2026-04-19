import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/login_screen.dart';

class ConnectionSetupScreen extends StatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  State<ConnectionSetupScreen> createState() => _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends State<ConnectionSetupScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = Provider.of<ConnectionService>(context, listen: false);
    final ip = await service.getSavedIp();
    final port = await service.getSavedPort();
    if (mounted) {
      setState(() {
        _ipController.text = ip ?? '';
        _portController.text = port ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    final service = Provider.of<ConnectionService>(context, listen: false);
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    await service.saveConnectionSettings(ip, port);
    
    if (mounted) {
      // Update ApiService baseUrl globally
      Provider.of<ApiService>(context, listen: false).baseUrl = service.getBaseUrl(ip, port);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.settings_input_component_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connection Setup',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    hintText: 'Server IP / Hostname',
                    prefixIcon: Icon(Icons.dns_rounded),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    hintText: 'Port',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _saveSettings(),
                  child: const Text('Save Settings'),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Troubleshooting Tips',
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildTip(theme, 'Ensure the server is running on the target machine.'),
                      _buildTip(theme, 'Check if both devices are on the same Wi-Fi network.'),
                      _buildTip(theme, 'Android Emulator? Try 10.0.2.2 instead of localhost.'),
                      _buildTip(theme, 'iOS Simulator? localhost or your local IP should work.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
