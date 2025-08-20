import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fieldforce/features/home/view/navbar_pages/home_page.dart';
import 'package:fieldforce/features/home/provider/time_filter_provider.dart';
import 'package:fieldforce/features/home/view/widgets/time_filter_buttons.dart';

void main() {
  group('Responsive Home Page Tests', () {
    Widget createTestWidget(Widget child, {Size? screenSize}) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        child: ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: screenSize ?? const Size(375, 812),
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('HomePage renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(const HomePage()),
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('TimeFilterRow renders all filter options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(const TimeFilterRow()),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
    });

    testWidgets('TimeFilter changes when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Consumer(
            builder: (context, ref, child) {
              final timeFilter = ref.watch(timeFilterProvider);
              return Column(
                children: [
                  Text('Current: ${timeFilter.displayName}'),
                  const TimeFilterRow(),
                ],
              );
            },
          ),
        ),
      );

      // Initially should be Week
      expect(find.text('Current: Week'), findsOneWidget);

      // Tap on Month
      await tester.tap(find.text('Month'));
      await tester.pump();

      // Should now be Month
      expect(find.text('Current: Month'), findsOneWidget);
    });

    testWidgets('HomePage adapts to small screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const HomePage(),
          screenSize: const Size(320, 568), // Small screen
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('HomePage adapts to large screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const HomePage(),
          screenSize: const Size(768, 1024), // Large screen
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    group('TimeFilterPeriod Extension Tests', () {
      test('displayName returns correct values', () {
        expect(TimeFilterPeriod.day.displayName, equals('Day'));
        expect(TimeFilterPeriod.week.displayName, equals('Week'));
        expect(TimeFilterPeriod.month.displayName, equals('Month'));
        expect(TimeFilterPeriod.year.displayName, equals('Year'));
      });

      test('chartLabels returns correct values', () {
        expect(TimeFilterPeriod.day.chartLabels.length, equals(7));
        expect(TimeFilterPeriod.week.chartLabels.length, equals(7));
        expect(TimeFilterPeriod.month.chartLabels.length, equals(4));
        expect(TimeFilterPeriod.year.chartLabels.length, equals(4));
      });

      test('mockChartData returns correct values', () {
        expect(TimeFilterPeriod.day.mockChartData.length, equals(7));
        expect(TimeFilterPeriod.week.mockChartData.length, equals(7));
        expect(TimeFilterPeriod.month.mockChartData.length, equals(4));
        expect(TimeFilterPeriod.year.mockChartData.length, equals(4));
      });

      test('startDate and endDate are valid', () {
        final now = DateTime.now();
        
        // Day
        final dayStart = TimeFilterPeriod.day.startDate;
        final dayEnd = TimeFilterPeriod.day.endDate;
        expect(dayStart.isBefore(dayEnd), isTrue);
        expect(dayStart.day, equals(now.day));
        
        // Week
        final weekStart = TimeFilterPeriod.week.startDate;
        final weekEnd = TimeFilterPeriod.week.endDate;
        expect(weekStart.isBefore(weekEnd), isTrue);
        
        // Month
        final monthStart = TimeFilterPeriod.month.startDate;
        final monthEnd = TimeFilterPeriod.month.endDate;
        expect(monthStart.isBefore(monthEnd), isTrue);
        expect(monthStart.day, equals(1));
        
        // Year
        final yearStart = TimeFilterPeriod.year.startDate;
        final yearEnd = TimeFilterPeriod.year.endDate;
        expect(yearStart.isBefore(yearEnd), isTrue);
        expect(yearStart.month, equals(1));
        expect(yearStart.day, equals(1));
      });
    });
  });
}