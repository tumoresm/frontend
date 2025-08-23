import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_filter.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';
import 'package:fieldforce/features/notifications/repository/notification_repository.dart';

/// State class for notifications
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
    this.hasMore = true,
    this.currentPage = 1,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() {
    return 'NotificationState(notifications: ${notifications.length}, isLoading: $isLoading, error: $error, unreadCount: $unreadCount, hasMore: $hasMore, currentPage: $currentPage)';
  }
}

/// Notification controller for managing notification state
class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationController(this._repository) : super(const NotificationState());

  /// Load notifications with optional filter
  Future<void> loadNotifications({
    NotificationFilter? filter,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMore: true,
        );
      } else if (state.isLoading || !state.hasMore) {
        return;
      } else {
        state = state.copyWith(isLoading: true, error: null);
      }

      final page = refresh ? 1 : state.currentPage;
      Loggers.database.info('Loading notifications - Page: $page, Refresh: $refresh');

      final result = await _repository.getNotifications(
        filter: filter,
        page: page,
        limit: 20,
      );

      result.fold(
        (error) {
          Loggers.database.error('Failed to load notifications: $error');
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
        },
        (newNotifications) {
          final updatedNotifications = refresh
              ? newNotifications
              : [...state.notifications, ...newNotifications];

          state = state.copyWith(
            notifications: updatedNotifications,
            isLoading: false,
            error: null,
            hasMore: newNotifications.length >= 20,
            currentPage: page + 1,
          );

          Loggers.database.info('Successfully loaded ${newNotifications.length} notifications');
          
          // Also update unread count
          _updateUnreadCount();
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in loadNotifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications({NotificationFilter? filter}) async {
    if (!state.hasMore || state.isLoading) return;
    await loadNotifications(filter: filter, refresh: false);
  }

  /// Refresh notifications
  Future<void> refreshNotifications({NotificationFilter? filter}) async {
    await loadNotifications(filter: filter, refresh: true);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      Loggers.database.info('Marking notification as read: $notificationId');

      // Optimistically update the UI
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(
            status: NotificationStatus.read,
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );

      // Make API call
      final result = await _repository.markAsRead(notificationId);

      result.fold(
        (error) {
          Loggers.database.error('Failed to mark notification as read: $error');
          // Revert optimistic update
          _revertNotificationUpdate(notificationId);
        },
        (updatedNotification) {
          // Update with server response
          final finalNotifications = state.notifications.map((notification) {
            if (notification.id == notificationId) {
              return updatedNotification;
            }
            return notification;
          }).toList();

          state = state.copyWith(notifications: finalNotifications);
          Loggers.database.info('Successfully marked notification as read');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in markAsRead: $e');
      _revertNotificationUpdate(notificationId);
    }
  }

  /// Mark notification as unread
  Future<void> markAsUnread(String notificationId) async {
    try {
      Loggers.database.info('Marking notification as unread: $notificationId');

      // Optimistically update the UI
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(
            status: NotificationStatus.unread,
            readAt: null,
          );
        }
        return notification;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount + 1,
      );

      // Make API call
      final result = await _repository.markAsUnread(notificationId);

      result.fold(
        (error) {
          Loggers.database.error('Failed to mark notification as unread: $error');
          // Revert optimistic update
          _revertNotificationUpdate(notificationId);
        },
        (updatedNotification) {
          // Update with server response
          final finalNotifications = state.notifications.map((notification) {
            if (notification.id == notificationId) {
              return updatedNotification;
            }
            return notification;
          }).toList();

          state = state.copyWith(notifications: finalNotifications);
          Loggers.database.info('Successfully marked notification as unread');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in markAsUnread: $e');
      _revertNotificationUpdate(notificationId);
    }
  }

  /// Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      Loggers.database.info('Archiving notification: $notificationId');

      // Optimistically remove from list
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final wasUnread = state.notifications
          .firstWhere((n) => n.id == notificationId)
          .isUnread;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: wasUnread ? state.unreadCount - 1 : state.unreadCount,
      );

      // Make API call
      final result = await _repository.archiveNotification(notificationId);

      result.fold(
        (error) {
          Loggers.database.error('Failed to archive notification: $error');
          // Revert by refreshing
          refreshNotifications();
        },
        (archivedNotification) {
          Loggers.database.info('Successfully archived notification');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in archiveNotification: $e');
      // Revert by refreshing
      refreshNotifications();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      Loggers.database.info('Deleting notification: $notificationId');

      // Optimistically remove from list
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final wasUnread = state.notifications
          .firstWhere((n) => n.id == notificationId)
          .isUnread;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: wasUnread ? state.unreadCount - 1 : state.unreadCount,
      );

      // Make API call
      final result = await _repository.deleteNotification(notificationId);

      result.fold(
        (error) {
          Loggers.database.error('Failed to delete notification: $error');
          // Revert by refreshing
          refreshNotifications();
        },
        (success) {
          Loggers.database.info('Successfully deleted notification');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in deleteNotification: $e');
      // Revert by refreshing
      refreshNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      Loggers.database.info('Marking all notifications as read');

      // Optimistically update all notifications
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.isUnread) {
          return notification.copyWith(
            status: NotificationStatus.read,
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Make API call
      final result = await _repository.markAllAsRead();

      result.fold(
        (error) {
          Loggers.database.error('Failed to mark all notifications as read: $error');
          // Revert by refreshing
          refreshNotifications();
        },
        (success) {
          Loggers.database.info('Successfully marked all notifications as read');
        },
      );
    } catch (e) {
      Loggers.database.error('Exception in markAllAsRead: $e');
      // Revert by refreshing
      refreshNotifications();
    }
  }

  /// Update unread count
  Future<void> _updateUnreadCount() async {
    try {
      final result = await _repository.getUnreadCount();
      result.fold(
        (error) {
          Loggers.database.warning('Failed to update unread count: $error');
        },
        (count) {
          state = state.copyWith(unreadCount: count);
        },
      );
    } catch (e) {
      Loggers.database.warning('Exception in _updateUnreadCount: $e');
    }
  }

  /// Revert notification update (helper method)
  void _revertNotificationUpdate(String notificationId) {
    // This would typically refresh from server or revert to previous state
    // For now, we'll refresh the notifications
    refreshNotifications();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get notification by ID
  NotificationModel? getNotificationById(String id) {
    try {
      return state.notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return state.notifications.where((notification) => notification.isUnread).toList();
  }

  /// Get read notifications
  List<NotificationModel> get readNotifications {
    return state.notifications.where((notification) => notification.isRead).toList();
  }
}

/// Provider for notification repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Provider for notification controller
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationController(repository);
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationControllerProvider);
  return notificationState.unreadCount;
});

/// Provider for filtered notifications
final filteredNotificationsProvider = Provider.family<List<NotificationModel>, NotificationFilter?>((ref, filter) {
  final notificationState = ref.watch(notificationControllerProvider);
  
  if (filter == null || filter.isEmpty) {
    return notificationState.notifications;
  }

  return notificationState.notifications.where((notification) {
    // Category filter
    if (filter.categories?.isNotEmpty ?? false) {
      if (!filter.categories!.contains(notification.category)) {
        return false;
      }
    }

    // Status filter
    if (filter.statuses?.isNotEmpty ?? false) {
      if (!filter.statuses!.contains(notification.status)) {
        return false;
      }
    }

    // Priority filter
    if (filter.priorities?.isNotEmpty ?? false) {
      if (!filter.priorities!.contains(notification.priority)) {
        return false;
      }
    }

    // Date range filter
    if (filter.startDate != null && notification.createdAt.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && notification.createdAt.isAfter(filter.endDate!)) {
      return false;
    }

    // Search query filter
    if (filter.searchQuery?.isNotEmpty ?? false) {
      final query = filter.searchQuery!.toLowerCase();
      if (!notification.title.toLowerCase().contains(query) &&
          !notification.body.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Quick filters
    if (filter.onlyUnread && !notification.isUnread) {
      return false;
    }
    if (filter.onlyHighPriority && !notification.isHighPriority) {
      return false;
    }

    return true;
  }).toList();
});