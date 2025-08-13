import 'dart:convert';
import 'package:fieldforce/core/base_model.dart';

/// Model representing a user's bank account for withdrawals
class BankAccountModel extends BaseModel {
  /// The ID of the user who owns this bank account
  final String userId;
  
  /// Name on the bank account
  final String accountName;
  
  /// Bank account number
  final String accountNumber;
  
  /// Name of the bank
  final String bankName;
  
  /// Bank routing number (optional, depends on country/bank)
  final String? routingNumber;
  
  /// Bank code or sort code (optional, depends on country)
  final String? bankCode;
  
  /// IBAN for international accounts (optional)
  final String? iban;
  
  /// SWIFT code for international transfers (optional)
  final String? swiftCode;
  
  /// Whether this is the default account for withdrawals
  final bool isDefault;
  
  /// Whether this account has been verified
  final bool isVerified;
  
  /// Country code for the bank account
  final String? countryCode;
  
  /// Currency code for the account
  final String? currencyCode;
  
  /// When the account was created
  final DateTime createdAt;
  
  /// When the account was last updated
  final DateTime updatedAt;
  
  /// When the account was verified (if applicable)
  final DateTime? verifiedAt;

  const BankAccountModel({
    required super.id,
    required this.userId,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    this.routingNumber,
    this.bankCode,
    this.iban,
    this.swiftCode,
    required this.isDefault,
    required this.isVerified,
    this.countryCode,
    this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedAt,
  });

  /// Get masked account number for display (shows only last 4 digits)
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '*' * (accountNumber.length - 4) + accountNumber.substring(accountNumber.length - 4);
  }

  /// Get display name for the account
  String get displayName => '$bankName - $maskedAccountNumber';

  BankAccountModel copyWith({
    String? id,
    String? userId,
    String? accountName,
    String? accountNumber,
    String? bankName,
    String? routingNumber,
    String? bankCode,
    String? iban,
    String? swiftCode,
    bool? isDefault,
    bool? isVerified,
    String? countryCode,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      routingNumber: routingNumber ?? this.routingNumber,
      bankCode: bankCode ?? this.bankCode,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'routingNumber': routingNumber,
      'bankCode': bankCode,
      'iban': iban,
      'swiftCode': swiftCode,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userId: map['userId']?.toString() ?? '',
      accountName: map['accountName']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      bankName: map['bankName']?.toString() ?? '',
      routingNumber: map['routingNumber']?.toString(),
      bankCode: map['bankCode']?.toString(),
      iban: map['iban']?.toString(),
      swiftCode: map['swiftCode']?.toString(),
      isDefault: map['isDefault'] == true,
      isVerified: map['isVerified'] == true,
      countryCode: map['countryCode']?.toString(),
      currencyCode: map['currencyCode']?.toString(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      verifiedAt: _parseDateTime(map['verifiedAt']),
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

  factory BankAccountModel.fromJson(String source) =>
      BankAccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BankAccountModel(id: $id, userId: $userId, accountName: $accountName, accountNumber: $maskedAccountNumber, bankName: $bankName, isDefault: $isDefault, isVerified: $isVerified, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant BankAccountModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.accountName == accountName &&
        other.accountNumber == accountNumber &&
        other.bankName == bankName &&
        other.routingNumber == routingNumber &&
        other.bankCode == bankCode &&
        other.iban == iban &&
        other.swiftCode == swiftCode &&
        other.isDefault == isDefault &&
        other.isVerified == isVerified &&
        other.countryCode == countryCode &&
        other.currencyCode == currencyCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.verifiedAt == verifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        accountName.hashCode ^
        accountNumber.hashCode ^
        bankName.hashCode ^
        routingNumber.hashCode ^
        bankCode.hashCode ^
        iban.hashCode ^
        swiftCode.hashCode ^
        isDefault.hashCode ^
        isVerified.hashCode ^
        countryCode.hashCode ^
        currencyCode.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        verifiedAt.hashCode;
  }
}