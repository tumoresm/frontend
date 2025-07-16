// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Company {
  final String id;
  final String companyName;
  final String logoUrl;
  final String description;
  final String industry;
  final List<Product> products;
  final double commissionPerOrder;
  final bool isActive;

  Company({
    required this.id,
    required this.companyName,
    required this.logoUrl,
    required this.description,
    required this.industry,
    required this.products,
    required this.commissionPerOrder,
    required this.isActive,
  });

  Company copyWith({
    String? id,
    String? companyName,
    String? logoUrl,
    String? description,
    String? industry,
    List<Product>? products,
    double? commissionPerOrder,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      products: products ?? this.products,
      commissionPerOrder: commissionPerOrder ?? this.commissionPerOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'companyName': companyName,
      'logoUrl': logoUrl,
      'description': description,
      'industry': industry,
      'products': products.map((x) => x.toMap()).toList(),
      'commissionPerOrder': commissionPerOrder,
      'isActive': isActive,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as String,
      companyName: map['companyName'] as String,
      logoUrl: map['logoUrl'] as String,
      description: map['description'] as String,
      industry: map['industry'] as String,
      products: List<Product>.from(
        (map['products'] as List<int>).map<Product>(
          (x) => Product.fromMap(x as Map<String, dynamic>),
        ),
      ),
      commissionPerOrder: map['commissionPerOrder'] as double,
      isActive: map['isActive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Company(id: $id, companyName: $companyName, logoUrl: $logoUrl, description: $description, industry: $industry, products: $products, commissionPerOrder: $commissionPerOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant Company other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.companyName == companyName &&
        other.logoUrl == logoUrl &&
        other.description == description &&
        other.industry == industry &&
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
        industry.hashCode ^
        products.hashCode ^
        commissionPerOrder.hashCode ^
        isActive.hashCode;
  }
}

class Product {
  final String productId;
  final String productName;
  final String description;
  final double price;

  Product({
    required this.productId,
    required this.productName,
    required this.description,
    required this.price,
  });

  Product copyWith({
    String? productId,
    String? productName,
    String? description,
    double? price,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'description': description,
      'price': price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(productId: $productId, productName: $productName, description: $description, price: $price)';
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.productName == productName &&
        other.description == description &&
        other.price == price;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        productName.hashCode ^
        description.hashCode ^
        price.hashCode;
  }
}
