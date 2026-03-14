import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/ph_monitor_notifier.dart';
import 'package:intl/intl.dart';

class PHMonitorScreen extends StatefulWidget {
  const PHMonitorScreen({super.key});

  @override
  State<PHMonitorScreen> createState() => _PHMonitorScreenState();
}

class _PHMonitorScreenState extends State<PHMonitorScreen> {
  late PHMonitorNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = context.read<PHMonitorNotifier>();
    // Connect to the WebSocket when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.connect(const String.fromEnvironment('PH_WS_URL', defaultValue: 'ws://localhost:8000/iot/ph/stream'));
    });
  }

  @override
  void dispose() {
    _notifier.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pH Monitor'),
      ),
      body: Consumer<PHMonitorNotifier>(
        builder: (context, notifier, child) {
          return Column(
            children: [
              _buildStatusHeader(notifier.isConnected, notifier.isReconnecting),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifier.readings.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final reading = notifier.readings[index];
                    return ListTile(
                      title: Text(reading.deviceId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(reading.timestamp),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ADC: ${reading.rawAdc}', style: const TextStyle(fontSize: 14)),
                          Text('${reading.voltage.toStringAsFixed(2)} V', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(bool isConnected, bool isReconnecting) {
    Color backgroundColor = Colors.red.shade100;
    Color iconColor = Colors.red;
    IconData icon = Icons.error;
    String statusText = 'Disconnected';

    if (isConnected) {
      backgroundColor = Colors.green.shade100;
      iconColor = Colors.green;
      icon = Icons.check_circle;
      statusText = 'Connected';
    } else if (isReconnecting) {
      backgroundColor = Colors.orange.shade100;
      iconColor = Colors.orange;
      icon = Icons.sync;
      statusText = 'Reconnecting...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: backgroundColor,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Status: $statusText',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isConnected ? Colors.green.shade900 : (isReconnecting ? Colors.orange.shade900 : Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
