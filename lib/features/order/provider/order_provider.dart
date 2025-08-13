import 'package:fieldforce/apis/order_api.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple provider that other providers can watch.
/// When this provider is invalidated, any watchers will be forced to rebuild.
/// This is our mechanism for triggering a refresh of the orders list.
final orderListStateChangesProvider = Provider((ref) => {});

final orderControllerProvider =
    StateNotifierProvider<OrderController, bool>((ref) {
  return OrderController(
    orderAPI: ref.watch(orderAPIProvider),
    ref: ref,
  );
});

final getOrdersProvider = FutureProvider((ref) {
  final orderController = ref.watch(orderControllerProvider.notifier);
  return orderController.getOrders();
});

final getRepOrdersProvider = FutureProvider.family((ref, String repId) {
  final orderController = ref.watch(orderControllerProvider.notifier);
  return orderController.getRepOrders(repId);
});

/// This controller is now focused only on actions, like creating an order.
/// The state it manages (`bool`) is purely for the loading status of the creation process.
class OrderController extends StateNotifier<bool> {
  final OrderAPI _orderAPI;
  final Ref _ref;

  OrderController({required OrderAPI orderAPI, required Ref ref})
      : _orderAPI = orderAPI,
        _ref = ref,
        super(false); // represents loading state

  Future<List<OrderModel>> getOrders() async {
    return _orderAPI.getOrders();
  }

  Future<List<OrderModel>> getRepOrders(String repId) async {
    return _orderAPI.getRepOrders(repId);
  }

  void createOrder({
    required String companyId,
    required String productId,
    required double invoiceTotal,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String customerAddress,
    required Map<String, dynamic> customerLocation,
    required OrderStatus orderStatus,
    String? statusReason,

    /// The ID of the user (sales representative) creating the order.
    required String repId,
  }) async {
    // Removed BuildContext
    state = true; // loading
    final now = DateTime.now();
    final order = OrderModel(
      id: '',
      // Appwrite will generate this
      companyId: companyId,
      createdAt: now,
      updatedAt: now,
      repId: repId,
      invoiceTotal: invoiceTotal,
      productId: productId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      customerAddress: customerAddress,
      customerLocation: customerLocation,
      orderStatus: orderStatus,
      statusReason: statusReason,
    );

    final res = await _orderAPI.createOrder(order);
    state = false; // not loading
    res.fold(
      (l) {
        throw l; // Throw the failure object
      },
      (r) {
        // When an order is created successfully, invalidate our change
        // provider. This will cause OrderNavController to refetch the list.
        _ref.invalidate(orderListStateChangesProvider);
        // UI actions are now handled by the caller.
      },
    );
  }
}
