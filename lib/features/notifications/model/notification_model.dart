import 'dart:convert';

import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Notification model representing a single notification
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionType;
  final String userId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.readAt,
    this.imageUrl,
    this.data,
    this.actionUrl,
    this.actionType,
  });

  /// Check if notification is unread
  bool get isUnread => status == NotificationStatus.unread;

  /// Check if notification is read
  bool get isRead => status == NotificationStatus.read;

  /// Check if notification is archived
  bool get isArchived => status == NotificationStatus.archived;

  /// Check if notification is high priority
  bool get isHighPriority => 
      priority == NotificationPriority.high || 
      priority == NotificationPriority.urgent;

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionType,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.value,
      'priority': priority.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'data': data,
      'actionUrl': actionUrl,
      'actionType': actionType,
      'userId': userId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: NotificationCategory.fromString(map['category'] ?? 'SYSTEM'),
      priority: NotificationPriority.fromString(map['priority'] ?? 'NORMAL'),
      status: NotificationStatus.fromString(map['status'] ?? 'UNREAD'),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      imageUrl: map['imageUrl'],
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
      actionUrl: map['actionUrl'],
      actionType: map['actionType'],
      userId: map['userId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, category: $category, priority: $priority, status: $status, createdAt: $createdAt, readAt: $readAt, imageUrl: $imageUrl, data: $data, actionUrl: $actionUrl, actionType: $actionType, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.category == category &&
        other.priority == priority &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.readAt == readAt &&
        other.imageUrl == imageUrl &&
        other.actionUrl == actionUrl &&
        other.actionType == actionType &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        readAt.hashCode ^
        imageUrl.hashCode ^
        actionUrl.hashCode ^
        actionType.hashCode ^
        userId.hashCode;
  }
}