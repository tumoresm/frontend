import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Widget for displaying a single notification in a card format
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onMarkAsUnread;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onMarkAsUnread,
    this.onArchive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isUnread ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: notification.isUnread
                ? Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with category icon, title, and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon with priority indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      size: 20,
                      color: _getCategoryColor(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: notification.isUnread 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Priority indicator
                            if (notification.isHighPriority)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  notification.priority.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Time and category
                        Row(
                          children: [
                            Text(
                              notification.timeAgo,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.outline,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notification.category.displayName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: _handleAction,
                    icon: Icon(
                      Symbols.more_vert,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    itemBuilder: (context) => [
                      if (notification.isUnread)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: ListTile(
                            leading: Icon(Symbols.mark_email_read),
                            title: Text('Mark as read'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: 'mark_unread',
                          child: ListTile(
                            leading: Icon(Symbols.mark_email_unread),
                            title: Text('Mark as unread'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'archive',
                        child: ListTile(
                          leading: Icon(Symbols.archive),
                          title: Text('Archive'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Symbols.delete),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Notification body
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: notification.isUnread
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).colorScheme.outline,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Image if available
              if (notification.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    notification.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Symbols.broken_image),
                    ),
                  ),
                ),
              ],
              
              // Action button if available
              if (notification.actionUrl != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: Icon(_getActionIcon()),
                    label: Text(_getActionText()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'mark_read':
        onMarkAsRead?.call();
        break;
      case 'mark_unread':
        onMarkAsUnread?.call();
        break;
      case 'archive':
        onArchive?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  IconData _getCategoryIcon() {
    switch (notification.category) {
      case NotificationCategory.orderUpdate:
        return Symbols.shopping_cart;
      case NotificationCategory.payment:
        return Symbols.payments;
      case NotificationCategory.verification:
        return Symbols.verified_user;
      case NotificationCategory.promotion:
        return Symbols.local_offer;
      case NotificationCategory.company:
        return Symbols.business;
      case NotificationCategory.system:
        return Symbols.settings;
      case NotificationCategory.security:
        return Symbols.security;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    switch (notification.category) {
      case NotificationCategory.orderUpdate:
        return Colors.blue;
      case NotificationCategory.payment:
        return Colors.green;
      case NotificationCategory.verification:
        return Colors.orange;
      case NotificationCategory.promotion:
        return Colors.purple;
      case NotificationCategory.company:
        return Colors.indigo;
      case NotificationCategory.system:
        return Colors.grey;
      case NotificationCategory.security:
        return Colors.red;
    }
  }

  Color _getPriorityColor(BuildContext context) {
    switch (notification.priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getActionIcon() {
    switch (notification.category) {
      case NotificationCategory.orderUpdate:
        return Symbols.visibility;
      case NotificationCategory.payment:
        return Symbols.account_balance_wallet;
      case NotificationCategory.verification:
        return Symbols.person;
      case NotificationCategory.company:
        return Symbols.business;
      default:
        return Symbols.open_in_new;
    }
  }

  String _getActionText() {
    switch (notification.category) {
      case NotificationCategory.orderUpdate:
        return 'View Order';
      case NotificationCategory.payment:
        return 'View Wallet';
      case NotificationCategory.verification:
        return 'View Profile';
      case NotificationCategory.company:
        return 'View Company';
      default:
        return 'View Details';
    }
  }
}