class Order {
  final String id;
  final String repId;
  final String companyId;
  final String productId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String customerAddress;
  final Map<String, double> customerLocation;
  final String orderStatus;
  final String? statusReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.repId,
    required this.companyId,
    required this.productId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.customerAddress,
    required this.customerLocation,
    required this.orderStatus,
    this.statusReason,
    required this.createdAt,
    required this.updatedAt,
  });
}
