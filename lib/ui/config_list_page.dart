import 'package:flutter/material.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/ui/config_page.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';

class ConfigListPage extends StatefulWidget {
  const ConfigListPage({super.key});

  @override
  State<ConfigListPage> createState() => _ConfigListPageState();
}

class _ConfigListPageState extends State<ConfigListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigProvider>().fetchConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservoir Configurations'),
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppFooter(),
      body: Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.configs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.configs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchConfigs(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.configs.isEmpty) {
            return const Center(
              child: Text('No configurations found. Create your first one!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchConfigs(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.configs.length,
              itemBuilder: (context, index) {
                final config = provider.configs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: config.isActive ? const Color(0xFF4E7A43) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: config.isActive ? const Color(0xFF4E7A43) : Colors.grey[300],
                      child: Icon(
                        config.isActive ? Icons.check : Icons.water_drop,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      config.tankName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Volume: ${config.waterVolumeLiters} L'),
                        Text('Upload Interval: ${config.uploadIntervalSeconds}s'),
                        Text('Macro: ${config.macroBrandName}'),
                        if (config.isActive)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(color: Color(0xFF4E7A43), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfigPage(configToEdit: config),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigPage()),
                );
              },
              backgroundColor: const Color(0xFF4E7A43),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
