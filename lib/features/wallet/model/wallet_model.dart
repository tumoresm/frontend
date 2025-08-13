import 'dart:convert';
import 'package:fieldforce/core/base_model.dart';

/// Model representing a user's wallet with balance and earnings information
class WalletModel extends BaseModel {
  /// The ID of the user who owns this wallet
  final String userId;
  
  /// Current available balance that can be withdrawn
  final double currentBalance;
  
  /// Total earnings accumulated over time
  final double totalEarnings;
  
  /// Earnings that are pending and not yet available for withdrawal
  final double pendingEarnings;
  
  /// Amount currently reserved for processing withdrawals
  final double reservedAmount;
  
  /// When the wallet was last updated
  final DateTime lastUpdated;
  
  /// When the wallet was created
  final DateTime createdAt;

  const WalletModel({
    required super.id,
    required this.userId,
    required this.currentBalance,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.reservedAmount,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Calculate the total balance (current + pending)
  double get totalBalance => currentBalance + pendingEarnings;

  /// Calculate available balance for withdrawal (current - reserved)
  double get availableBalance => currentBalance - reservedAmount;

  WalletModel copyWith({
    String? id,
    String? userId,
    double? currentBalance,
    double? totalEarnings,
    double? pendingEarnings,
    double? reservedAmount,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentBalance: currentBalance ?? this.currentBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      reservedAmount: reservedAmount ?? this.reservedAmount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'currentBalance': currentBalance,
      'totalEarnings': totalEarnings,
      'pendingEarnings': pendingEarnings,
      'reservedAmount': reservedAmount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['userId']?.toString() ?? '',
      currentBalance: (map['currentBalance'] is num)
          ? (map['currentBalance'] as num).toDouble()
          : 0.0,
      totalEarnings: (map['totalEarnings'] is num)
          ? (map['totalEarnings'] as num).toDouble()
          : 0.0,
      pendingEarnings: (map['pendingEarnings'] is num)
          ? (map['pendingEarnings'] as num).toDouble()
          : 0.0,
      reservedAmount: (map['reservedAmount'] is num)
          ? (map['reservedAmount'] as num).toDouble()
          : 0.0,
      lastUpdated: _parseDateTime(map['lastUpdated']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  /// Helper method to safely parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    
    if (dateTime is DateTime) return dateTime;
    
    if (dateTime is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } catch (e) {
        return null;
      }
    }
    
    if (dateTime is String) {
      try {
        final intValue = int.tryParse(dateTime);
        if (intValue != null) {
          return DateTime.fromMillisecondsSinceEpoch(intValue);
        }
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  String toJson() => json.encode(toMap());

  factory WalletModel.fromJson(String source) =>
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletModel(id: $id, userId: $userId, currentBalance: $currentBalance, totalEarnings: $totalEarnings, pendingEarnings: $pendingEarnings, reservedAmount: $reservedAmount, lastUpdated: $lastUpdated, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant WalletModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.currentBalance == currentBalance &&
        other.totalEarnings == totalEarnings &&
        other.pendingEarnings == pendingEarnings &&
        other.reservedAmount == reservedAmount &&
        other.lastUpdated == lastUpdated &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        currentBalance.hashCode ^
        totalEarnings.hashCode ^
        pendingEarnings.hashCode ^
        reservedAmount.hashCode ^
        lastUpdated.hashCode ^
        createdAt.hashCode;
  }
}