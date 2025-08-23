import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_filter.dart';
import 'package:fieldforce/features/notifications/model/notification_preferences.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';
import 'package:fieldforce/features/notifications/service/mock_notification_service.dart';
import 'package:fpdart/fpdart.dart';

/// Repository for notification-related operations
/// Currently uses mock data - will be connected to FastAPI backend later
class NotificationRepository {
  NotificationRepository();

  /// Get all notifications for the current user
  Future<Either<String, List<NotificationModel>>> getNotifications({
    NotificationFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Loggers.database.info('Fetching notifications - Page: $page, Limit: $limit');

      // For now, return mock data
      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final allNotifications = MockNotificationService.generateMockNotifications(count: 50);
      
      // Apply basic filtering
      var filteredNotifications = allNotifications;
      
      if (filter != null) {
        if (filter.categories?.isNotEmpty ?? false) {
          filteredNotifications = filteredNotifications
              .where((n) => filter.categories!.contains(n.category))
              .toList();
        }
        
        if (filter.onlyUnread) {
          filteredNotifications = filteredNotifications
              .where((n) => n.isUnread)
              .toList();
        }
        
        if (filter.searchQuery?.isNotEmpty ?? false) {
          final query = filter.searchQuery!.toLowerCase();
          filteredNotifications = filteredNotifications
              .where((n) => n.title.toLowerCase().contains(query) || 
                           n.body.toLowerCase().contains(query))
              .toList();
        }
      }
      
      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedNotifications = filteredNotifications.length > startIndex
          ? filteredNotifications.sublist(
              startIndex, 
              endIndex > filteredNotifications.length ? filteredNotifications.length : endIndex
            )
          : <NotificationModel>[];

      Loggers.database.info('Successfully fetched ${paginatedNotifications.length} notifications');
      return right(paginatedNotifications);
    } catch (e) {
      Loggers.database.error('Exception in getNotifications: $e');
      return left('An unexpected error occurred while fetching notifications');
    }
  }

  /// Get notification by ID
  Future<Either<String, NotificationModel>> getNotificationById(String id) async {
    try {
      Loggers.database.info('Fetching notification by ID: $id');

      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 200));
      
      final notifications = MockNotificationService.generateMockNotifications(count: 10);
      final notification = notifications.firstWhere(
        (n) => n.id.contains(id.substring(0, 1)), // Simple mock matching
        orElse: () => notifications.first,
      );

      Loggers.database.info('Successfully fetched notification: $id');
      return right(notification);
    } catch (e) {
      Loggers.database.error('Exception in getNotificationById: $e');
      return left('An unexpected error occurred while fetching notification');
    }
  }

  /// Mark notification as read
  Future<Either<String, NotificationModel>> markAsRead(String id) async {
    try {
      Loggers.database.info('Marking notification as read: $id');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));
      
      final notifications = MockNotificationService.generateMockNotifications(count: 1);
      final notification = notifications.first.copyWith(
        status: NotificationStatus.read,
        readAt: DateTime.now(),
      );

      Loggers.database.info('Successfully marked notification as read: $id');
      return right(notification);
    } catch (e) {
      Loggers.database.error('Exception in markAsRead: $e');
      return left('An unexpected error occurred while marking notification as read');
    }
  }

  /// Mark notification as unread
  Future<Either<String, NotificationModel>> markAsUnread(String id) async {
    try {
      Loggers.database.info('Marking notification as unread: $id');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));
      
      final notifications = MockNotificationService.generateMockNotifications(count: 1);
      final notification = notifications.first.copyWith(
        status: NotificationStatus.unread,
        readAt: null,
      );

      Loggers.database.info('Successfully marked notification as unread: $id');
      return right(notification);
    } catch (e) {
      Loggers.database.error('Exception in markAsUnread: $e');
      return left('An unexpected error occurred while marking notification as unread');
    }
  }

  /// Archive notification
  Future<Either<String, NotificationModel>> archiveNotification(String id) async {
    try {
      Loggers.database.info('Archiving notification: $id');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));
      
      final notifications = MockNotificationService.generateMockNotifications(count: 1);
      final notification = notifications.first.copyWith(
        status: NotificationStatus.archived,
      );

      Loggers.database.info('Successfully archived notification: $id');
      return right(notification);
    } catch (e) {
      Loggers.database.error('Exception in archiveNotification: $e');
      return left('An unexpected error occurred while archiving notification');
    }
  }

  /// Delete notification
  Future<Either<String, bool>> deleteNotification(String id) async {
    try {
      Loggers.database.info('Deleting notification: $id');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));

      Loggers.database.info('Successfully deleted notification: $id');
      return right(true);
    } catch (e) {
      Loggers.database.error('Exception in deleteNotification: $e');
      return left('An unexpected error occurred while deleting notification');
    }
  }

  /// Mark all notifications as read
  Future<Either<String, bool>> markAllAsRead() async {
    try {
      Loggers.database.info('Marking all notifications as read');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 500));

      Loggers.database.info('Successfully marked all notifications as read');
      return right(true);
    } catch (e) {
      Loggers.database.error('Exception in markAllAsRead: $e');
      return left('An unexpected error occurred while marking all notifications as read');
    }
  }

  /// Get unread notification count
  Future<Either<String, int>> getUnreadCount() async {
    try {
      Loggers.database.info('Fetching unread notification count');

      // For now, return mock count
      await Future.delayed(const Duration(milliseconds: 100));
      
      final notifications = MockNotificationService.generateMockNotifications(count: 20);
      final unreadCount = notifications.where((n) => n.isUnread).length;

      Loggers.database.info('Unread notification count: $unreadCount');
      return right(unreadCount);
    } catch (e) {
      Loggers.database.error('Exception in getUnreadCount: $e');
      return left('An unexpected error occurred while fetching unread count');
    }
  }

  /// Get notification preferences
  Future<Either<String, NotificationPreferences>> getNotificationPreferences() async {
    try {
      Loggers.database.info('Fetching notification preferences');

      // For now, return default preferences
      await Future.delayed(const Duration(milliseconds: 200));
      
      const preferences = NotificationPreferences();

      Loggers.database.info('Successfully fetched notification preferences');
      return right(preferences);
    } catch (e) {
      Loggers.database.error('Exception in getNotificationPreferences: $e');
      return left('An unexpected error occurred while fetching notification preferences');
    }
  }

  /// Update notification preferences
  Future<Either<String, NotificationPreferences>> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      Loggers.database.info('Updating notification preferences');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 300));

      Loggers.database.info('Successfully updated notification preferences');
      return right(preferences);
    } catch (e) {
      Loggers.database.error('Exception in updateNotificationPreferences: $e');
      return left('An unexpected error occurred while updating notification preferences');
    }
  }

  /// Register device for push notifications
  Future<Either<String, bool>> registerDeviceToken(String token) async {
    try {
      Loggers.database.info('Registering device token for push notifications');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));

      Loggers.database.info('Successfully registered device token');
      return right(true);
    } catch (e) {
      Loggers.database.error('Exception in registerDeviceToken: $e');
      return left('An unexpected error occurred while registering device token');
    }
  }

  /// Unregister device for push notifications
  Future<Either<String, bool>> unregisterDeviceToken(String token) async {
    try {
      Loggers.database.info('Unregistering device token');

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 200));

      Loggers.database.info('Successfully unregistered device token');
      return right(true);
    } catch (e) {
      Loggers.database.error('Exception in unregisterDeviceToken: $e');
      return left('An unexpected error occurred while unregistering device token');
    }
  }
}