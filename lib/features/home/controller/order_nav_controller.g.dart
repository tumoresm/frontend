// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_nav_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderTabsHash() => r'488a22f5f5fbbd59f7c914a86be10e5fed4923e7';

/// Provides the list of statuses to be used for the filter tabs in the UI.
///
/// Copied from [orderTabs].
@ProviderFor(orderTabs)
final orderTabsProvider = AutoDisposeProvider<List<OrderStatus>>.internal(
  orderTabs,
  name: r'orderTabsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$orderTabsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OrderTabsRef = Ref<List<OrderStatus>>;
String _$filteredOrdersHash() => r'07b8ed296147ef7199fa313f199993e0bbce7cc0';

/// Provides a filtered list of orders based on the selected tab.
///
/// Copied from [filteredOrders].
@ProviderFor(filteredOrders)
final filteredOrdersProvider = AutoDisposeProvider<List<OrderModel>>.internal(
  filteredOrders,
  name: r'filteredOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredOrdersRef = Ref<List<OrderModel>>;
String _$orderNavControllerHash() =>
    r'7c1be96275db3eb6dfa7a4ea4994c64016e28b6b';

/// Manages the state for the orders page, including fetching and filtering orders.
///
/// Copied from [OrderNavController].
@ProviderFor(OrderNavController)
final orderNavControllerProvider = AutoDisposeAsyncNotifierProvider<
    OrderNavController, OrderNavState>.internal(
  OrderNavController.new,
  name: r'orderNavControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderNavControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrderNavController = AutoDisposeAsyncNotifier<OrderNavState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member