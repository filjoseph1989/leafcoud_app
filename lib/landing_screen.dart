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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Connection failed. Please check your settings.'),
            backgroundColor: Colors.red[700],
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ConnectionSetupScreen()),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 120,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LeafCloud',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Hydroponics Monitoring',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[800]?.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 64),
                    if (_isCheckingConnection || _isConnecting)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _handleGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
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
                    icon: const Icon(Icons.settings),
                    label: const Text('Connection Settings'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[800],
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
