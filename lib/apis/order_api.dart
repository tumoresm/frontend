import 'dart:convert';
import 'package:fieldforce/constants/host_constants.dart';
import 'package:http/http.dart' as http;
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final orderAPIProvider = Provider((ref) {
  return OrderAPI();
});

abstract class IOrderAPI {
  FutureEither<OrderModel> createOrder(OrderModel order);
  FutureEither<List<OrderModel>> getOrders();
  FutureEither<List<OrderModel>> getRepOrders(String repId);
  FutureEither<OrderModel> getOrderById(String orderId);
  FutureEither<List<OrderModel>> getOrdersByStatus(OrderStatus status);
  FutureEither<List<OrderModel>> searchOrders(String query);
  FutureEither<OrderModel> updateOrder(OrderModel order);
  FutureEither<OrderModel> updateOrderStatus(String orderId, OrderStatus status, String? reason);
  FutureEither<String> deleteOrder(String orderId);
}

class OrderAPI implements IOrderAPI {
  final String _baseUrl = HostConstants.baseURL;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  FutureEither<OrderModel> createOrder(OrderModel order) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(order.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return right(OrderModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to create order: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<OrderModel>> getOrders() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        return right(orders);
      } else {
        return left(Failure(
            'Failed to get orders: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<OrderModel>> getRepOrders(String repId) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/rep/$repId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        return right(orders);
      } else {
        return left(Failure(
            'Failed to get rep orders: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<OrderModel> getOrderById(String orderId) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return right(OrderModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to get order: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final token = await _getAccessToken();
      final statusString = status.toString().split('.').last;
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/status/$statusString'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        return right(orders);
      } else {
        return left(Failure(
            'Failed to get orders by status: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<OrderModel>> searchOrders(String query) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        return right(orders);
      } else {
        return left(Failure(
            'Failed to search orders: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<OrderModel> updateOrder(OrderModel order) async {
    try {
      final token = await _getAccessToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/${order.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(order.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return right(OrderModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to update order: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<OrderModel> updateOrderStatus(String orderId, OrderStatus status, String? reason) async {
    try {
      final token = await _getAccessToken();
      final statusString = status.toString().split('.').last;
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': statusString,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return right(OrderModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to update order status: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<String> deleteOrder(String orderId) async {
    try {
      final token = await _getAccessToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(data['message']);
      } else {
        return left(Failure(
            'Failed to delete order: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}