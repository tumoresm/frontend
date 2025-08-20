import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fieldforce/features/home/view/widgets/earningscard.dart';

void main() {
  group('EarningsCard Responsive Tests', () {
    Widget createTestWidget(Widget child, {Size? screenSize}) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: screenSize ?? const Size(375, 812),
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('EarningsCard renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 25058.00,
            totalPaid: 10200.00,
          ),
        ),
      );

      expect(find.byType(EarningsCard), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('R25058.00'), findsOneWidget);
      expect(find.text('R10200.00'), findsOneWidget);
    });

    testWidgets('EarningsCard shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Total Earnings'), findsNothing);
      expect(find.text('Total Paid'), findsNothing);
    });

    testWidgets('EarningsCard handles null values gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(),
        ),
      );

      expect(find.byType(EarningsCard), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      // Should show default values
      expect(find.text('R25058.00'), findsOneWidget);
      expect(find.text('R10200.00'), findsOneWidget);
    });

    testWidgets('EarningsCard adapts to small screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 1000.50,
            totalPaid: 500.25,
          ),
          screenSize: const Size(320, 568), // Small screen
        ),
      );

      expect(find.byType(EarningsCard), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('R1000.50'), findsOneWidget);
      expect(find.text('R500.25'), findsOneWidget);
    });

    testWidgets('EarningsCard adapts to large screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 50000.75,
            totalPaid: 25000.25,
          ),
          screenSize: const Size(768, 1024), // Large screen
        ),
      );

      expect(find.byType(EarningsCard), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('R50000.75'), findsOneWidget);
      expect(find.text('R25000.25'), findsOneWidget);
    });

    testWidgets('EarningsCard has proper gradient and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 15000.00,
            totalPaid: 8000.00,
          ),
        ),
      );

      // Find the container with gradient
      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Check that it has a gradient
      expect(decoration.gradient, isA<LinearGradient>());
      
      // Check that it has border radius
      expect(decoration.borderRadius, isA<BorderRadius>());
      
      // Check that it has box shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets('EarningsCard text scales properly with FittedBox', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 999999.99,
            totalPaid: 888888.88,
          ),
        ),
      );

      // Find FittedBox widgets that should contain the amount text
      final fittedBoxes = find.byType(FittedBox);
      expect(fittedBoxes, findsAtLeastNWidgets(2)); // One for each amount

      // Verify the amounts are displayed
      expect(find.text('R999999.99'), findsOneWidget);
      expect(find.text('R888888.88'), findsOneWidget);
    });

    testWidgets('EarningsCard has proper icon display', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 5000.00,
            totalPaid: 2500.00,
          ),
        ),
      );

      // Should have icons for both sections
      final icons = find.byType(Icon);
      expect(icons, findsAtLeastNWidgets(2));
    });

    testWidgets('EarningsCard divider is properly positioned', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EarningsCard(
            totalEarnings: 3000.00,
            totalPaid: 1500.00,
          ),
        ),
      );

      // Find the divider container
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(1));

      // The card should have a Row with two Expanded widgets
      final rows = find.byType(Row);
      expect(rows, findsAtLeastNWidgets(1));

      final expandedWidgets = find.byType(Expanded);
      expect(expandedWidgets, findsAtLeastNWidgets(2)); // Two sections
    });
  });
}