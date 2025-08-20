import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/home/provider/time_filter_provider.dart';
import 'package:fieldforce/common/widgets/notifications_dialog.dart';
import 'package:fieldforce/features/home/view/widgets/time_filter_buttons.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final userWallet = ref.watch(getUserWalletProvider);
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final chartData = ref.watch(chartDataProvider);
    final timeFilter = ref.watch(timeFilterProvider);

    // Responsive dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final headerHeight = isSmallScreen ? 100.h : 120.h;
    final earningsCardHeight = isSmallScreen ? 90.h : 110.h;

    return Scaffold(
      backgroundColor: kRed,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Container(
              height: headerHeight,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: currentUserDetails.when(
                      data: (user) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            user?.fullName ?? "User",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20.sp : 24.sp,
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Loading...",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20.sp : 24.sp,
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                      error: (error, stack) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "User",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20.sp : 24.sp,
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Notification icon
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: kSecondary,
                        builder: (context) => const NotificationsDialog(),
                      );
                    },
                    icon: Icon(
                      Symbols.notifications,
                      color: kWhite,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // EarningsCard positioned below header
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: userWallet.when(
                data: (wallet) => EarningsCard(
                  totalEarnings: wallet?.totalEarnings,
                  totalPaid: wallet != null
                      ? wallet.totalEarnings - wallet.currentBalance - wallet.pendingEarnings
                      : null,
                  isLoading: false,
                ),
                loading: () => const EarningsCard(isLoading: true),
                error: (error, stack) => const EarningsCard(),
              ),
            ),

            SizedBox(height: 16.h),

            // Scrollable Content Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(18, 18, 18, 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    // Chart Section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            Text(
                              "Orders Overview",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: kWhite,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "${timeFilter.displayName}ly Performance",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colours.greyColor,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            
                            // Responsive Chart
                            Container(
                              height: isSmallScreen ? 140.h : 160.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final labels = chartData['labels'] as List<String>;
                                          final index = value.toInt();
                                          if (index >= 0 && index < labels.length) {
                                            return Text(
                                              labels[index],
                                              style: TextStyle(
                                                color: Colours.greyColor,
                                                fontSize: 12.sp,
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
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _generateChartSpots(chartData['data'] as List<double>),
                                      isCurved: true,
                                      color: kPrimary,
                                      barWidth: 3,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: kPrimary,
                                            strokeWidth: 2,
                                            strokeColor: kWhite,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            kPrimary.withOpacity(0.3),
                                            kPrimary.withOpacity(0.05),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Time Filter Section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const TimeFilterRow(),
                      ),
                    ),

                    // Orders List Header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Orders",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: kWhite,
                              ),
                            ),
                            Text(
                              "${filteredOrders.length} orders",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colours.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Orders List
                    filteredOrders.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              height: 200.h,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.shopping_cart_off,
                                      size: 48.sp,
                                      color: Colours.greyColor,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "No orders for ${timeFilter.displayName.toLowerCase()}",
                                      style: TextStyle(
                                        color: Colours.greyColor,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "Try selecting a different time period",
                                      style: TextStyle(
                                        color: Colours.greyColor.withOpacity(0.7),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 4.h,
                                  ),
                                  child: OrderCard(
                                    transaction: filteredOrders[index],
                                  ),
                                );
                              },
                              childCount: filteredOrders.length,
                            ),
                          ),

                    // Bottom padding for scroll
                    SliverToBoxAdapter(
                      child: SizedBox(height: 20.h),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartSpots(List<double> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }
}
