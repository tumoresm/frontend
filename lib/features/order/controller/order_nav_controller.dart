import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the order navigation controller
final orderNavControllerProvider = StateNotifierProvider<OrderNavController, OrderNavState>((ref) {
  return OrderNavController(ref);
});

/// State for the order navigation controller
class OrderNavState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final String? selectedFilter;

  const OrderNavState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter,
  });

  OrderNavState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return OrderNavState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

/// Controller for order navigation and management
class OrderNavController extends StateNotifier<OrderNavState> {
  final Ref _ref;

  OrderNavController(this._ref) : super(const OrderNavState()) {
    // Listen to order list changes and refresh when needed
    _ref.listen(orderListStateChangesProvider, (previous, next) {
      refreshOrders();
    });
  }

  /// Refresh the orders list
  Future<void> refreshOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final orderController = _ref.read(orderControllerProvider.notifier);
      final orders = await orderController.getOrders();
      
      state = state.copyWith(
        orders: orders,
        isLoading: false,
        error: null,
      );
      
      Loggers.database.info('Orders refreshed successfully: ${orders.length} orders');
    } catch (e) {
      Loggers.database.error('Failed to refresh orders: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load orders: $e',
      );
    }
  }

  /// Get orders for a specific rep
  Future<void> getRepOrders(String repId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final orderController = _ref.read(orderControllerProvider.notifier);
      final orders = await orderController.getRepOrders(repId);
      
      state = state.copyWith(
        orders: orders,
        isLoading: false,
        error: null,
      );
      
      Loggers.database.info('Rep orders loaded successfully: ${orders.length} orders for rep $repId');
    } catch (e) {
      Loggers.database.error('Failed to get rep orders: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load rep orders: $e',
      );
    }
  }

  /// Filter orders by status
  void filterOrdersByStatus(OrderStatus? status) {
    if (status == null) {
      state = state.copyWith(selectedFilter: null);
      refreshOrders();
      return;
    }

    final filteredOrders = state.orders.where((order) => order.orderStatus == status).toList();
    state = state.copyWith(
      orders: filteredOrders,
      selectedFilter: status.toString().split('.').last,
    );
    
    Loggers.database.info('Orders filtered by status: ${status.toString().split('.').last}, ${filteredOrders.length} orders');
  }

  /// Search orders by customer name
  void searchOrders(String query) {
    if (query.isEmpty) {
      refreshOrders();
      return;
    }

    final searchResults = state.orders.where((order) {
      return order.customerName.toLowerCase().contains(query.toLowerCase()) ||
             order.customerPhone.contains(query) ||
             (order.customerEmail?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    state = state.copyWith(orders: searchResults);
    Loggers.database.info('Orders searched with query: "$query", ${searchResults.length} results');
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return state.orders.where((order) => order.orderStatus == status).toList();
  }

  /// Get total order value
  double getTotalOrderValue() {
    return state.orders.fold(0.0, (sum, order) => sum + order.invoiceTotal);
  }

  /// Get order count by status
  Map<OrderStatus, int> getOrderCountByStatus() {
    final Map<OrderStatus, int> counts = {};
    
    for (final status in OrderStatus.values) {
      counts[status] = state.orders.where((order) => order.orderStatus == status).length;
    }
    
    return counts;
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset filters and show all orders
  void resetFilters() {
    state = state.copyWith(selectedFilter: null);
    refreshOrders();
  }
}

/// Provider for order statistics
final orderStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final orderNavState = ref.watch(orderNavControllerProvider);
  final orders = orderNavState.orders;

  if (orders.isEmpty) {
    return {
      'totalOrders': 0,
      'totalValue': 0.0,
      'pendingOrders': 0,
      'approvedOrders': 0,
      'deliveredOrders': 0,
    };
  }

  final totalOrders = orders.length;
  final totalValue = orders.fold(0.0, (sum, order) => sum + order.invoiceTotal);
  final pendingOrders = orders.where((order) => order.orderStatus == OrderStatus.pending).length;
  final approvedOrders = orders.where((order) => order.orderStatus == OrderStatus.approved).length;
  final deliveredOrders = orders.where((order) => order.orderStatus == OrderStatus.delivered).length;

  return {
    'totalOrders': totalOrders,
    'totalValue': totalValue,
    'pendingOrders': pendingOrders,
    'approvedOrders': approvedOrders,
    'deliveredOrders': deliveredOrders,
  };
});

/// Provider for filtered orders
final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orderNavState = ref.watch(orderNavControllerProvider);
  return orderNavState.orders;
});

/// Provider for order loading state
final orderLoadingProvider = Provider<bool>((ref) {
  final orderNavState = ref.watch(orderNavControllerProvider);
  return orderNavState.isLoading;
});

/// Provider for order error state
final orderErrorProvider = Provider<String?>((ref) {
  final orderNavState = ref.watch(orderNavControllerProvider);
  return orderNavState.error;
});