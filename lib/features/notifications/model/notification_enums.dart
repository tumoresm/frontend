/// Notification category enumeration
enum NotificationCategory {
  orderUpdate('ORDER_UPDATE', 'Order Updates', 'Updates about your orders'),
  payment('PAYMENT', 'Payments', 'Payment and earnings notifications'),
  verification('VERIFICATION', 'Verification', 'Account verification updates'),
  promotion('PROMOTION', 'Promotions', 'Marketing and promotional offers'),
  company('COMPANY', 'Companies', 'Company-related notifications'),
  system('SYSTEM', 'System', 'System and account notifications'),
  security('SECURITY', 'Security', 'Security and login alerts');

  const NotificationCategory(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => NotificationCategory.system,
    );
  }
}

/// Notification priority enumeration
enum NotificationPriority {
  low('LOW', 'Low'),
  normal('NORMAL', 'Normal'),
  high('HIGH', 'High'),
  urgent('URGENT', 'Urgent');

  const NotificationPriority(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

/// Notification status enumeration
enum NotificationStatus {
  unread('UNREAD', 'Unread'),
  read('READ', 'Read'),
  archived('ARCHIVED', 'Archived'),
  deleted('DELETED', 'Deleted');

  const NotificationStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.unread,
    );
  }
}