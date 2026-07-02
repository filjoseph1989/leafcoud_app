import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/alert_provider.dart';
import 'package:leaf_cloud/models/alert_model.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrient Alerts'),
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
        actions: [
          Consumer<AlertProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.refresh(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      body: Consumer<AlertProvider>(
        builder: (context, provider, child) {
          final alerts = provider.alerts.values.toList();
          
          if (alerts.isEmpty && !provider.isLoading) {
            return const Center(
              child: Text('No reservoir alerts detected.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return _buildAlertCard(context, alerts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertStatus alert) {
    final isCritical = alert.level?.toUpperCase() == 'CRITICAL';
    final hasAlert = alert.hasAlert;
    
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle_outline;
    
    if (hasAlert) {
      statusColor = isCritical ? Colors.red : Colors.orange;
      statusIcon = isCritical ? Icons.error_outline : Icons.warning_amber_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.5), width: 1),
      ),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text(
          alert.tankName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          hasAlert ? (alert.level ?? 'Alert Active') : 'All levels normal',
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        ),
        children: [
          if (hasAlert)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert.message ?? 'Nutrient level low. Please check the reservoir.',
                      style: TextStyle(color: statusColor.withValues(alpha: 0.9)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Required Top-up:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTopupBadge('Macro', '${alert.topupMacroMl ?? 0} mL', Colors.purple),
                      const SizedBox(width: 8),
                      _buildTopupBadge('Micro', '${alert.topupMicroMl ?? 0} mL', Colors.blue),
                    ],
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('System is within target nutrient range. No action required.'),
            ),
        ],
      ),
    );
  }

  Widget _buildTopupBadge(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $amount',
        style: TextStyle(color: color.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
