import 'package:fieldforce/features/companies/providers/company_provider.dart';
import 'package:fieldforce/features/home/view/widgets/industry_filter_buttons.dart';

import 'package:fieldforce/theme/custom_appbar.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/common/widgets/order_card.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String? selectedIndustryId;

  void onIndustrySelected(String? industryId) {
    setState(() {
      selectedIndustryId = industryId;
    });
  }

  /// Refresh method for pull-to-refresh functionality
  Future<void> _refreshOrders() async {
    // Invalidate the providers to trigger a refresh
    ref.invalidate(getCompaniesProvider);
    
    // Get current user to refresh their orders
    final currentUser = ref.read(currentUserDetailsProvider).value;
    if (currentUser != null) {
      ref.invalidate(getRepOrdersProvider(currentUser.id));
    }
    
    // Wait a bit to ensure the refresh completes
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: CustomAppBar.appBar(const Text('Orders')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          IndustryFilterButtons(onIndustrySelected: onIndustrySelected),
          const SizedBox(height: 30),
          currentUser.when(
            data: (user) {
              if (user == null) {
                return const Center(child: Text('User not found.'));
              }
              final companiesAsyncValue = ref.watch(getCompaniesProvider);
              return companiesAsyncValue.when(
                data: (companies) {
                  final filteredCompanies = selectedIndustryId == null
                      ? companies
                      : companies
                          .where((company) =>
                              company.industryId == selectedIndustryId)
                          .toList();
                  final filteredCompanyIds =
                      filteredCompanies.map((company) => company.id).toList();

                  return ref.watch(getRepOrdersProvider(user.id)).when(
                        data: (List<OrderModel> orders) {
                          final filteredOrders = orders
                              .where((order) =>
                                  filteredCompanyIds.contains(order.companyId))
                              .toList();
                          if (filteredOrders.isEmpty) {
                            return Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refreshOrders,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 200),
                                    Center(
                                      child: Text('No orders found.\nPull down to refresh'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Expanded(
                            child: RefreshIndicator(
                              onRefresh: _refreshOrders,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  return OrderCard(
                                    transaction: order,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        loading: () => const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) => Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshOrders,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 200),
                                Center(
                                  child: Column(
                                    children: [
                                      Text('Error: ${error.toString()}'),
                                      const SizedBox(height: 10),
                                      const Text('Pull down to retry'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                },
                loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshOrders,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 200),
                        Center(
                          child: Column(
                            children: [
                              Text('Error loading companies: ${error.toString()}'),
                              const SizedBox(height: 10),
                              const Text('Pull down to retry'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshOrders,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Column(
                        children: [
                          Text('Error loading user: ${error.toString()}'),
                          const SizedBox(height: 10),
                          const Text('Pull down to retry'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
