import 'dart:convert';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

/// Provider for FastAPI order API
final fastapiOrderAPIProvider = Provider<IFastAPIOrderAPI>((ref) {
  final httpClient = ref.watch(authenticatedHttpClientProvider);
  return FastAPIOrderAPI(httpClient);
});

/// Interface for order API operations
abstract class IFastAPIOrderAPI {
  /// Get user's orders
  FutureEither<List<OrderModel>> getOrders({
    int? limit,
    int? offset,
    OrderStatus? status,
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get order by ID
  FutureEither<OrderModel> getOrderById(String id);
  
  /// Create a new order
  FutureEither<OrderModel> createOrder(OrderModel order);
  
  /// Update an existing order
  FutureEither<OrderModel> updateOrder(String orderId, OrderModel order);
  
  /// Delete an order
  FutureEither<void> deleteOrder(String orderId);
  
  /// Get order statistics
  FutureEither<Map<String, dynamic>> getOrderStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// FastAPI implementation of order API
class FastAPIOrderAPI extends FastAPIRepository implements IFastAPIOrderAPI {
  FastAPIOrderAPI(super.httpClient);

  @override
  FutureEither<List<OrderModel>> getOrders({
    int? limit,
    int? offset,
    OrderStatus? status,
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (status != null) queryParams['status'] = status.toString().split('.').last;
      if (companyId != null) queryParams['company_id'] = companyId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/orders${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await httpClient.get(endpoint);
      
      final orders = handleListResponse<OrderModel>(
        response,
        (data) => OrderModel.fromMap(data),
        operation: 'Get orders',
      );
      
      Loggers.database.info('Retrieved ${orders.length} orders');
      return right(orders);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get orders: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<OrderModel> getOrderById(String id) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.get('/orders/$id');
      
      final order = handleResponse<OrderModel>(
        response,
        (data) => OrderModel.fromMap(data),
        operation: 'Get order by ID',
      );
      
      Loggers.database.info('Order retrieved successfully: $id');
      return right(order);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get order by ID: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<OrderModel> createOrder(OrderModel order) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = order.toMap();
      // Remove fields that should be set by the server
      requestBody.remove('id');
      requestBody.remove('createdAt');
      requestBody.remove('updatedAt');
      
      // Ensure user_id is set from current user
      final currentUserId = await FastAPISecurity.getCurrentUserId();
      if (currentUserId != null) {
        requestBody['user_id'] = currentUserId;
        requestBody['repId'] = currentUserId;
      }
      
      final response = await httpClient.post(
        '/orders',
        body: requestBody,
      );
      
      final newOrder = handleResponse<OrderModel>(
        response,
        (data) => OrderModel.fromMap(data),
        operation: 'Create order',
      );
      
      Loggers.database.info('Order created successfully: ${newOrder.id}');
      return right(newOrder);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to create order: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<OrderModel> updateOrder(String orderId, OrderModel order) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = order.toMap();
      // Remove fields that shouldn't be updated
      requestBody.remove('id');
      requestBody.remove('repId');
      requestBody.remove('user_id');
      requestBody.remove('createdAt');
      
      final response = await httpClient.put(
        '/orders/$orderId',
        body: requestBody,
      );
      
      final updatedOrder = handleResponse<OrderModel>(
        response,
        (data) => OrderModel.fromMap(data),
        operation: 'Update order',
      );
      
      Loggers.database.info('Order updated successfully: $orderId');
      return right(updatedOrder);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to update order: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<void> deleteOrder(String orderId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.delete('/orders/$orderId');
      
      handleVoidResponse(response, operation: 'Delete order');
      
      Loggers.database.info('Order deleted successfully: $orderId');
      return right(null);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to delete order: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<Map<String, dynamic>> getOrderStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/orders/statistics${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await httpClient.get(endpoint);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final statistics = responseData['data'] ?? responseData;
        
        Loggers.database.info('Order statistics retrieved successfully');
        return right(statistics);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
        Loggers.database.error('Get order statistics failed: HTTP ${response.statusCode}: $errorMessage');
        throw Exception('Get order statistics failed: $errorMessage');
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get order statistics: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }
}