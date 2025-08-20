import 'package:fieldforce/features/profile/model/user_settings_model.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for settings controller
final settingsControllerProvider = StateNotifierProvider<SettingsController, UserSettingsModel>((ref) {
  return SettingsController();
});

/// Controller for managing user settings
class SettingsController extends StateNotifier<UserSettingsModel> {
  static const String _settingsKey = 'user_settings';

  SettingsController() : super(const UserSettingsModel()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settings = UserSettingsModel.fromJson(settingsJson);
        state = settings;
        Loggers.database.info('Settings loaded successfully');
      } else {
        Loggers.database.info('No saved settings found, using defaults');
      }
    } catch (e) {
      Loggers.database.error('Failed to load settings: $e');
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, state.toJson());
      Loggers.database.info('Settings saved successfully');
    } catch (e) {
      Loggers.database.error('Failed to save settings: $e');
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(bool isDarkMode) async {
    state = state.copyWith(isDarkMode: isDarkMode);
    await _saveSettings();
    Loggers.database.info('Theme mode updated to: ${isDarkMode ? 'Dark' : 'Light'}');
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
    Loggers.database.info('Language updated to: $language');
  }

  /// Update currency
  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _saveSettings();
    Loggers.database.info('Currency updated to: $currency');
  }

  /// Update date format
  Future<void> updateDateFormat(String dateFormat) async {
    state = state.copyWith(dateFormat: dateFormat);
    await _saveSettings();
    Loggers.database.info('Date format updated to: $dateFormat');
  }

  /// Update time format
  Future<void> updateTimeFormat(String timeFormat) async {
    state = state.copyWith(timeFormat: timeFormat);
    await _saveSettings();
    Loggers.database.info('Time format updated to: $timeFormat');
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings notifications) async {
    state = state.copyWith(notifications: notifications);
    await _saveSettings();
    Loggers.database.info('Notification settings updated');
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings privacy) async {
    state = state.copyWith(privacy: privacy);
    await _saveSettings();
    Loggers.database.info('Privacy settings updated');
  }

  /// Update push notifications
  Future<void> updatePushNotifications(bool enabled) async {
    final notifications = state.notifications.copyWith(pushNotifications: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update email notifications
  Future<void> updateEmailNotifications(bool enabled) async {
    final notifications = state.notifications.copyWith(emailNotifications: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update SMS notifications
  Future<void> updateSmsNotifications(bool enabled) async {
    final notifications = state.notifications.copyWith(smsNotifications: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update order update notifications
  Future<void> updateOrderUpdates(bool enabled) async {
    final notifications = state.notifications.copyWith(orderUpdates: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update payment notifications
  Future<void> updatePaymentNotifications(bool enabled) async {
    final notifications = state.notifications.copyWith(paymentNotifications: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update marketing emails
  Future<void> updateMarketingEmails(bool enabled) async {
    final notifications = state.notifications.copyWith(marketingEmails: enabled);
    await updateNotificationSettings(notifications);
  }

  /// Update profile visibility
  Future<void> updateProfileVisibility(bool visible) async {
    final privacy = state.privacy.copyWith(profileVisibility: visible);
    await updatePrivacySettings(privacy);
  }

  /// Update data sharing with companies
  Future<void> updateDataSharing(bool enabled) async {
    final privacy = state.privacy.copyWith(shareDataWithCompanies: enabled);
    await updatePrivacySettings(privacy);
  }

  /// Update location tracking
  Future<void> updateLocationTracking(bool enabled) async {
    final privacy = state.privacy.copyWith(locationTracking: enabled);
    await updatePrivacySettings(privacy);
  }

  /// Update analytics tracking
  Future<void> updateAnalyticsTracking(bool enabled) async {
    final privacy = state.privacy.copyWith(analyticsTracking: enabled);
    await updatePrivacySettings(privacy);
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    state = const UserSettingsModel();
    await _saveSettings();
    Loggers.database.info('Settings reset to defaults');
  }

  /// Export settings as JSON
  String exportSettings() {
    return state.toJson();
  }

  /// Import settings from JSON
  Future<void> importSettings(String settingsJson) async {
    try {
      final settings = UserSettingsModel.fromJson(settingsJson);
      state = settings;
      await _saveSettings();
      Loggers.database.info('Settings imported successfully');
    } catch (e) {
      Loggers.database.error('Failed to import settings: $e');
      throw Exception('Invalid settings format');
    }
  }
}