import 'dart:convert';
import 'package:fieldforce/core/base_model.dart';
import 'package:fieldforce/features/wallet/model/wallet_enums.dart';

/// Model representing a withdrawal request from the wallet
class WithdrawalRequestModel extends BaseModel {
  /// The ID of the user requesting the withdrawal
  final String userId;
  
  /// Amount to be withdrawn
  final double amount;
  
  /// ID of the bank account to receive the withdrawal
  final String bankAccountId;
  
  /// Current status of the withdrawal request
  final WithdrawalStatus status;
  
  /// When the withdrawal was requested
  final DateTime requestedAt;
  
  /// When the withdrawal was processed (if applicable)
  final DateTime? processedAt;
  
  /// Reason for failure or rejection (if applicable)
  final String? failureReason;
  
  /// Reference number for tracking the withdrawal
  final String? referenceNumber;
  
  /// Processing fee charged for the withdrawal
  final double? processingFee;
  
  /// Net amount after fees
  final double? netAmount;
  
  /// ID of the admin who approved/rejected the request
  final String? processedBy;
  
  /// Additional notes from admin or system
  final String? notes;
  
  /// Expected completion date
  final DateTime? expectedCompletionDate;

  const WithdrawalRequestModel({
    required super.id,
    required this.userId,
    required this.amount,
    required this.bankAccountId,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.failureReason,
    this.referenceNumber,
    this.processingFee,
    this.netAmount,
    this.processedBy,
    this.notes,
    this.expectedCompletionDate,
  });

  /// Calculate net amount if not provided
  double get calculatedNetAmount {
    if (netAmount != null) return netAmount!;
    return amount - (processingFee ?? 0.0);
  }

  /// Check if the withdrawal is in a final state
  bool get isFinal {
    return status == WithdrawalStatus.completed ||
           status == WithdrawalStatus.failed ||
           status == WithdrawalStatus.cancelled ||
           status == WithdrawalStatus.rejected;
  }

  /// Check if the withdrawal can be cancelled
  bool get canBeCancelled {
    return status == WithdrawalStatus.pending ||
           status == WithdrawalStatus.approved;
  }

  WithdrawalRequestModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? bankAccountId,
    WithdrawalStatus? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? failureReason,
    String? referenceNumber,
    double? processingFee,
    double? netAmount,
    String? processedBy,
    String? notes,
    DateTime? expectedCompletionDate,
  }) {
    return WithdrawalRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      failureReason: failureReason ?? this.failureReason,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      processingFee: processingFee ?? this.processingFee,
      netAmount: netAmount ?? this.netAmount,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'bankAccountId': bankAccountId,
      'status': status.value,
      'requestedAt': requestedAt.millisecondsSinceEpoch,
      'processedAt': processedAt?.millisecondsSinceEpoch,
      'failureReason': failureReason,
      'referenceNumber': referenceNumber,
      'processingFee': processingFee,
      'netAmount': netAmount,
      'processedBy': processedBy,
      'notes': notes,
      'expectedCompletionDate': expectedCompletionDate?.millisecondsSinceEpoch,
    };
  }

  factory WithdrawalRequestModel.fromMap(Map<String, dynamic> map) {
    return WithdrawalRequestModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['userId']?.toString() ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : 0.0,
      bankAccountId: map['bankAccountId']?.toString() ?? '',
      status: map['status'] != null
          ? WithdrawalStatus.values.firstWhere(
              (e) => e.value == map['status'],
              orElse: () => WithdrawalStatus.pending,
            )
          : WithdrawalStatus.pending,
      requestedAt: _parseDateTime(map['requestedAt']) ?? DateTime.now(),
      processedAt: _parseDateTime(map['processedAt']),
      failureReason: map['failureReason']?.toString(),
      referenceNumber: map['referenceNumber']?.toString(),
      processingFee: map['processingFee'] != null
          ? (map['processingFee'] as num).toDouble()
          : null,
      netAmount: map['netAmount'] != null
          ? (map['netAmount'] as num).toDouble()
          : null,
      processedBy: map['processedBy']?.toString(),
      notes: map['notes']?.toString(),
      expectedCompletionDate: _parseDateTime(map['expectedCompletionDate']),
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

  factory WithdrawalRequestModel.fromJson(String source) =>
      WithdrawalRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WithdrawalRequestModel(id: $id, userId: $userId, amount: $amount, bankAccountId: $bankAccountId, status: $status, requestedAt: $requestedAt, processedAt: $processedAt)';
  }

  @override
  bool operator ==(covariant WithdrawalRequestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.bankAccountId == bankAccountId &&
        other.status == status &&
        other.requestedAt == requestedAt &&
        other.processedAt == processedAt &&
        other.failureReason == failureReason &&
        other.referenceNumber == referenceNumber &&
        other.processingFee == processingFee &&
        other.netAmount == netAmount &&
        other.processedBy == processedBy &&
        other.notes == notes &&
        other.expectedCompletionDate == expectedCompletionDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        amount.hashCode ^
        bankAccountId.hashCode ^
        status.hashCode ^
        requestedAt.hashCode ^
        processedAt.hashCode ^
        failureReason.hashCode ^
        referenceNumber.hashCode ^
        processingFee.hashCode ^
        netAmount.hashCode ^
        processedBy.hashCode ^
        notes.hashCode ^
        expectedCompletionDate.hashCode;
  }
}