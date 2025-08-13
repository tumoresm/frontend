import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/utils/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(getOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: orders.when(
        data: (orderList) {
          if (orderList.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          return ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              final order = orderList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${order.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Product ID: ${order.productId}'),
                      Text('Status: ${order.orderStatus.name}'),
                      Text(
                          'Created At: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
                      // Add more order details as needed
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Loader(),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}
