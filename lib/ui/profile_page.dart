import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';
import 'package:leaf_cloud/ui/login_page.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).loginResponse?.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.loginResponse?.user;

    final nameInput = _nameController.text.trim();
    final emailInput = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    final nameChanged = nameInput != user?.name;
    final emailChanged = emailInput != user?.email;
    final passwordChanged = _changePassword && newPassword.isNotEmpty;

    if (!nameChanged && !emailChanged && !passwordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await authProvider.updateProfile(
      name: nameChanged ? nameInput : null,
      email: emailChanged ? emailInput : null,
      currentPassword: passwordChanged ? currentPassword : null,
      newPassword: passwordChanged ? newPassword : null,
    );

    if (!mounted) return;

    if (success) {
      if (emailChanged || passwordChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security settings updated! Please log in again with your new credentials.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).loginResponse?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: const AppFooter(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFF4E7A43),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'LeafCloud User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E29),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user?.isAdmin ?? false
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                                border: Border.all(
                                  color: user?.isAdmin ?? false
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user?.isAdmin ?? false ? 'Administrator' : 'Standard User',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: user?.isAdmin ?? false
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form fields section
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E7A43),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name cannot be empty';
                  return null;
                },
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email cannot be empty';
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: 12),
              // Security Section
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _changePassword,
                        onChanged: (val) {
                          setState(() {
                            _changePassword = val;
                          });
                        },
                        title: const Text(
                          'Change Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E29),
                          ),
                        ),
                        subtitle: const Text('Update account security credentials'),
                        activeThumbColor: const Color(0xFF4E7A43),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_changePassword) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildTextField(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          icon: Icons.lock_open,
                          obscureText: true,
                          validator: (v) {
                            if (_changePassword && (v == null || v.isEmpty)) {
                              return 'Current password is required to verify change';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) {
                            if (_changePassword && (v == null || v.isEmpty)) {
                              return 'New password is required';
                            }
                            if (_changePassword && v!.length < 6) {
                              return 'Must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ]
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E7A43),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF4E7A43)) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}
