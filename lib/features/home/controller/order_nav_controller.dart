import 'dart:async';

import 'package:fieldforce/apis/order_api.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_nav_controller.g.dart';

/// A model to hold the state for the orders screen.
///
/// This includes the full list of orders and the currently selected filter.
class OrderNavState {
  final List<OrderModel> orders;
  final OrderStatus selectedFilter;

  OrderNavState({
    this.orders = const <OrderModel>[],
    this.selectedFilter = OrderStatus.pending,
  });

  OrderNavState copyWith({
    List<OrderModel>? orders,
    OrderStatus? selectedFilter,
  }) {
    return OrderNavState(
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

/// Manages the state for the orders page, including fetching and filtering orders.
@riverpod
class OrderNavController extends _$OrderNavController {
  @override
  Future<OrderNavState> build() async {
    // By watching this provider, the controller will refetch orders whenever
    // an order is created/updated elsewhere in the app.
    ref.watch(orderListStateChangesProvider);

    // Await the future of the provider to get the actual UserModel object.
    // This correctly handles loading/error states from the user provider.
    final user = await ref.watch(currentUserDetailsProvider.future);

    if (user == null) {
      // If the user is not logged in, return an empty state.
      // The UI should handle this case, perhaps by showing a login prompt.
      return OrderNavState();
    }

    // Fetch the orders from the API. Riverpod handles loading/error states.
    final orderAPI = ref.watch(orderAPIProvider);
    final ordersResult = await orderAPI.getRepOrders(user.id);

    // Handle the Either result properly
    final orders = ordersResult.fold(
      (failure) {
        // Log the error and return empty list for graceful degradation
        Loggers.database.warning('Failed to fetch orders for user ${user.id}: ${failure.message}');
        Loggers.database.info('Returning empty orders list until migration to FastAPI is complete');
        return <OrderModel>[];
      },
      (ordersList) => ordersList,
    );

    return OrderNavState(orders: orders);
  }

  /// Sets the filter for the orders list.
  void setFilter(OrderStatus filter) {
    final currentState = state.value;
    if (currentState != null) {
      // Update the state with the new filter without refetching data.
      state = AsyncData(currentState.copyWith(selectedFilter: filter));
    }
  }
}

/// Provides the list of statuses to be used for the filter tabs in the UI.
@riverpod
List<OrderStatus> orderTabs(Ref ref) {
  return [
    OrderStatus.pending,
    OrderStatus.approved,
    OrderStatus.paid,
    OrderStatus.rejected,
  ];
}

/// Provides a filtered list of orders based on the selected tab.
@riverpod
List<OrderModel> filteredOrders(Ref ref) {
  final orderNavState = ref.watch(orderNavControllerProvider).valueOrNull;
  if (orderNavState == null) return [];

  return orderNavState.orders
      .where((order) => order.orderStatus == orderNavState.selectedFilter)
      .toList();
}
