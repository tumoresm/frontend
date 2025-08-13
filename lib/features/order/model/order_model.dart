// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fieldforce/core/base_model.dart';

enum OrderStatus {
  pending,
  approved,
  paid,
  delivered,
  rejected,
  cancelled,
}

class OrderModel extends BaseModel {
  /// The unique identifier of the user (sales representative) who created the order.
  /// This corresponds to the `id` field in the `UserModel`.
  final String repId;
  final String companyId;
  final String productId;
  final String? addons;
  final String? accessories;
  final double invoiceTotal;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String customerAddress;
  final Map<String, dynamic> customerLocation;
  final OrderStatus orderStatus;
  final String? statusReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.repId,
    required this.companyId,
    required this.productId,
    this.addons,
    this.accessories,
    required this.invoiceTotal,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.customerAddress,
    required this.customerLocation,
    required this.orderStatus,
    this.statusReason,
    required this.createdAt,
    required this.updatedAt,
    required super.id,
  });

  OrderModel copyWith({
    String? id,
    String? repId,
    String? companyId,
    String? productId,
    String? addons,
    String? accessories,
    double? invoiceTotal,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    Map<String, dynamic>? customerLocation,
    OrderStatus? orderStatus,
    String? statusReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      OrderModel(
        id: id ?? this.id,
        repId: repId ?? this.repId,
        companyId: companyId ?? this.companyId,
        productId: productId ?? this.productId,
        addons: addons ?? this.addons,
        accessories: accessories ?? this.accessories,
        invoiceTotal: invoiceTotal ?? this.invoiceTotal,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        customerEmail: customerEmail ?? this.customerEmail,
        customerAddress: customerAddress ?? this.customerAddress,
        customerLocation: customerLocation ?? this.customerLocation,
        orderStatus: orderStatus ?? this.orderStatus,
        statusReason: statusReason ?? this.statusReason,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'repId': repId,
        'companyId': companyId,
        'productId': productId,
        'addons': addons,
        'accessories': accessories,
        'invoiceTotal': invoiceTotal,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
        'customerAddress': customerAddress,
        'customerLocation': customerLocation,
        'orderStatus':
            orderStatus.toString().split('.').last, // Convert enum to string
        'statusReason': statusReason,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  /// Helper method to safely parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) {
      return null;
    }
    
    // If it's already a DateTime, return it
    if (dateTime is DateTime) {
      return dateTime;
    }
    
    // If it's an int (milliseconds since epoch), parse it
    if (dateTime is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } catch (e) {
        return null;
      }
    }
    
    // If it's a string, try to parse it as int first, then as ISO string
    if (dateTime is String) {
      try {
        // Try parsing as int (milliseconds)
        final intValue = int.tryParse(dateTime);
        if (intValue != null) {
          return DateTime.fromMillisecondsSinceEpoch(intValue);
        }
        
        // Try parsing as ISO string
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// Helper method to safely parse customerLocation from various formats
  static Map<String, dynamic> _parseCustomerLocation(dynamic location) {
    if (location == null) {
      return <String, dynamic>{};
    }
    
    // If it's already a Map, return it
    if (location is Map<String, dynamic>) {
      return location;
    }
    
    // If it's a Map with different generic types, convert it
    if (location is Map) {
      return Map<String, dynamic>.from(location);
    }
    
    // If it's a JSON string, try to parse it
    if (location is String) {
      try {
        final parsed = json.decode(location);
        if (parsed is Map) {
          return Map<String, dynamic>.from(parsed);
        }
      } catch (e) {
        // If JSON parsing fails, return empty map
        return <String, dynamic>{};
      }
    }
    
    // For any other type, return empty map
    return <String, dynamic>{};
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['\$id'] ?? map['id'] ?? '',
      repId: map['repId']?.toString() ?? '',
      companyId: map['companyId']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      addons: map['addons']?.toString(),
      accessories: map['accessories']?.toString(),
      invoiceTotal: (map['invoiceTotal'] is num)
          ? (map['invoiceTotal'] as num).toDouble()
          : 0.0,
      customerName: map['customerName']?.toString() ?? '',
      customerPhone: map['customerPhone']?.toString() ?? '',
      customerEmail: map['customerEmail']?.toString(),
      customerAddress: map['customerAddress']?.toString() ?? '',
      customerLocation: _parseCustomerLocation(map['customerLocation']),
      orderStatus: map['orderStatus'] != null
          ? OrderStatus.values.firstWhere(
              (e) => e.toString().split('.').last == map['orderStatus'],
              orElse: () => OrderStatus.pending,
            )
          : OrderStatus.pending,
      statusReason: map['statusReason']?.toString(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Order(id: $id, repId: $repId, companyId: $companyId, productId: $productId, addons: $addons, accessories: $accessories, invoiceTotal: $invoiceTotal, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerAddress: $customerAddress, customerLocation: $customerLocation, orderStatus: $orderStatus, statusReason: $statusReason, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.repId == repId &&
        other.companyId == companyId &&
        other.productId == productId &&
        other.addons == addons &&
        other.accessories == accessories &&
        other.invoiceTotal == invoiceTotal &&
        other.customerName == customerName &&
        other.customerPhone == customerPhone &&
        other.customerEmail == customerEmail &&
        other.customerAddress == customerAddress &&
        mapEquals(other.customerLocation, customerLocation) &&
        other.orderStatus == orderStatus &&
        other.statusReason == statusReason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        repId.hashCode ^
        companyId.hashCode ^
        productId.hashCode ^
        addons.hashCode ^
        accessories.hashCode ^
        invoiceTotal.hashCode ^
        customerName.hashCode ^
        customerPhone.hashCode ^
        customerEmail.hashCode ^
        customerAddress.hashCode ^
        customerLocation.hashCode ^
        orderStatus.hashCode ^
        statusReason.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
