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
}
