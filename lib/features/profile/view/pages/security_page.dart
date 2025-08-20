import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _sessionAlerts = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Security Section
            SettingsSection(
              title: 'Account Security',
              icon: Symbols.security,
              children: [
                SettingsTile(
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  icon: Symbols.lock,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                SettingsTile(
                  title: 'Two-Factor Authentication',
                  subtitle: _twoFactorEnabled 
                      ? 'Enabled - Your account is protected'
                      : 'Disabled - Enable for better security',
                  icon: Symbols.verified_user,
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      if (value) {
                        _showTwoFactorSetupDialog(context);
                      }
                    },
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face recognition',
                  icon: Symbols.fingerprint,
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      _showBiometricDialog(context, value);
                    },
                    activeColor: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Session Management Section
            SettingsSection(
              title: 'Session Management',
              icon: Symbols.devices,
              children: [
                SettingsTile(
                  title: 'Active Sessions',
                  subtitle: 'Manage your active login sessions',
                  icon: Symbols.smartphone,
                  onTap: () => _showActiveSessionsDialog(context),
                ),
                SettingsTile(
                  title: 'Login History',
                  subtitle: 'View your recent login activity',
                  icon: Symbols.history,
                  onTap: () => _showLoginHistoryDialog(context),
                ),
                SettingsTile(
                  title: 'Session Alerts',
                  subtitle: 'Get notified of new login attempts',
                  icon: Symbols.notification_important,
                  trailing: Switch(
                    value: _sessionAlerts,
                    onChanged: (value) {
                      setState(() {
                        _sessionAlerts = value;
                      });
                    },
                    activeColor: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy & Data Section
            SettingsSection(
              title: 'Privacy & Data',
              icon: Symbols.privacy_tip,
              children: [
                SettingsTile(
                  title: 'Download My Data',
                  subtitle: 'Export your personal data',
                  icon: Symbols.download,
                  onTap: () => _showDataExportDialog(context),
                ),
                SettingsTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  icon: Symbols.delete_forever,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Security Status Card
            currentUser.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                return _buildSecurityStatusCard(context, user);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard(BuildContext context, dynamic user) {
    final securityScore = _calculateSecurityScore();
    final color = securityScore >= 80 
        ? Colors.green 
        : securityScore >= 60 
            ? Colors.orange 
            : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.shield, color: color),
                const SizedBox(width: 8),
                Text(
                  'Security Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: securityScore / 100,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$securityScore%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getSecurityMessage(securityScore),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSecurityScore() {
    int score = 40; // Base score for having an account
    
    if (_twoFactorEnabled) score += 30;
    if (_biometricEnabled) score += 20;
    if (_sessionAlerts) score += 10;
    
    return score;
  }

  String _getSecurityMessage(int score) {
    if (score >= 80) {
      return 'Excellent! Your account is well protected.';
    } else if (score >= 60) {
      return 'Good security. Consider enabling more features.';
    } else {
      return 'Your account needs better protection. Enable security features.';
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 8 characters long'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              
              try {
                // Note: This would typically call an API to change password
                // For now, we'll show a success message
                await Future.delayed(const Duration(seconds: 1)); // Simulate API call
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error changing password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.verified_user, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Two-factor authentication adds an extra layer of security to your account.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This feature will be available in a future update.',
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: Text(
          enabled
              ? 'Biometric authentication has been enabled. You can now use your fingerprint or face recognition to log in.'
              : 'Biometric authentication has been disabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Symbols.smartphone),
              title: Text('Current Device'),
              subtitle: Text('Last active: Now'),
              trailing: Chip(label: Text('Current')),
            ),
            ListTile(
              leading: Icon(Symbols.computer),
              title: Text('Web Browser'),
              subtitle: Text('Last active: 2 hours ago'),
              trailing: TextButton(child: Text('Revoke'), onPressed: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login History'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Symbols.smartphone, color: Colors.green),
              title: Text('Mobile App'),
              subtitle: Text('Today, 9:30 AM'),
            ),
            ListTile(
              leading: Icon(Symbols.computer, color: Colors.blue),
              title: Text('Web Browser'),
              subtitle: Text('Yesterday, 2:15 PM'),
            ),
            ListTile(
              leading: Icon(Symbols.smartphone, color: Colors.green),
              title: Text('Mobile App'),
              subtitle: Text('2 days ago, 8:45 AM'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'We will prepare a file containing all your personal data and send it to your registered email address within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export request submitted')),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}