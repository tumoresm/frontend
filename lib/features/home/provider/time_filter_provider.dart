import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/features/order/provider/order_provider.dart';

enum TimeFilterPeriod {
  day,
  week,
  month,
  year,
}

extension TimeFilterPeriodExtension on TimeFilterPeriod {
  String get displayName {
    switch (this) {
      case TimeFilterPeriod.day:
        return 'Day';
      case TimeFilterPeriod.week:
        return 'Week';
      case TimeFilterPeriod.month:
        return 'Month';
      case TimeFilterPeriod.year:
        return 'Year';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case TimeFilterPeriod.day:
        return DateTime(now.year, now.month, now.day);
      case TimeFilterPeriod.week:
        final weekday = now.weekday;
        return now.subtract(Duration(days: weekday - 1));
      case TimeFilterPeriod.month:
        return DateTime(now.year, now.month, 1);
      case TimeFilterPeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (this) {
      case TimeFilterPeriod.day:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case TimeFilterPeriod.week:
        final weekday = now.weekday;
        return now.add(Duration(days: 7 - weekday));
      case TimeFilterPeriod.month:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case TimeFilterPeriod.year:
        return DateTime(now.year, 12, 31, 23, 59, 59);
    }
  }

  List<String> get chartLabels {
    switch (this) {
      case TimeFilterPeriod.day:
        return ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM', '12AM'];
      case TimeFilterPeriod.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case TimeFilterPeriod.month:
        return ['W1', 'W2', 'W3', 'W4'];
      case TimeFilterPeriod.year:
        return ['Q1', 'Q2', 'Q3', 'Q4'];
    }
  }

  List<double> get mockChartData {
    switch (this) {
      case TimeFilterPeriod.day:
        return [1, 3, 2, 5, 8, 6, 4];
      case TimeFilterPeriod.week:
        return [1, 2, 0, 2, 3, 5, 7];
      case TimeFilterPeriod.month:
        return [12, 18, 15, 22];
      case TimeFilterPeriod.year:
        return [45, 62, 58, 71];
    }
  }
}

class TimeFilterNotifier extends StateNotifier<TimeFilterPeriod> {
  TimeFilterNotifier() : super(TimeFilterPeriod.week);

  void setPeriod(TimeFilterPeriod period) {
    state = period;
  }
}

final timeFilterProvider = StateNotifierProvider<TimeFilterNotifier, TimeFilterPeriod>((ref) {
  return TimeFilterNotifier();
});

// Provider for filtered orders based on time period
final filteredOrdersProvider = Provider((ref) {
  final orders = ref.watch(getOrdersProvider);
  final timeFilter = ref.watch(timeFilterProvider);
  
  return orders.when(
    data: (ordersList) {
      final startDate = timeFilter.startDate;
      final endDate = timeFilter.endDate;
      
      return ordersList.where((order) {
        return order.createdAt.isAfter(startDate) && order.createdAt.isBefore(endDate);
      }).toList();
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

// Provider for chart data based on time period
final chartDataProvider = Provider((ref) {
  final timeFilter = ref.watch(timeFilterProvider);
  final filteredOrders = ref.watch(filteredOrdersProvider);
  
  // For now, return mock data based on the time period
  // In a real app, you would calculate this from the filtered orders
  return {
    'labels': timeFilter.chartLabels,
    'data': timeFilter.mockChartData,
  };
});