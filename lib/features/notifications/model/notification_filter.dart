import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Notification filter model for filtering notifications
class NotificationFilter {
  final List<NotificationCategory>? categories;
  final List<NotificationStatus>? statuses;
  final List<NotificationPriority>? priorities;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final bool onlyUnread;
  final bool onlyHighPriority;

  const NotificationFilter({
    this.categories,
    this.statuses,
    this.priorities,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.onlyUnread = false,
    this.onlyHighPriority = false,
  });

  /// Check if filter is empty (no filters applied)
  bool get isEmpty {
    return (categories?.isEmpty ?? true) &&
        (statuses?.isEmpty ?? true) &&
        (priorities?.isEmpty ?? true) &&
        startDate == null &&
        endDate == null &&
        (searchQuery?.isEmpty ?? true) &&
        !onlyUnread &&
        !onlyHighPriority;
  }

  /// Check if filter has any active filters
  bool get hasActiveFilters => !isEmpty;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (categories?.isNotEmpty ?? false) count++;
    if (statuses?.isNotEmpty ?? false) count++;
    if (priorities?.isNotEmpty ?? false) count++;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (searchQuery?.isNotEmpty ?? false) count++;
    if (onlyUnread) count++;
    if (onlyHighPriority) count++;
    return count;
  }

  NotificationFilter copyWith({
    List<NotificationCategory>? categories,
    List<NotificationStatus>? statuses,
    List<NotificationPriority>? priorities,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool? onlyUnread,
    bool? onlyHighPriority,
  }) {
    return NotificationFilter(
      categories: categories ?? this.categories,
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyUnread: onlyUnread ?? this.onlyUnread,
      onlyHighPriority: onlyHighPriority ?? this.onlyHighPriority,
    );
  }

  /// Clear all filters
  NotificationFilter clear() {
    return const NotificationFilter();
  }

  /// Apply quick filter for unread notifications
  NotificationFilter unreadOnly() {
    return copyWith(
      onlyUnread: true,
      statuses: [NotificationStatus.unread],
    );
  }

  /// Apply quick filter for high priority notifications
  NotificationFilter highPriorityOnly() {
    return copyWith(
      onlyHighPriority: true,
      priorities: [NotificationPriority.high, NotificationPriority.urgent],
    );
  }

  /// Apply quick filter for today's notifications
  NotificationFilter todayOnly() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return copyWith(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Apply quick filter for this week's notifications
  NotificationFilter thisWeekOnly() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return copyWith(
      startDate: startOfDay,
      endDate: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categories': categories?.map((x) => x.value).toList(),
      'statuses': statuses?.map((x) => x.value).toList(),
      'priorities': priorities?.map((x) => x.value).toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'searchQuery': searchQuery,
      'onlyUnread': onlyUnread,
      'onlyHighPriority': onlyHighPriority,
    };
  }

  factory NotificationFilter.fromMap(Map<String, dynamic> map) {
    return NotificationFilter(
      categories: map['categories'] != null
          ? List<NotificationCategory>.from(
              map['categories']?.map((x) => NotificationCategory.fromString(x)))
          : null,
      statuses: map['statuses'] != null
          ? List<NotificationStatus>.from(
              map['statuses']?.map((x) => NotificationStatus.fromString(x)))
          : null,
      priorities: map['priorities'] != null
          ? List<NotificationPriority>.from(
              map['priorities']?.map((x) => NotificationPriority.fromString(x)))
          : null,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      searchQuery: map['searchQuery'],
      onlyUnread: map['onlyUnread'] ?? false,
      onlyHighPriority: map['onlyHighPriority'] ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationFilter(categories: $categories, statuses: $statuses, priorities: $priorities, startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery, onlyUnread: $onlyUnread, onlyHighPriority: $onlyHighPriority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationFilter &&
        other.categories == categories &&
        other.statuses == statuses &&
        other.priorities == priorities &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.searchQuery == searchQuery &&
        other.onlyUnread == onlyUnread &&
        other.onlyHighPriority == onlyHighPriority;
  }

  @override
  int get hashCode {
    return categories.hashCode ^
        statuses.hashCode ^
        priorities.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        searchQuery.hashCode ^
        onlyUnread.hashCode ^
        onlyHighPriority.hashCode;
  }
}