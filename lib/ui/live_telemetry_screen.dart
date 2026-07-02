import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/providers/iot_provider.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';

class SessionLogEntry {
  final DateTime timestamp;
  final double ph;
  final double ec;
  final double waterTemp;

  SessionLogEntry({
    required this.timestamp,
    required this.ph,
    required this.ec,
    required this.waterTemp,
  });
}

class LiveTelemetryScreen extends StatefulWidget {
  const LiveTelemetryScreen({super.key});

  @override
  State<LiveTelemetryScreen> createState() => _LiveTelemetryScreenState();
}

class _LiveTelemetryScreenState extends State<LiveTelemetryScreen> {
  String _selectedMetric = 'ph'; // 'ph', 'ec', 'temp'
  final List<SessionLogEntry> _sessionLogs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePolling();
    });
  }

  void _initializePolling() {
    final activeConfig = context.read<ConfigProvider>().activeConfig;
    if (activeConfig != null) {
      final iotProvider = context.read<IotProvider>();
      
      // Register listener to capture incoming live readings
      iotProvider.addListener(_onIotProviderChanged);
      
      // Start live telemetry polling (every 3 seconds)
      iotProvider.startLiveTelemetryPolling(activeConfig.id!);
    }
  }

  void _onIotProviderChanged() {
    final iotProvider = context.read<IotProvider>();
    final live = iotProvider.liveTelemetry;
    if (live != null) {
      // Deduplicate: only log if timestamp is new
      final isNewTimestamp = _sessionLogs.isEmpty || 
          _sessionLogs.last.timestamp.millisecondsSinceEpoch != live.updatedAt.millisecondsSinceEpoch;
      
      if (isNewTimestamp) {
        setState(() {
          _sessionLogs.add(SessionLogEntry(
            timestamp: live.updatedAt,
            ph: live.ph ?? 0.0,
            ec: live.ec ?? 0.0,
            waterTemp: live.waterTemp ?? 0.0,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    final iotProvider = context.read<IotProvider>();
    iotProvider.removeListener(_onIotProviderChanged);
    iotProvider.stopLiveTelemetryPolling();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final activeConfig = context.read<ConfigProvider>().activeConfig;
    if (activeConfig != null) {
      await context.read<IotProvider>().fetchLiveTelemetry(activeConfig.id!);
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Readings'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppFooter(),
      body: Consumer2<ConfigProvider, IotProvider>(
        builder: (context, configProvider, iotProvider, child) {
          final activeConfig = configProvider.activeConfig;
          if (activeConfig == null) {
            return const Center(
              child: Text(
                'No active reservoir. Please configure one first.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final liveTelemetry = iotProvider.liveTelemetry;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connected Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeConfig.tankName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Row(
                        children: [
                          _PulsingDot(),
                          SizedBox(width: 8),
                          Text(
                            'POLLING LIVE',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Real-time cards (ticking live values)
                  Row(
                    children: [
                      Expanded(
                        child: _buildRealTimeCard(
                          title: 'pH Level',
                          value: liveTelemetry?.ph != null ? liveTelemetry!.ph!.toStringAsFixed(2) : '--',
                          unit: 'pH',
                          icon: Icons.water_drop,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRealTimeCard(
                          title: 'Conductivity',
                          value: liveTelemetry?.ec != null ? liveTelemetry!.ec!.toStringAsFixed(2) : '--',
                          unit: 'mS/cm',
                          icon: Icons.bolt,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRealTimeCard(
                          title: 'Temperature',
                          value: liveTelemetry?.waterTemp != null ? liveTelemetry!.waterTemp!.toStringAsFixed(1) : '--',
                          unit: '°C',
                          icon: Icons.thermostat,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section Title
                  const Text(
                    'Session Logs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E7A43)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select a sensor below to stream live log outputs in real-time.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Sensor Log Selection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildLogSelectorButton(
                          label: 'pH Logs',
                          metricKey: 'ph',
                          icon: Icons.water_drop,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildLogSelectorButton(
                          label: 'EC Logs',
                          metricKey: 'ec',
                          icon: Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildLogSelectorButton(
                          label: 'Temp Logs',
                          metricKey: 'temp',
                          icon: Icons.thermostat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Log Console Box
                  Container(
                    height: 280,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list_alt, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Live Log Stream',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Expanded(
                          child: _sessionLogs.isEmpty
                              ? Center(
                                  child: Text(
                                    'Waiting for live readings from Raspberry Pi...',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _sessionLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = _sessionLogs[index];
                                    return _buildLogLine(log);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRealTimeCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogSelectorButton({
    required String label,
    required String metricKey,
    required IconData icon,
  }) {
    final isSelected = _selectedMetric == metricKey;
    final primaryColor = const Color(0xFF4E7A43);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMetric = metricKey;
        });
        _scrollToBottom();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLine(SessionLogEntry log) {
    final timeStr = _formatTime(log.timestamp);
    String logText = '';

    if (_selectedMetric == 'ph') {
      // Reconstruct raw voltage analog reading for pH
      double voltage = 2.487 + (7.00 - log.ph) * 0.15;
      logText = '⚡ Voltage: ${voltage.toStringAsFixed(4)} V | 🧪 Calculated pH: ${log.ph.toStringAsFixed(2)}';
    } else if (_selectedMetric == 'ec') {
      // Reconstruct raw voltage analog reading for EC
      double voltage = log.ec / 6.04;
      logText = '⚡ Voltage: ${voltage.toStringAsFixed(4)} V | 💧 Calculated EC: ${log.ec.toStringAsFixed(2)} mS/cm';
    } else {
      logText = '🌡️ Temperature: ${log.waterTemp.toStringAsFixed(2)} °C';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$timeStr]  ',
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              logText,
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
