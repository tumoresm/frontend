import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/notifications/model/notification_preferences.dart';
import 'package:fieldforce/features/notifications/repository/notification_repository.dart';
import 'package:fieldforce/features/notifications/controller/notification_controller.dart';

/// State class for notification preferences
class NotificationPreferencesState {
  final NotificationPreferences preferences;
  final bool isLoading;
  final String? error;
  final bool hasChanges;

  const NotificationPreferencesState({
    this.preferences = const NotificationPreferences(),
    this.isLoading = false,
    this.error,
    this.hasChanges = false,
  });

  NotificationPreferencesState copyWith({
    NotificationPreferences? preferences,
    bool? isLoading,
    String? error,
    bool? hasChanges,
  }) {
    return NotificationPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferencesState(preferences: $preferences, isLoading: $isLoading, error: $error, hasChanges: $hasChanges)';
  }
}

/// Notification preferences controller
class NotificationPreferencesController extends StateNotifier<NotificationPreferencesState> {
  final NotificationRepository _repository;
  NotificationPreferences? _originalPreferences;

  NotificationPreferencesController(this._repository) : super(const NotificationPreferencesState());

  /// Load notification preferences
  Future<void> loadPreferences() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      Loggers.database.info('Loading notification preferences');

      final result = await _repository.getNotificationPreferences();

      result.fold(
        (error) {
          Loggers.database.error('Failed to load notification preferences: $error');
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
        },
        (preferences) {
          _originalPreferences = preferences;
          state = state.copyWith(
            preferences: preferences,
            isLoading: false,
            error: null,
            hasChanges: false,
          );
          Loggers.database.info('Successfully loaded notification preferences');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in loadPreferences: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Save notification preferences
  Future<void> savePreferences() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      Loggers.database.info('Saving notification preferences');

      final result = await _repository.updateNotificationPreferences(state.preferences);

      result.fold(
        (error) {
          Loggers.database.error('Failed to save notification preferences: $error');
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
        },
        (updatedPreferences) {
          _originalPreferences = updatedPreferences;
          state = state.copyWith(
            preferences: updatedPreferences,
            isLoading: false,
            error: null,
            hasChanges: false,
          );
          Loggers.database.info('Successfully saved notification preferences');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in savePreferences: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Update preferences locally (without saving)
  void updatePreferences(NotificationPreferences preferences) {
    final hasChanges = _originalPreferences != null && _originalPreferences != preferences;
    state = state.copyWith(
      preferences: preferences,
      hasChanges: hasChanges,
      error: null,
    );
  }

  /// Reset preferences to original values
  void resetPreferences() {
    if (_originalPreferences != null) {
      state = state.copyWith(
        preferences: _originalPreferences!,
        hasChanges: false,
        error: null,
      );
    }
  }

  /// Update push notifications setting
  void updatePushNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(pushNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update email notifications setting
  void updateEmailNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(emailNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update SMS notifications setting
  void updateSmsNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(smsNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update in-app notifications setting
  void updateInAppNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(inAppNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update order update notifications setting
  void updateOrderUpdateNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(orderUpdateNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update payment notifications setting
  void updatePaymentNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(paymentNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update verification notifications setting
  void updateVerificationNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(verificationNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update promotion notifications setting
  void updatePromotionNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(promotionNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update company notifications setting
  void updateCompanyNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(companyNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update system notifications setting
  void updateSystemNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(systemNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update security notifications setting
  void updateSecurityNotifications(bool enabled) {
    final updatedPreferences = state.preferences.copyWith(securityNotifications: enabled);
    updatePreferences(updatedPreferences);
  }

  /// Update quiet hours setting
  void updateQuietHours({
    bool? enabled,
    int? startHour,
    int? endHour,
  }) {
    final updatedPreferences = state.preferences.copyWith(
      quietHoursEnabled: enabled,
      quietHoursStart: startHour,
      quietHoursEnd: endHour,
    );
    updatePreferences(updatedPreferences);
  }

  /// Update allowed days
  void updateAllowedDays(List<int> days) {
    final updatedPreferences = state.preferences.copyWith(allowedDays: days);
    updatePreferences(updatedPreferences);
  }

  /// Update priority settings
  void updatePrioritySettings({
    bool? allowLow,
    bool? allowNormal,
    bool? allowHigh,
    bool? allowUrgent,
  }) {
    final updatedPreferences = state.preferences.copyWith(
      allowLowPriority: allowLow,
      allowNormalPriority: allowNormal,
      allowHighPriority: allowHigh,
      allowUrgentPriority: allowUrgent,
    );
    updatePreferences(updatedPreferences);
  }

  /// Update grouping settings
  void updateGroupingSettings({
    bool? groupSimilar,
    int? maxPerHour,
    bool? enableSummary,
  }) {
    final updatedPreferences = state.preferences.copyWith(
      groupSimilarNotifications: groupSimilar,
      maxNotificationsPerHour: maxPerHour,
      enableNotificationSummary: enableSummary,
    );
    updatePreferences(updatedPreferences);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check if preferences have unsaved changes
  bool get hasUnsavedChanges => state.hasChanges;

  /// Get current preferences
  NotificationPreferences get currentPreferences => state.preferences;
}

/// Provider for notification preferences controller
final notificationPreferencesControllerProvider =
    StateNotifierProvider<NotificationPreferencesController, NotificationPreferencesState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationPreferencesController(repository);
});

/// Provider for current notification preferences
final currentNotificationPreferencesProvider = Provider<NotificationPreferences>((ref) {
  final preferencesState = ref.watch(notificationPreferencesControllerProvider);
  return preferencesState.preferences;
});

/// Provider for checking if preferences have unsaved changes
final hasUnsavedNotificationChangesProvider = Provider<bool>((ref) {
  final preferencesState = ref.watch(notificationPreferencesControllerProvider);
  return preferencesState.hasChanges;
});