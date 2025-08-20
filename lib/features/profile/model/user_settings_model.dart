import 'dart:convert';

/// Model for user settings and preferences
class UserSettingsModel {
  final bool isDarkMode;
  final String language;
  final String currency;
  final String dateFormat;
  final String timeFormat;
  final NotificationSettings notifications;
  final PrivacySettings privacy;

  const UserSettingsModel({
    this.isDarkMode = false,
    this.language = 'en',
    this.currency = 'USD',
    this.dateFormat = 'MM/dd/yyyy',
    this.timeFormat = '12h',
    this.notifications = const NotificationSettings(),
    this.privacy = const PrivacySettings(),
  });

  UserSettingsModel copyWith({
    bool? isDarkMode,
    String? language,
    String? currency,
    String? dateFormat,
    String? timeFormat,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
  }) {
    return UserSettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'currency': currency,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'notifications': notifications.toMap(),
      'privacy': privacy.toMap(),
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      isDarkMode: map['isDarkMode'] ?? false,
      language: map['language'] ?? 'en',
      currency: map['currency'] ?? 'USD',
      dateFormat: map['dateFormat'] ?? 'MM/dd/yyyy',
      timeFormat: map['timeFormat'] ?? '12h',
      notifications: NotificationSettings.fromMap(map['notifications'] ?? {}),
      privacy: PrivacySettings.fromMap(map['privacy'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettingsModel.fromJson(String source) =>
      UserSettingsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserSettingsModel(isDarkMode: $isDarkMode, language: $language, currency: $currency, dateFormat: $dateFormat, timeFormat: $timeFormat, notifications: $notifications, privacy: $privacy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettingsModel &&
        other.isDarkMode == isDarkMode &&
        other.language == language &&
        other.currency == currency &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.notifications == notifications &&
        other.privacy == privacy;
  }

  @override
  int get hashCode {
    return isDarkMode.hashCode ^
        language.hashCode ^
        currency.hashCode ^
        dateFormat.hashCode ^
        timeFormat.hashCode ^
        notifications.hashCode ^
        privacy.hashCode;
  }
}

/// Notification settings model
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool orderUpdates;
  final bool paymentNotifications;
  final bool marketingEmails;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.orderUpdates = true,
    this.paymentNotifications = true,
    this.marketingEmails = false,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? orderUpdates,
    bool? paymentNotifications,
    bool? marketingEmails,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'orderUpdates': orderUpdates,
      'paymentNotifications': paymentNotifications,
      'marketingEmails': marketingEmails,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      orderUpdates: map['orderUpdates'] ?? true,
      paymentNotifications: map['paymentNotifications'] ?? true,
      marketingEmails: map['marketingEmails'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.pushNotifications == pushNotifications &&
        other.emailNotifications == emailNotifications &&
        other.smsNotifications == smsNotifications &&
        other.orderUpdates == orderUpdates &&
        other.paymentNotifications == paymentNotifications &&
        other.marketingEmails == marketingEmails;
  }

  @override
  int get hashCode {
    return pushNotifications.hashCode ^
        emailNotifications.hashCode ^
        smsNotifications.hashCode ^
        orderUpdates.hashCode ^
        paymentNotifications.hashCode ^
        marketingEmails.hashCode;
  }
}

/// Privacy settings model
class PrivacySettings {
  final bool profileVisibility;
  final bool shareDataWithCompanies;
  final bool locationTracking;
  final bool analyticsTracking;

  const PrivacySettings({
    this.profileVisibility = true,
    this.shareDataWithCompanies = true,
    this.locationTracking = false,
    this.analyticsTracking = true,
  });

  PrivacySettings copyWith({
    bool? profileVisibility,
    bool? shareDataWithCompanies,
    bool? locationTracking,
    bool? analyticsTracking,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      shareDataWithCompanies: shareDataWithCompanies ?? this.shareDataWithCompanies,
      locationTracking: locationTracking ?? this.locationTracking,
      analyticsTracking: analyticsTracking ?? this.analyticsTracking,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileVisibility': profileVisibility,
      'shareDataWithCompanies': shareDataWithCompanies,
      'locationTracking': locationTracking,
      'analyticsTracking': analyticsTracking,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      profileVisibility: map['profileVisibility'] ?? true,
      shareDataWithCompanies: map['shareDataWithCompanies'] ?? true,
      locationTracking: map['locationTracking'] ?? false,
      analyticsTracking: map['analyticsTracking'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrivacySettings &&
        other.profileVisibility == profileVisibility &&
        other.shareDataWithCompanies == shareDataWithCompanies &&
        other.locationTracking == locationTracking &&
        other.analyticsTracking == analyticsTracking;
  }

  @override
  int get hashCode {
    return profileVisibility.hashCode ^
        shareDataWithCompanies.hashCode ^
        locationTracking.hashCode ^
        analyticsTracking.hashCode;
  }
}