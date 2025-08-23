import 'dart:convert';

import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Enhanced notification preferences model
class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool inAppNotifications;
  
  // Category-specific preferences
  final bool orderUpdateNotifications;
  final bool paymentNotifications;
  final bool verificationNotifications;
  final bool promotionNotifications;
  final bool companyNotifications;
  final bool systemNotifications;
  final bool securityNotifications;
  
  // Timing preferences
  final bool quietHoursEnabled;
  final int quietHoursStart; // Hour in 24-hour format
  final int quietHoursEnd; // Hour in 24-hour format
  final List<int> allowedDays; // 1-7 (Monday-Sunday)
  
  // Priority preferences
  final bool allowLowPriority;
  final bool allowNormalPriority;
  final bool allowHighPriority;
  final bool allowUrgentPriority;
  
  // Grouping preferences
  final bool groupSimilarNotifications;
  final int maxNotificationsPerHour;
  final bool enableNotificationSummary;

  const NotificationPreferences({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.inAppNotifications = true,
    this.orderUpdateNotifications = true,
    this.paymentNotifications = true,
    this.verificationNotifications = true,
    this.promotionNotifications = false,
    this.companyNotifications = true,
    this.systemNotifications = true,
    this.securityNotifications = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22, // 10 PM
    this.quietHoursEnd = 8, // 8 AM
    this.allowedDays = const [1, 2, 3, 4, 5, 6, 7], // All days
    this.allowLowPriority = true,
    this.allowNormalPriority = true,
    this.allowHighPriority = true,
    this.allowUrgentPriority = true,
    this.groupSimilarNotifications = true,
    this.maxNotificationsPerHour = 10,
    this.enableNotificationSummary = true,
  });

  /// Check if notifications are enabled for a specific category
  bool isCategoryEnabled(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return orderUpdateNotifications;
      case NotificationCategory.payment:
        return paymentNotifications;
      case NotificationCategory.verification:
        return verificationNotifications;
      case NotificationCategory.promotion:
        return promotionNotifications;
      case NotificationCategory.company:
        return companyNotifications;
      case NotificationCategory.system:
        return systemNotifications;
      case NotificationCategory.security:
        return securityNotifications;
    }
  }

  /// Check if notifications are enabled for a specific priority
  bool isPriorityEnabled(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return allowLowPriority;
      case NotificationPriority.normal:
        return allowNormalPriority;
      case NotificationPriority.high:
        return allowHighPriority;
      case NotificationPriority.urgent:
        return allowUrgentPriority;
    }
  }

  /// Check if current time is within quiet hours
  bool get isQuietTime {
    if (!quietHoursEnabled) return false;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;
    
    // Check if current day is allowed
    if (!allowedDays.contains(currentDay)) return true;
    
    // Check quiet hours
    if (quietHoursStart < quietHoursEnd) {
      // Same day quiet hours (e.g., 14:00 - 18:00)
      return currentHour >= quietHoursStart && currentHour < quietHoursEnd;
    } else {
      // Overnight quiet hours (e.g., 22:00 - 08:00)
      return currentHour >= quietHoursStart || currentHour < quietHoursEnd;
    }
  }

  /// Get formatted quiet hours string
  String get quietHoursString {
    if (!quietHoursEnabled) return 'Disabled';
    
    final startTime = '${quietHoursStart.toString().padLeft(2, '0')}:00';
    final endTime = '${quietHoursEnd.toString().padLeft(2, '0')}:00';
    return '$startTime - $endTime';
  }

  NotificationPreferences copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? inAppNotifications,
    bool? orderUpdateNotifications,
    bool? paymentNotifications,
    bool? verificationNotifications,
    bool? promotionNotifications,
    bool? companyNotifications,
    bool? systemNotifications,
    bool? securityNotifications,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    List<int>? allowedDays,
    bool? allowLowPriority,
    bool? allowNormalPriority,
    bool? allowHighPriority,
    bool? allowUrgentPriority,
    bool? groupSimilarNotifications,
    int? maxNotificationsPerHour,
    bool? enableNotificationSummary,
  }) {
    return NotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
      orderUpdateNotifications: orderUpdateNotifications ?? this.orderUpdateNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      verificationNotifications: verificationNotifications ?? this.verificationNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      companyNotifications: companyNotifications ?? this.companyNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      securityNotifications: securityNotifications ?? this.securityNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      allowedDays: allowedDays ?? this.allowedDays,
      allowLowPriority: allowLowPriority ?? this.allowLowPriority,
      allowNormalPriority: allowNormalPriority ?? this.allowNormalPriority,
      allowHighPriority: allowHighPriority ?? this.allowHighPriority,
      allowUrgentPriority: allowUrgentPriority ?? this.allowUrgentPriority,
      groupSimilarNotifications: groupSimilarNotifications ?? this.groupSimilarNotifications,
      maxNotificationsPerHour: maxNotificationsPerHour ?? this.maxNotificationsPerHour,
      enableNotificationSummary: enableNotificationSummary ?? this.enableNotificationSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'inAppNotifications': inAppNotifications,
      'orderUpdateNotifications': orderUpdateNotifications,
      'paymentNotifications': paymentNotifications,
      'verificationNotifications': verificationNotifications,
      'promotionNotifications': promotionNotifications,
      'companyNotifications': companyNotifications,
      'systemNotifications': systemNotifications,
      'securityNotifications': securityNotifications,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'allowedDays': allowedDays,
      'allowLowPriority': allowLowPriority,
      'allowNormalPriority': allowNormalPriority,
      'allowHighPriority': allowHighPriority,
      'allowUrgentPriority': allowUrgentPriority,
      'groupSimilarNotifications': groupSimilarNotifications,
      'maxNotificationsPerHour': maxNotificationsPerHour,
      'enableNotificationSummary': enableNotificationSummary,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      inAppNotifications: map['inAppNotifications'] ?? true,
      orderUpdateNotifications: map['orderUpdateNotifications'] ?? true,
      paymentNotifications: map['paymentNotifications'] ?? true,
      verificationNotifications: map['verificationNotifications'] ?? true,
      promotionNotifications: map['promotionNotifications'] ?? false,
      companyNotifications: map['companyNotifications'] ?? true,
      systemNotifications: map['systemNotifications'] ?? true,
      securityNotifications: map['securityNotifications'] ?? true,
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietHoursStart: map['quietHoursStart'] ?? 22,
      quietHoursEnd: map['quietHoursEnd'] ?? 8,
      allowedDays: List<int>.from(map['allowedDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      allowLowPriority: map['allowLowPriority'] ?? true,
      allowNormalPriority: map['allowNormalPriority'] ?? true,
      allowHighPriority: map['allowHighPriority'] ?? true,
      allowUrgentPriority: map['allowUrgentPriority'] ?? true,
      groupSimilarNotifications: map['groupSimilarNotifications'] ?? true,
      maxNotificationsPerHour: map['maxNotificationsPerHour'] ?? 10,
      enableNotificationSummary: map['enableNotificationSummary'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationPreferences.fromJson(String source) =>
      NotificationPreferences.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NotificationPreferences(pushNotifications: $pushNotifications, emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, inAppNotifications: $inAppNotifications, orderUpdateNotifications: $orderUpdateNotifications, paymentNotifications: $paymentNotifications, verificationNotifications: $verificationNotifications, promotionNotifications: $promotionNotifications, companyNotifications: $companyNotifications, systemNotifications: $systemNotifications, securityNotifications: $securityNotifications, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, allowedDays: $allowedDays, allowLowPriority: $allowLowPriority, allowNormalPriority: $allowNormalPriority, allowHighPriority: $allowHighPriority, allowUrgentPriority: $allowUrgentPriority, groupSimilarNotifications: $groupSimilarNotifications, maxNotificationsPerHour: $maxNotificationsPerHour, enableNotificationSummary: $enableNotificationSummary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationPreferences &&
        other.pushNotifications == pushNotifications &&
        other.emailNotifications == emailNotifications &&
        other.smsNotifications == smsNotifications &&
        other.inAppNotifications == inAppNotifications &&
        other.orderUpdateNotifications == orderUpdateNotifications &&
        other.paymentNotifications == paymentNotifications &&
        other.verificationNotifications == verificationNotifications &&
        other.promotionNotifications == promotionNotifications &&
        other.companyNotifications == companyNotifications &&
        other.systemNotifications == systemNotifications &&
        other.securityNotifications == securityNotifications &&
        other.quietHoursEnabled == quietHoursEnabled &&
        other.quietHoursStart == quietHoursStart &&
        other.quietHoursEnd == quietHoursEnd &&
        other.allowLowPriority == allowLowPriority &&
        other.allowNormalPriority == allowNormalPriority &&
        other.allowHighPriority == allowHighPriority &&
        other.allowUrgentPriority == allowUrgentPriority &&
        other.groupSimilarNotifications == groupSimilarNotifications &&
        other.maxNotificationsPerHour == maxNotificationsPerHour &&
        other.enableNotificationSummary == enableNotificationSummary;
  }

  @override
  int get hashCode {
    return pushNotifications.hashCode ^
        emailNotifications.hashCode ^
        smsNotifications.hashCode ^
        inAppNotifications.hashCode ^
        orderUpdateNotifications.hashCode ^
        paymentNotifications.hashCode ^
        verificationNotifications.hashCode ^
        promotionNotifications.hashCode ^
        companyNotifications.hashCode ^
        systemNotifications.hashCode ^
        securityNotifications.hashCode ^
        quietHoursEnabled.hashCode ^
        quietHoursStart.hashCode ^
        quietHoursEnd.hashCode ^
        allowLowPriority.hashCode ^
        allowNormalPriority.hashCode ^
        allowHighPriority.hashCode ^
        allowUrgentPriority.hashCode ^
        groupSimilarNotifications.hashCode ^
        maxNotificationsPerHour.hashCode ^
        enableNotificationSummary.hashCode;
  }
}