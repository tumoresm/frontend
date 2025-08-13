import 'dart:convert';
import 'package:fieldforce/core/base_model.dart';
import 'package:fieldforce/features/wallet/model/wallet_enums.dart';

/// Model representing a financial transaction in the wallet system
class TransactionModel extends BaseModel {
  /// The ID of the user who owns this transaction
  final String userId;
  
  /// Type of transaction (earning, payment, withdrawal, etc.)
  final TransactionType type;
  
  /// Amount of the transaction (positive for credits, negative for debits)
  final double amount;
  
  /// Description of the transaction
  final String description;
  
  /// Optional order ID if this transaction is related to an order
  final String? orderId;
  
  /// Current status of the transaction
  final TransactionStatus status;
  
  /// Optional reference number for tracking
  final String? referenceNumber;
  
  /// Optional bank account ID if related to a withdrawal/payment
  final String? bankAccountId;
  
  /// When the transaction was created
  final DateTime createdAt;
  
  /// When the transaction was processed (if applicable)
  final DateTime? processedAt;
  
  /// Additional metadata as JSON
  final Map<String, dynamic>? metadata;

  const TransactionModel({
    required super.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.orderId,
    required this.status,
    this.referenceNumber,
    this.bankAccountId,
    required this.createdAt,
    this.processedAt,
    this.metadata,
  });

  /// Check if this is a credit transaction (adds money to wallet)
  bool get isCredit => amount > 0;

  /// Check if this is a debit transaction (removes money from wallet)
  bool get isDebit => amount < 0;

  /// Get absolute amount for display purposes
  double get absoluteAmount => amount.abs();

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? description,
    String? orderId,
    TransactionStatus? status,
    String? referenceNumber,
    String? bankAccountId,
    DateTime? createdAt,
    DateTime? processedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'amount': amount,
      'description': description,
      'orderId': orderId,
      'status': status.value,
      'referenceNumber': referenceNumber,
      'bankAccountId': bankAccountId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'processedAt': processedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['userId']?.toString() ?? '',
      type: map['type'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.value == map['type'],
              orElse: () => TransactionType.earning,
            )
          : TransactionType.earning,
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : 0.0,
      description: map['description']?.toString() ?? '',
      orderId: map['orderId']?.toString(),
      status: map['status'] != null
          ? TransactionStatus.values.firstWhere(
              (e) => e.value == map['status'],
              orElse: () => TransactionStatus.pending,
            )
          : TransactionStatus.pending,
      referenceNumber: map['referenceNumber']?.toString(),
      bankAccountId: map['bankAccountId']?.toString(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      processedAt: _parseDateTime(map['processedAt']),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
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

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, type: $type, amount: $amount, description: $description, orderId: $orderId, status: $status, referenceNumber: $referenceNumber, bankAccountId: $bankAccountId, createdAt: $createdAt, processedAt: $processedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(covariant TransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.amount == amount &&
        other.description == description &&
        other.orderId == orderId &&
        other.status == status &&
        other.referenceNumber == referenceNumber &&
        other.bankAccountId == bankAccountId &&
        other.createdAt == createdAt &&
        other.processedAt == processedAt &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        type.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        orderId.hashCode ^
        status.hashCode ^
        referenceNumber.hashCode ^
        bankAccountId.hashCode ^
        createdAt.hashCode ^
        processedAt.hashCode ^
        metadata.hashCode;
  }
}