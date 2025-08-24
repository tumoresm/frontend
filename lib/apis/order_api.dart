import 'dart:convert';
import 'package:fieldforce/constants/backend_constants.dart';
import 'package:http/http.dart' as http;
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/core/session_manager.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

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
  String get _baseUrl {
    final url = BackendConstants.apiBaseUrl;
    Loggers.database.debug('OrderAPI base URL: $url');
    return url;
  }

  Future<String?> _getAccessToken() async {
    try {
      final sessionManager = SessionManager.instance;
      final token = await sessionManager.getAccessToken();
      
      if (token == null) {
        Loggers.database.warning('No access token found in session');
      } else {
        Loggers.database.debug('Access token found, length: ${token.length}');
      }
      
      return token;
    } catch (e) {
      Loggers.database.error('Error getting access token from session: $e');
      return null;
    }
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
      Loggers.database.info('Fetching all orders');
      
      final token = await _getAccessToken();
      if (token == null) {
        Loggers.database.error('No access token available for getOrders');
        return left(Failure('No access token available', StackTrace.current));
      }
      
      final url = '$_baseUrl/orders';
      Loggers.database.debug('Making request to: $url');
      Loggers.database.debug('Using token: ${token.substring(0, 10)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Loggers.database.debug('Response status: ${response.statusCode}');
      Loggers.database.debug('Response headers: ${response.headers}');
      Loggers.database.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        
        Loggers.database.info('Successfully fetched ${orders.length} orders');
        return right(orders);
      } else {
        final errorMessage = 'Failed to get orders: ${response.statusCode} - ${response.body}';
        Loggers.database.error(errorMessage);
        
        // Try to parse error details from response
        try {
          final errorData = jsonDecode(response.body);
          final detailedError = errorData['message'] ?? errorData['error'] ?? errorData['detail'] ?? 'Unknown error';
          Loggers.database.error('Backend error details: $detailedError');
        } catch (e) {
          Loggers.database.error('Could not parse error response: ${response.body}');
        }
        
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, st) {
      final errorMessage = 'Exception in getOrders: $e';
      Loggers.database.error(errorMessage, error: e, stackTrace: st);
      return left(Failure(errorMessage, st));
    }
  }

  @override
  FutureEither<List<OrderModel>> getRepOrders(String repId) async {
    try {
      // Add logging to track the rep_id being used
      Loggers.database.info('Fetching orders for rep_id: $repId');
      
      final token = await _getAccessToken();
      if (token == null) {
        Loggers.database.error('No access token available for getRepOrders');
        return left(Failure('No access token available', StackTrace.current));
      }
      
      final url = BackendConstants.getRepOrdersEndpoint(repId);
      Loggers.database.debug('Making request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Loggers.database.debug('Response status: ${response.statusCode}');
      Loggers.database.debug('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final orders = data.map((e) => OrderModel.fromMap(e)).toList();
        
        Loggers.database.info('Successfully fetched ${orders.length} orders for rep_id: $repId');
        return right(orders);
      } else {
        final errorMessage = 'Failed to get rep orders: ${response.statusCode} - ${response.body}';
        Loggers.database.error(errorMessage);
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, st) {
      final errorMessage = 'Exception in getRepOrders for rep_id $repId: $e';
      Loggers.database.error(errorMessage, error: e, stackTrace: st);
      return left(Failure(errorMessage, st));
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