import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/system_config_model.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';

class ConfigPage extends StatefulWidget {
  final SystemConfig? configToEdit;
  const ConfigPage({super.key, this.configToEdit});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _tankNameController = TextEditingController();
  final _waterVolumeController = TextEditingController();
  final _uploadIntervalController = TextEditingController(text: '60');
  final _macroBrandController = TextEditingController();
  final _macroNController = TextEditingController();
  final _macroPController = TextEditingController();
  final _macroKController = TextEditingController();
  final _microBrandController = TextEditingController();
  final _microNController = TextEditingController();
  final _microPController = TextEditingController();
  final _microKController = TextEditingController();
  final _targetMacroDosageController = TextEditingController();
  final _targetMicroDosageController = TextEditingController();
  final _macroDensityController = TextEditingController(text: '1.0');
  final _microDensityController = TextEditingController(text: '1.0');
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.configToEdit != null) {
      _populateFields(widget.configToEdit!);
    }
  }

  void _populateFields(SystemConfig config) {
    _tankNameController.text = config.tankName;
    _waterVolumeController.text = config.waterVolumeLiters.toString();
    _uploadIntervalController.text = config.uploadIntervalSeconds.toString();
    _macroBrandController.text = config.macroBrandName;
    _macroNController.text = config.macroNPct.toString();
    _macroPController.text = config.macroPPct.toString();
    _macroKController.text = config.macroKPct.toString();
    _microBrandController.text = config.microBrandName;
    _microNController.text = config.microNPct.toString();
    _microPController.text = config.microPPct.toString();
    _microKController.text = config.microKPct.toString();
    _targetMacroDosageController.text = config.targetMacroDosageMlL.toString();
    _targetMicroDosageController.text = config.targetMicroDosageMlL.toString();
    _macroDensityController.text = config.macroDensity.toString();
    _microDensityController.text = config.microDensity.toString();
    _isActive = config.isActive;
  }

  @override
  void dispose() {
    _tankNameController.dispose();
    _waterVolumeController.dispose();
    _uploadIntervalController.dispose();
    _macroBrandController.dispose();
    _macroNController.dispose();
    _macroPController.dispose();
    _macroKController.dispose();
    _microBrandController.dispose();
    _microNController.dispose();
    _microPController.dispose();
    _microKController.dispose();
    _targetMacroDosageController.dispose();
    _targetMicroDosageController.dispose();
    _macroDensityController.dispose();
    _microDensityController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    final config = SystemConfig(
      id: widget.configToEdit?.id,
      tankName: _tankNameController.text,
      waterVolumeLiters: double.parse(_waterVolumeController.text),
      macroBrandName: _macroBrandController.text,
      macroNPct: double.parse(_macroNController.text),
      macroPPct: double.parse(_macroPController.text),
      macroKPct: double.parse(_macroKController.text),
      microBrandName: _microBrandController.text,
      microNPct: double.parse(_microNController.text),
      microPPct: double.parse(_microPController.text),
      microKPct: double.parse(_microKController.text),
      targetMacroDosageMlL: double.parse(_targetMacroDosageController.text),
      targetMicroDosageMlL: double.parse(_targetMicroDosageController.text),
      macroDensity: double.parse(_macroDensityController.text),
      microDensity: double.parse(_microDensityController.text),
      isActive: _isActive,
      uploadIntervalSeconds: int.parse(_uploadIntervalController.text),
    );

    final provider = context.read<ConfigProvider>();
    bool success;
    
    if (widget.configToEdit != null) {
      success = await provider.updateConfig(widget.configToEdit!.id!, config);
    } else {
      success = await provider.createConfig(config);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Failed to save configuration'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.configToEdit != null
            ? (isAdmin ? 'Edit Configuration' : 'View Configuration')
            : 'New Configuration'),
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Reservoir Configuration'),
              _buildTextField(
                label: 'Reservoir Name',
                controller: _tankNameController,
                placeholder: 'e.g., "Lettuce Bed A"',
                readOnly: !isAdmin,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : (v.length > 50 ? 'Max 50 chars' : null),
              ),
              _buildTextField(
                label: 'Total Water Volume (Liters)',
                controller: _waterVolumeController,
                placeholder: 'e.g., 50.0',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              _buildTextField(
                label: 'Upload Interval (Seconds)',
                controller: _uploadIntervalController,
                placeholder: 'e.g., 60',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Set as Active Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Only active configurations are used for calculations.'),
                value: _isActive,
                activeThumbColor: const Color(0xFF4E7A43),
                onChanged: isAdmin ? (val) => setState(() => _isActive = val) : null,
              ),
              const Divider(height: 32),
              
              _buildSectionTitle('2. Fertilizer Chemical Profile'),
              _buildSubSectionTitle('A. Macro Fertilizer Profile'),
              _buildTextField(
                label: 'Macro Brand',
                controller: _macroBrandController,
                placeholder: 'e.g., "MasterBlend"',
                readOnly: !isAdmin,
              ),
              _buildNPKRow(_macroNController, _macroPController, _macroKController, !isAdmin),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Density (g/mL)',
                controller: _macroDensityController,
                placeholder: 'e.g., 1.0',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              _buildSubSectionTitle('B. Micro Fertilizer Profile'),
              _buildTextField(
                label: 'Micro Brand',
                controller: _microBrandController,
                placeholder: 'e.g., "NutriHydro"',
                readOnly: !isAdmin,
              ),
              _buildNPKRow(_microNController, _microPController, _microKController, !isAdmin),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Density (g/mL)',
                controller: _microDensityController,
                placeholder: 'e.g., 1.0',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              
              const Divider(height: 32),
              
              _buildSectionTitle('3. Target Recipe Dosage'),
              _buildTextField(
                label: 'Target Macro Dosage (mL/L)',
                controller: _targetMacroDosageController,
                placeholder: '2.0',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val < 0) return 'Must be >= 0';
                  return null;
                },
              ),
              _buildTextField(
                label: 'Target Micro Dosage (mL/L)',
                controller: _targetMicroDosageController,
                placeholder: '2.0',
                isNumeric: true,
                readOnly: !isAdmin,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null) return 'Required';
                  if (val < 0) return 'Must be >= 0';
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              if (isAdmin)
                Consumer<ConfigProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E7A43),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(widget.configToEdit != null ? 'Update Settings' : 'Create Configuration', 
                                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[350]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Read-Only Mode: You do not have permission to make changes. Please contact your administrator.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4E7A43))),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    bool isNumeric = false,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.5),
        ),
        validator: readOnly ? null : (validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null),
      ),
    );
  }

  Widget _buildNPKRow(TextEditingController n, TextEditingController p, TextEditingController k, bool readOnly) {
    return Row(
      children: [
        Expanded(child: _buildPercentageField('N %', n, readOnly)),
        const SizedBox(width: 8),
        Expanded(child: _buildPercentageField('P %', p, readOnly)),
        const SizedBox(width: 8),
        Expanded(child: _buildPercentageField('K %', k, readOnly)),
      ],
    );
  }

  Widget _buildPercentageField(String label, TextEditingController controller, bool readOnly) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      validator: readOnly ? null : (v) {
        final val = double.tryParse(v ?? '');
        if (val == null) return 'Req';
        if (val < 0 || val > 100) return '0-100';
        return null;
      },
    );
  }
}
