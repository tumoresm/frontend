// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class CompanyModel {
  final String id;
  final String companyName;
  final String logoUrl;
  final String description;
  final String industryId;
  final String? industryName;
  final List<String> products;
  final double commissionPerOrder;
  final bool isActive;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.logoUrl,
    required this.description,
    required this.industryId,
    this.industryName,
    required this.products,
    required this.commissionPerOrder,
    required this.isActive,
  });

  CompanyModel copyWith({
    String? id,
    String? companyName,
    String? logoUrl,
    String? description,
    String? industryId,
    String? industryName,
    List<String>? products,
    double? commissionPerOrder,
    bool? isActive,
  }) =>
      CompanyModel(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        logoUrl: logoUrl ?? this.logoUrl,
        description: description ?? this.description,
        industryId: industryId ?? this.industryId,
        industryName: industryName ?? this.industryName,
        products: products ?? this.products,
        commissionPerOrder: commissionPerOrder ?? this.commissionPerOrder,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'companyName': companyName,
        'logoUrl': logoUrl,
        'description': description,
        'industryId': industryId,
        'industryName': industryName,
        'products': products,
        'commissionPerOrder': commissionPerOrder,
        'isActive': isActive,
      };

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['\$id'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      industryId: map['industryId'] as String? ?? '',
      industryName: map['industryName'] as String?,
      products: List<String>.from(map['products'] ?? []),
      commissionPerOrder: (map['commissionPerOrder'] is num)
          ? (map['commissionPerOrder'] as num).toDouble()
          : 0.0,
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyModel.fromJson(String source) =>
      CompanyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Company(id: $id, companyName: $companyName, logoUrl: $logoUrl, description: $description, industryId: $industryId, industryName: $industryName, products: $products, commissionPerOrder: $commissionPerOrder, isActive: $isActive)';

  @override
  bool operator ==(covariant CompanyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.companyName == companyName &&
        other.logoUrl == logoUrl &&
        other.description == description &&
        other.industryId == industryId &&
        other.industryName == industryName &&
        listEquals(other.products, products) &&
        other.commissionPerOrder == commissionPerOrder &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyName.hashCode ^
        logoUrl.hashCode ^
        description.hashCode ^
        industryId.hashCode ^
        industryName.hashCode ^
        products.hashCode ^
        commissionPerOrder.hashCode ^
        isActive.hashCode;
  }
}