import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final String id;
  final String companyId;
  final String productName;
  final String description;
  final double price;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.companyId,
    required this.productName,
    required this.description,
    required this.price,
    required this.isActive,
  });

  ProductModel copyWith({
    String? id,
    String? companyId,
    String? productName,
    String? description,
    double? price,
    bool? isActive,
  }) =>
      ProductModel(
        id: id ?? this.id,
        companyId: companyId ?? this.companyId,
        productName: productName ?? this.productName,
        description: description ?? this.description,
        price: price ?? this.price,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'companyId': companyId,
        'productName': productName,
        'description': description,
        'price': price,
        'isActive': isActive,
      };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['\$id'] as String,
      companyId: map['companyId'] as String,
      productName: map['productName'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      isActive: map['isActive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ProductModel(id: $id, companyId: $companyId, productName: $productName, description: $description, price: $price, isActive: $isActive)';

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.companyId == companyId &&
        other.productName == productName &&
        other.description == description &&
        other.price == price &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        productName.hashCode ^
        description.hashCode ^
        price.hashCode ^
        isActive.hashCode;
  }
}
