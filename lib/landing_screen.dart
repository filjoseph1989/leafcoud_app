import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/connection_setup_screen.dart';
import 'package:flutter_leafcloud_app/login_screen.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isCheckingConnection = true;
  String? _savedBaseUrl;

  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSavedConnection();
  }

  Future<void> _checkSavedConnection() async {
    final connectionService = Provider.of<ConnectionService>(context, listen: false);
    final ip = await connectionService.getSavedIp();
    final port = await connectionService.getSavedPort();
    
    _savedBaseUrl = connectionService.getBaseUrl(ip, port);
    
    // Update ApiService baseUrl with saved settings if they exist
    if (mounted) {
      Provider.of<ApiService>(context, listen: false).baseUrl = _savedBaseUrl!;
      setState(() {
        _isCheckingConnection = false;
      });
    }
  }

  Future<void> _handleGetStarted() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    final connectionService = Provider.of<ConnectionService>(context, listen: false);
    final ip = await connectionService.getSavedIp();
    final port = await connectionService.getSavedPort();
    
    final result = await connectionService.checkHealth(ip ?? '', port ?? '');

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });

      if (result.success) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // Clear any existing snackbars to prevent stacking
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Connection failed. Please check your settings.'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
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
                          Icons.eco_rounded,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'LeafCloud',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Smart Hydroponics Monitoring',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 80),
                      if (_isCheckingConnection || _isConnecting)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleGetStarted,
                            child: const Text('Get Started'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ConnectionSetupScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Connection Settings'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
