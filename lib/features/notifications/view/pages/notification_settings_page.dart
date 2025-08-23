import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fieldforce/features/notifications/controller/notification_preferences_controller.dart';

/// Enhanced notification settings page
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load preferences when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationPreferencesControllerProvider.notifier)
          .loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferencesState =
        ref.watch(notificationPreferencesControllerProvider);
    final controller =
        ref.read(notificationPreferencesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          if (preferencesState.hasChanges)
            TextButton(
              onPressed: preferencesState.isLoading
                  ? null
                  : () {
                      controller.savePreferences();
                    },
              child: preferencesState.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: preferencesState.isLoading && !preferencesState.hasChanges
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (preferencesState.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.error,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              preferencesState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.clearError,
                            icon: const Icon(Symbols.close),
                          ),
                        ],
                      ),
                    ),

                  // Unsaved changes warning
                  if (preferencesState.hasChanges)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.info,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You have unsaved changes',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.resetPreferences,
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),

                  // Delivery Methods
                  _buildDeliveryMethodsSection(
                      preferencesState.preferences, controller),
                  const SizedBox(height: 24),

                  // Notification Categories
                  _buildCategoriesSection(
                      preferencesState.preferences, controller),
                  const SizedBox(height: 24),

                  // Quiet Hours
                  _buildQuietHoursSection(
                      preferencesState.preferences, controller),
                  const SizedBox(height: 24),

                  // Priority Settings
                  _buildPrioritySection(
                      preferencesState.preferences, controller),
                  const SizedBox(height: 24),

                  // Advanced Settings
                  _buildAdvancedSection(
                      preferencesState.preferences, controller),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildDeliveryMethodsSection(preferences, controller) {
    return _buildSection(
      title: 'Delivery Methods',
      icon: Symbols.notifications,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          value: preferences.pushNotifications,
          onChanged: controller.updatePushNotifications,
          icon: Symbols.notifications_active,
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: preferences.emailNotifications,
          onChanged: controller.updateEmailNotifications,
          icon: Symbols.email,
        ),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive notifications via SMS',
          value: preferences.smsNotifications,
          onChanged: controller.updateSmsNotifications,
          icon: Symbols.sms,
        ),
        _buildSwitchTile(
          title: 'In-App Notifications',
          subtitle: 'Show notifications within the app',
          value: preferences.inAppNotifications,
          onChanged: controller.updateInAppNotifications,
          icon: Symbols.app_badging,
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(preferences, controller) {
    return _buildSection(
      title: 'Notification Categories',
      icon: Symbols.category,
      children: [
        _buildSwitchTile(
          title: 'Order Updates',
          subtitle: 'Order status changes and updates',
          value: preferences.orderUpdateNotifications,
          onChanged: controller.updateOrderUpdateNotifications,
          icon: Symbols.shopping_cart,
        ),
        _buildSwitchTile(
          title: 'Payment Notifications',
          subtitle: 'Earnings, withdrawals, and payments',
          value: preferences.paymentNotifications,
          onChanged: controller.updatePaymentNotifications,
          icon: Symbols.payments,
        ),
        _buildSwitchTile(
          title: 'Verification Updates',
          subtitle: 'Account verification status changes',
          value: preferences.verificationNotifications,
          onChanged: controller.updateVerificationNotifications,
          icon: Symbols.verified_user,
        ),
        _buildSwitchTile(
          title: 'Company Notifications',
          subtitle: 'New opportunities and company updates',
          value: preferences.companyNotifications,
          onChanged: controller.updateCompanyNotifications,
          icon: Symbols.business,
        ),
        _buildSwitchTile(
          title: 'System Notifications',
          subtitle: 'App updates and system messages',
          value: preferences.systemNotifications,
          onChanged: controller.updateSystemNotifications,
          icon: Symbols.settings,
        ),
        _buildSwitchTile(
          title: 'Security Alerts',
          subtitle: 'Login attempts and security warnings',
          value: preferences.securityNotifications,
          onChanged: controller.updateSecurityNotifications,
          icon: Symbols.security,
        ),
        _buildSwitchTile(
          title: 'Promotional Offers',
          subtitle: 'Marketing and promotional content',
          value: preferences.promotionNotifications,
          onChanged: controller.updatePromotionNotifications,
          icon: Symbols.local_offer,
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(preferences, controller) {
    return _buildSection(
      title: 'Quiet Hours',
      icon: Symbols.bedtime,
      children: [
        _buildSwitchTile(
          title: 'Enable Quiet Hours',
          subtitle: preferences.quietHoursEnabled
              ? 'Active: ${preferences.quietHoursString}'
              : 'Notifications will be silenced during quiet hours',
          value: preferences.quietHoursEnabled,
          onChanged: (enabled) => controller.updateQuietHours(enabled: enabled),
          icon: Symbols.do_not_disturb,
        ),
        if (preferences.quietHoursEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  title: 'Start Time',
                  time: preferences.quietHoursStart,
                  onChanged: (time) =>
                      controller.updateQuietHours(startHour: time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeSelector(
                  title: 'End Time',
                  time: preferences.quietHoursEnd,
                  onChanged: (time) =>
                      controller.updateQuietHours(endHour: time),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrioritySection(preferences, controller) {
    return _buildSection(
      title: 'Priority Settings',
      icon: Symbols.priority_high,
      children: [
        _buildSwitchTile(
          title: 'Low Priority',
          subtitle: 'General information and updates',
          value: preferences.allowLowPriority,
          onChanged: (value) =>
              controller.updatePrioritySettings(allowLow: value),
          icon: Symbols.low_priority,
        ),
        _buildSwitchTile(
          title: 'Normal Priority',
          subtitle: 'Standard notifications',
          value: preferences.allowNormalPriority,
          onChanged: (value) =>
              controller.updatePrioritySettings(allowNormal: value),
          icon: Symbols.notifications,
        ),
        _buildSwitchTile(
          title: 'High Priority',
          subtitle: 'Important updates requiring attention',
          value: preferences.allowHighPriority,
          onChanged: (value) =>
              controller.updatePrioritySettings(allowHigh: value),
          icon: Symbols.priority_high,
        ),
        _buildSwitchTile(
          title: 'Urgent Priority',
          subtitle: 'Critical alerts and emergencies',
          value: preferences.allowUrgentPriority,
          onChanged: (value) =>
              controller.updatePrioritySettings(allowUrgent: value),
          icon: Symbols.warning,
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(preferences, controller) {
    return _buildSection(
      title: 'Advanced Settings',
      icon: Symbols.tune,
      children: [
        _buildSwitchTile(
          title: 'Group Similar Notifications',
          subtitle: 'Combine similar notifications to reduce clutter',
          value: preferences.groupSimilarNotifications,
          onChanged: (value) =>
              controller.updateGroupingSettings(groupSimilar: value),
          icon: Symbols.group_work,
        ),
        _buildSwitchTile(
          title: 'Notification Summary',
          subtitle: 'Receive daily summary of notifications',
          value: preferences.enableNotificationSummary,
          onChanged: (value) =>
              controller.updateGroupingSettings(enableSummary: value),
          icon: Symbols.summarize,
        ),
        ListTile(
          leading: const Icon(Symbols.speed),
          title: const Text('Max Notifications Per Hour'),
          subtitle: Text('Currently: ${preferences.maxNotificationsPerHour}'),
          trailing: SizedBox(
            width: 100,
            child: Slider(
              value: preferences.maxNotificationsPerHour.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: preferences.maxNotificationsPerHour.toString(),
              onChanged: (value) => controller.updateGroupingSettings(
                maxPerHour: value.round(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required int time,
    required Function(int) onChanged,
  }) {
    return OutlinedButton(
      onPressed: () async {
        final timeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: time, minute: 0),
        );
        if (timeOfDay != null) {
          onChanged(timeOfDay.hour);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          const SizedBox(height: 4),
          Text(
            '${time.toString().padLeft(2, '0')}:00',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
