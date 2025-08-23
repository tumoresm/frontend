import 'dart:math';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Mock service for generating sample notifications for testing
class MockNotificationService {
  static final Random _random = Random();

  /// Generate mock notifications for testing
  static List<NotificationModel> generateMockNotifications({int count = 20}) {
    final notifications = <NotificationModel>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final category = NotificationCategory.values[_random.nextInt(NotificationCategory.values.length)];
      final priority = NotificationPriority.values[_random.nextInt(NotificationPriority.values.length)];
      final status = _random.nextBool() ? NotificationStatus.unread : NotificationStatus.read;
      final createdAt = now.subtract(Duration(
        hours: _random.nextInt(72),
        minutes: _random.nextInt(60),
      ));

      notifications.add(NotificationModel(
        id: 'mock_${i}_${DateTime.now().millisecondsSinceEpoch}',
        title: _generateTitle(category),
        body: _generateBody(category),
        category: category,
        priority: priority,
        status: status,
        createdAt: createdAt,
        readAt: status == NotificationStatus.read ? createdAt.add(Duration(minutes: _random.nextInt(30))) : null,
        userId: 'current_user',
        actionUrl: _generateActionUrl(category),
        actionType: _generateActionType(category),
        data: _generateData(category),
      ));
    }

    // Sort by creation date (newest first)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  static String _generateTitle(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return [
          'Order #12345 has been approved',
          'New order requires your attention',
          'Order #67890 has been delivered',
          'Order payment processed successfully',
          'Order #54321 has been cancelled',
        ][_random.nextInt(5)];

      case NotificationCategory.payment:
        return [
          'Payment of \$250.00 received',
          'Withdrawal request approved',
          'Commission earned: \$75.50',
          'Monthly earnings summary available',
          'Payment method updated',
        ][_random.nextInt(5)];

      case NotificationCategory.verification:
        return [
          'Account verification completed',
          'Additional documents required',
          'Profile verification in progress',
          'ID verification approved',
          'Verification status updated',
        ][_random.nextInt(5)];

      case NotificationCategory.promotion:
        return [
          'Special offer: 20% bonus commission',
          'New product launch announcement',
          'Limited time promotion available',
          'Exclusive deal for top performers',
          'Holiday bonus program active',
        ][_random.nextInt(5)];

      case NotificationCategory.company:
        return [
          'New company partnership available',
          'TechCorp updated their product catalog',
          'Company rating improved',
          'New territory opened for sales',
          'Company policy update',
        ][_random.nextInt(5)];

      case NotificationCategory.system:
        return [
          'App update available',
          'Scheduled maintenance tonight',
          'New features released',
          'System performance improved',
          'Terms of service updated',
        ][_random.nextInt(5)];

      case NotificationCategory.security:
        return [
          'New login detected',
          'Password changed successfully',
          'Suspicious activity detected',
          'Two-factor authentication enabled',
          'Security settings updated',
        ][_random.nextInt(5)];
    }
  }

  static String _generateBody(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return [
          'Your order has been processed and is now ready for delivery. Track your order status in the orders section.',
          'A new order has been assigned to you. Please review the details and confirm your availability.',
          'The customer has confirmed receipt of the order. Your commission will be processed within 24 hours.',
          'Payment for order #12345 has been successfully processed. Check your wallet for updated balance.',
          'The order has been cancelled by the customer. Please contact support if you have any questions.',
        ][_random.nextInt(5)];

      case NotificationCategory.payment:
        return [
          'A payment of \$250.00 has been credited to your account. Your new balance is \$1,250.00.',
          'Your withdrawal request for \$500.00 has been approved and will be processed within 2-3 business days.',
          'You earned a commission of \$75.50 from your recent sales. Keep up the great work!',
          'Your monthly earnings summary is now available. You earned \$2,150.00 this month.',
          'Your payment method has been successfully updated. All future payments will use the new method.',
        ][_random.nextInt(5)];

      case NotificationCategory.verification:
        return [
          'Congratulations! Your account verification has been completed successfully. You now have full access to all features.',
          'We need additional documents to complete your verification. Please upload the required documents in your profile.',
          'Your profile verification is currently in progress. We\'ll notify you once it\'s complete.',
          'Your ID verification has been approved. You can now access premium features.',
          'Your verification status has been updated. Check your profile for more details.',
        ][_random.nextInt(5)];

      case NotificationCategory.promotion:
        return [
          'For a limited time, earn 20% bonus commission on all sales. This offer expires in 7 days.',
          'We\'re excited to announce the launch of our new product line. Start selling today!',
          'A special promotion is now available for top performers. Check your dashboard for details.',
          'You\'ve qualified for our exclusive deal program. Enjoy special pricing and bonuses.',
          'Our holiday bonus program is now active. Earn extra rewards for every sale this month.',
        ][_random.nextInt(5)];

      case NotificationCategory.company:
        return [
          'A new company partnership is available in your area. Explore new opportunities to grow your business.',
          'TechCorp has updated their product catalog with new items. Check out the latest offerings.',
          'The company rating has improved based on recent customer feedback. Great job!',
          'A new sales territory has opened up. You can now sell in additional locations.',
          'Important company policy updates have been made. Please review the changes in your dashboard.',
        ][_random.nextInt(5)];

      case NotificationCategory.system:
        return [
          'A new app update is available with improved features and bug fixes. Update now for the best experience.',
          'Scheduled maintenance will occur tonight from 2:00 AM to 4:00 AM. Some features may be temporarily unavailable.',
          'We\'ve released new features to improve your selling experience. Check out what\'s new!',
          'System performance has been improved for faster loading and better reliability.',
          'Our terms of service have been updated. Please review the changes at your convenience.',
        ][_random.nextInt(5)];

      case NotificationCategory.security:
        return [
          'A new login was detected from a different device. If this wasn\'t you, please secure your account immediately.',
          'Your password has been changed successfully. If you didn\'t make this change, contact support.',
          'Suspicious activity was detected on your account. Please review your recent activity and contact support if needed.',
          'Two-factor authentication has been enabled for your account. Your account is now more secure.',
          'Your security settings have been updated successfully. Your account security has been improved.',
        ][_random.nextInt(5)];
    }
  }

  static String? _generateActionUrl(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return '/orders';
      case NotificationCategory.payment:
        return '/wallet';
      case NotificationCategory.verification:
        return '/profile';
      case NotificationCategory.company:
        return '/companies';
      default:
        return null;
    }
  }

  static String? _generateActionType(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return 'OPEN_ORDER';
      case NotificationCategory.payment:
        return 'OPEN_WALLET';
      case NotificationCategory.verification:
        return 'OPEN_PROFILE';
      case NotificationCategory.company:
        return 'OPEN_COMPANY';
      default:
        return 'NONE';
    }
  }

  static Map<String, dynamic>? _generateData(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return {
          'orderId': 'ORD_${_random.nextInt(99999)}',
          'amount': (_random.nextDouble() * 1000).toStringAsFixed(2),
          'status': ['pending', 'approved', 'delivered', 'cancelled'][_random.nextInt(4)],
        };
      case NotificationCategory.payment:
        return {
          'amount': (_random.nextDouble() * 500).toStringAsFixed(2),
          'type': ['commission', 'withdrawal', 'bonus'][_random.nextInt(3)],
          'transactionId': 'TXN_${_random.nextInt(99999)}',
        };
      case NotificationCategory.company:
        return {
          'companyId': 'COMP_${_random.nextInt(999)}',
          'companyName': ['TechCorp', 'InnovateCo', 'FutureTech', 'GlobalSales'][_random.nextInt(4)],
        };
      default:
        return null;
    }
  }
}