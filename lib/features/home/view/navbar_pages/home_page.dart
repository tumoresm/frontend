import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/common/widgets/notifications_dialog.dart';
import 'package:fieldforce/features/home/view/widgets/time_filter_buttons.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/common/widgets/order_card.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:fieldforce/features/home/view/widgets/earningscard.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentUserDetails = ref.watch(currentUserDetailsProvider);
    final orders = ref.watch(getOrdersProvider);
    final userWallet = ref.watch(getUserWalletProvider);

    return Scaffold(
      backgroundColor: kRed,
      body: SafeArea(
        child: Stack(
          children: [
            orders.when(
              data: (ordersList) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          currentUserDetails.when(
                            data: (user) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome back",
                                  style: TextStyle(
                                    color: kWhite,
                                  ),
                                ),
                                Text(
                                  user?.fullName ?? "User",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kWhite,
                                  ),
                                ),
                              ],
                            ),
                            loading: () => const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back",
                                  style: TextStyle(
                                    color: kWhite,
                                  ),
                                ),
                                Text(
                                  "Loading...",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kWhite,
                                  ),
                                ),
                              ],
                            ),
                            error: (error, stack) => const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back",
                                  style: TextStyle(
                                    color: kWhite,
                                  ),
                                ),
                                Text(
                                  "User",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          //Notification icon
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierColor: kSecondary,
                                builder: (context) =>
                                    const NotificationsDialog(),
                              );
                            },
                            icon: const Icon(
                              Symbols.notifications,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer for EarningsCard
                    const SizedBox(height: 55),
                    // Main Content Section
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 60),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(18, 18, 18, 0.8),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Total Orders",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Chart Section with fixed height
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                height: 160,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const titles = [
                                                'S',
                                                'M',
                                                'T',
                                                'W',
                                                'T',
                                                'F',
                                                'S'
                                              ];
                                              final index = value.toInt();
                                              if (index >= 0 &&
                                                  index < titles.length) {
                                                return Text(
                                                  titles[index],
                                                  style: const TextStyle(
                                                    color: Colours.greyColor,
                                                  ),
                                                );
                                              }
                                              return const Text("");
                                            },
                                            reservedSize: 22,
                                            interval: 1,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 1),
                                            FlSpot(1, 2),
                                            FlSpot(2, 0),
                                            FlSpot(3, 2),
                                            FlSpot(4, 3),
                                            FlSpot(5, 5),
                                            FlSpot(6, 7),
                                          ],
                                          isCurved: true,
                                          color: kPrimary,
                                          barWidth: 2,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Colours.gradient3
                                                .withOpacity(0.07),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const TimeFilterRow(),
                            const SizedBox(height: 20),
                            // Orders List
                            Expanded(
                              child: ordersList.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No orders yet",
                                        style: TextStyle(
                                          color: Colours.greyColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      itemCount: ordersList.length,
                                      itemBuilder: (context, index) {
                                        return OrderCard(
                                          transaction: ordersList[index],
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
            ),
            // Positioned EarningsCard
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: userWallet.when(
                data: (wallet) => EarningsCard(
                  totalEarnings: wallet?.totalEarnings,
                  totalPaid: wallet != null
                      ? wallet.totalEarnings -
                          wallet.currentBalance -
                          wallet.pendingEarnings
                      : null,
                  isLoading: false,
                ),
                loading: () => const EarningsCard(isLoading: true),
                error: (error, stack) => const EarningsCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
