import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fieldforce/features/notifications/controller/notification_controller.dart';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_filter.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';
import 'package:fieldforce/features/notifications/view/widgets/notification_card.dart';
import 'package:fieldforce/features/notifications/view/widgets/notification_filter_sheet.dart';
import 'package:fieldforce/features/notifications/view/widgets/notification_search_bar.dart';
import 'package:fieldforce/common/widgets/common_widgets.dart';

/// Notification center page - main notifications inbox
class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  NotificationFilter _currentFilter = const NotificationFilter();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load notifications when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).refreshNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more notifications when near bottom
      ref.read(notificationControllerProvider.notifier)
          .loadMoreNotifications(filter: _currentFilter);
    }
  }

  void _onTabChanged() {
    NotificationFilter filter;
    switch (_tabController.index) {
      case 0: // All
        filter = const NotificationFilter();
        break;
      case 1: // Unread
        filter = const NotificationFilter().unreadOnly();
        break;
      case 2: // High Priority
        filter = const NotificationFilter().highPriorityOnly();
        break;
      case 3: // Today
        filter = const NotificationFilter().todayOnly();
        break;
      default:
        filter = const NotificationFilter();
    }
    
    setState(() {
      _currentFilter = filter;
    });
    
    ref.read(notificationControllerProvider.notifier)
        .refreshNotifications(filter: filter);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFilterSheet(
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          ref.read(notificationControllerProvider.notifier)
              .refreshNotifications(filter: filter);
        },
      ),
    );
  }

  void _markAllAsRead() {
    ref.read(notificationControllerProvider.notifier).markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationControllerProvider);
    final filteredNotifications = ref.watch(
      filteredNotificationsProvider(_currentFilter),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          // Filter button
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(
              _currentFilter.hasActiveFilters 
                  ? Symbols.filter_alt 
                  : Symbols.filter_alt_off,
            ),
            tooltip: 'Filter notifications',
          ),
          // Mark all as read button
          if (notificationState.unreadCount > 0)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Symbols.mark_email_read),
              tooltip: 'Mark all as read',
            ),
          // More options menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.pushNamed(context, '/notification-settings');
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Symbols.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Symbols.clear_all),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _onTabChanged(),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.inbox, size: 16),
                  const SizedBox(width: 4),
                  Text('All (${notificationState.notifications.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.mark_email_unread, size: 16),
                  const SizedBox(width: 4),
                  Text('Unread (${notificationState.unreadCount})'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.priority_high, size: 16),
                  SizedBox(width: 4),
                  Text('Priority'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.today, size: 16),
                  SizedBox(width: 4),
                  Text('Today'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: NotificationSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(searchQuery: query);
                });
              },
            ),
          ),
          
          // Active filters indicator
          if (_currentFilter.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Symbols.filter_alt,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentFilter.activeFilterCount} filter(s) active',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentFilter = const NotificationFilter();
                      });
                      ref.read(notificationControllerProvider.notifier)
                          .refreshNotifications();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Notifications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(notificationControllerProvider.notifier)
                  .refreshNotifications(filter: _currentFilter),
              child: _buildNotificationsList(filteredNotifications, notificationState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<NotificationModel> notifications,
    NotificationState state,
  ) {
    if (state.isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationControllerProvider.notifier)
                  .refreshNotifications(filter: _currentFilter),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () => _onNotificationTap(notification),
          onMarkAsRead: () => ref.read(notificationControllerProvider.notifier)
              .markAsRead(notification.id),
          onMarkAsUnread: () => ref.read(notificationControllerProvider.notifier)
              .markAsUnread(notification.id),
          onArchive: () => ref.read(notificationControllerProvider.notifier)
              .archiveNotification(notification.id),
          onDelete: () => ref.read(notificationControllerProvider.notifier)
              .deleteNotification(notification.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (_currentFilter.hasActiveFilters) {
      title = 'No matching notifications';
      subtitle = 'Try adjusting your filters or search terms';
      icon = Symbols.filter_alt_off;
    } else {
      title = 'No notifications yet';
      subtitle = 'You\'ll see your notifications here when you receive them';
      icon = Symbols.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (_currentFilter.hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentFilter = const NotificationFilter();
                });
                ref.read(notificationControllerProvider.notifier)
                    .refreshNotifications();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    // Mark as read if unread
    if (notification.isUnread) {
      ref.read(notificationControllerProvider.notifier)
          .markAsRead(notification.id);
    }

    // Handle notification action
    if (notification.actionUrl != null) {
      // Navigate to specific page based on action URL
      _handleNotificationAction(notification);
    }
  }

  void _handleNotificationAction(NotificationModel notification) {
    // Handle different notification actions
    switch (notification.category) {
      case NotificationCategory.orderUpdate:
        Navigator.pushNamed(context, '/orders');
        break;
      case NotificationCategory.payment:
        Navigator.pushNamed(context, '/wallet');
        break;
      case NotificationCategory.verification:
        Navigator.pushNamed(context, '/profile');
        break;
      case NotificationCategory.company:
        Navigator.pushNamed(context, '/companies');
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Category: ${notification.category.displayName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Priority: ${notification.priority.displayName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Time: ${notification.timeAgo}',
              style: Theme.of(context).textTheme.bodySmall,
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

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear all functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear all functionality coming soon'),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}