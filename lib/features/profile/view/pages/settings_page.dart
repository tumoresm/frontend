import 'package:fieldforce/features/profile/controller/settings_controller.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/auth/view/pages/verification_page.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final currentUser = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            SettingsSection(
              title: 'Account',
              icon: Symbols.person,
              children: [
                currentUser.when(
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        SettingsTile(
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          icon: Symbols.edit,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VerificationPage(),
                              ),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'Account Information',
                          subtitle: user.email,
                          icon: Symbols.account_circle,
                          onTap: () {
                            _showAccountInfoDialog(context, user);
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences Section
            SettingsSection(
              title: 'App Preferences',
              icon: Symbols.tune,
              children: [
                SettingsTile(
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  icon: settings.isDarkMode ? Symbols.dark_mode : Symbols.light_mode,
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      settingsController.updateThemeMode(value);
                    },
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Language',
                  subtitle: _getLanguageDisplayName(settings.language),
                  icon: Symbols.language,
                  onTap: () => _showLanguageDialog(context, settingsController, settings.language),
                ),
                SettingsTile(
                  title: 'Currency',
                  subtitle: settings.currency,
                  icon: Symbols.attach_money,
                  onTap: () => _showCurrencyDialog(context, settingsController, settings.currency),
                ),
                SettingsTile(
                  title: 'Date Format',
                  subtitle: settings.dateFormat,
                  icon: Symbols.calendar_today,
                  onTap: () => _showDateFormatDialog(context, settingsController, settings.dateFormat),
                ),
                SettingsTile(
                  title: 'Time Format',
                  subtitle: settings.timeFormat,
                  icon: Symbols.schedule,
                  onTap: () => _showTimeFormatDialog(context, settingsController, settings.timeFormat),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Section
            SettingsSection(
              title: 'Notifications',
              icon: Symbols.notifications,
              children: [
                SettingsTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications on your device',
                  icon: Symbols.notifications_active,
                  trailing: Switch(
                    value: settings.notifications.pushNotifications,
                    onChanged: settingsController.updatePushNotifications,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive notifications via email',
                  icon: Symbols.email,
                  trailing: Switch(
                    value: settings.notifications.emailNotifications,
                    onChanged: settingsController.updateEmailNotifications,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'SMS Notifications',
                  subtitle: 'Receive notifications via SMS',
                  icon: Symbols.sms,
                  trailing: Switch(
                    value: settings.notifications.smsNotifications,
                    onChanged: settingsController.updateSmsNotifications,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Order Updates',
                  subtitle: 'Get notified about order status changes',
                  icon: Symbols.shopping_bag,
                  trailing: Switch(
                    value: settings.notifications.orderUpdates,
                    onChanged: settingsController.updateOrderUpdates,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Payment Notifications',
                  subtitle: 'Get notified about payments and earnings',
                  icon: Symbols.payment,
                  trailing: Switch(
                    value: settings.notifications.paymentNotifications,
                    onChanged: settingsController.updatePaymentNotifications,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Marketing Emails',
                  subtitle: 'Receive promotional emails and updates',
                  icon: Symbols.campaign,
                  trailing: Switch(
                    value: settings.notifications.marketingEmails,
                    onChanged: settingsController.updateMarketingEmails,
                    activeColor: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Section
            SettingsSection(
              title: 'Privacy & Data',
              icon: Symbols.privacy_tip,
              children: [
                SettingsTile(
                  title: 'Profile Visibility',
                  subtitle: 'Make your profile visible to companies',
                  icon: Symbols.visibility,
                  trailing: Switch(
                    value: settings.privacy.profileVisibility,
                    onChanged: settingsController.updateProfileVisibility,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Share Data with Companies',
                  subtitle: 'Allow companies to access your performance data',
                  icon: Symbols.share,
                  trailing: Switch(
                    value: settings.privacy.shareDataWithCompanies,
                    onChanged: settingsController.updateDataSharing,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Location Tracking',
                  subtitle: 'Allow location tracking for better service',
                  icon: Symbols.location_on,
                  trailing: Switch(
                    value: settings.privacy.locationTracking,
                    onChanged: settingsController.updateLocationTracking,
                    activeColor: kPrimary,
                  ),
                ),
                SettingsTile(
                  title: 'Analytics Tracking',
                  subtitle: 'Help improve the app with usage analytics',
                  icon: Symbols.analytics,
                  trailing: Switch(
                    value: settings.privacy.analyticsTracking,
                    onChanged: settingsController.updateAnalyticsTracking,
                    activeColor: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Advanced Section
            SettingsSection(
              title: 'Advanced',
              icon: Symbols.settings_applications,
              children: [
                SettingsTile(
                  title: 'Export Settings',
                  subtitle: 'Export your settings as a backup',
                  icon: Symbols.download,
                  onTap: () => _exportSettings(context, settingsController),
                ),
                SettingsTile(
                  title: 'Reset Settings',
                  subtitle: 'Reset all settings to default values',
                  icon: Symbols.restart_alt,
                  onTap: () => _showResetDialog(context, settingsController),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      default:
        return 'English';
    }
  }

  void _showAccountInfoDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', user.fullName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', user.phoneNumber),
            _buildInfoRow('Role', user.role),
            _buildInfoRow('Verification Status', user.verificationStatus.toString().split('.').last),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller, String currentLanguage) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'pt', 'name': 'Português'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsController controller, String currentCurrency) {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: currentCurrency,
              onChanged: (value) {
                if (value != null) {
                  controller.updateCurrency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context, SettingsController controller, String currentFormat) {
    final formats = ['MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd', 'dd-MM-yyyy'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return RadioListTile<String>(
              title: Text(format),
              value: format,
              groupValue: currentFormat,
              onChanged: (value) {
                if (value != null) {
                  controller.updateDateFormat(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeFormatDialog(BuildContext context, SettingsController controller, String currentFormat) {
    final formats = ['12h', '24h'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return RadioListTile<String>(
              title: Text(format == '12h' ? '12 Hour' : '24 Hour'),
              value: format,
              groupValue: currentFormat,
              onChanged: (value) {
                if (value != null) {
                  controller.updateTimeFormat(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _exportSettings(BuildContext context, SettingsController controller) {
    final settingsJson = controller.exportSettings();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your settings have been exported. Copy the text below:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                settingsJson,
                style: const TextStyle(fontSize: 12),
              ),
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

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}