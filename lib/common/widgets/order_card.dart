import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final OrderModel transaction;

  const OrderCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${transaction.customerName}'),
            Text('Status: ${transaction.orderStatus}'),
            Text('Created: ${transaction.createdAt}'),
          ],
        ),
      ),
    );
  }
}
