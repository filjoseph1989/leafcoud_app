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

  Future<void> _connect({bool useDefault = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = Provider.of<ConnectionService>(context, listen: false);
    final ip = useDefault ? '' : _ipController.text.trim();
    final port = useDefault ? '' : _portController.text.trim();

    final result = await service.checkHealth(ip, port);

    if (result.success) {
      await service.saveConnectionSettings(ip, port);
      if (mounted) {
        // Update ApiService baseUrl globally
        Provider.of<ApiService>(context, listen: false).baseUrl = service.getBaseUrl(ip, port);
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage ?? 'Could not connect to server. Please check settings.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.settings_remote,
                size: 80,
                color: Colors.green[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Setup',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure the server address to continue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'Server IP / Hostname',
                  hintText: 'e.g. 192.168.1.10',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: 'e.g. 8000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _connect(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Connect',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isLoading ? null : () => _connect(useDefault: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.green[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Use Default',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Troubleshooting Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildTip('Ensure the server is running on the target machine.'),
              _buildTip('Check if both devices are on the same Wi-Fi network.'),
              _buildTip('Android Emulator? Try 10.0.2.2 instead of localhost.'),
              _buildTip('iOS Simulator? localhost or your Mac\'s local IP should work.'),
              _buildTip('Check your firewall settings on the server machine.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
