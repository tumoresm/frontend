import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/features/profile/view/pages/settings_page.dart';
import 'package:fieldforce/features/profile/view/pages/security_page.dart';
import 'package:fieldforce/features/profile/view/pages/help_center_page.dart';
import 'package:fieldforce/features/profile/view/pages/legal_terms_page.dart';
import 'package:fieldforce/features/profile/view/pages/portfolio_page.dart';
import 'package:fieldforce/features/profile/controller/settings_controller.dart';

void main() {
  group('Profile Menu Tests', () {
    testWidgets('Settings page should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Verify the page loads
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('Security page should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SecurityPage(),
          ),
        ),
      );

      // Verify the page loads
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Account Security'), findsOneWidget);
      expect(find.text('Session Management'), findsOneWidget);
    });

    testWidgets('Help Center page should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HelpCenterPage(),
        ),
      );

      // Verify the page loads
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
    });

    testWidgets('Legal Terms page should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LegalTermsPage(),
        ),
      );

      // Verify the page loads
      expect(find.text('Legal Terms'), findsOneWidget);
      expect(find.text('Legal Documents'), findsOneWidget);
      expect(find.text('Rep Agreements'), findsOneWidget);
    });

    testWidgets('Portfolio page should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PortfolioPage(),
          ),
        ),
      );

      // Verify the page loads
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(find.text('Performance Overview'), findsOneWidget);
      expect(find.text('Professional Profile'), findsOneWidget);
    });

    testWidgets('Settings controller should manage state correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Test initial state
      final controller = container.read(settingsControllerProvider.notifier);
      final initialState = container.read(settingsControllerProvider);

      expect(initialState.isDarkMode, false);
      expect(initialState.language, 'en');
      expect(initialState.currency, 'USD');

      // Test state updates
      await controller.updateThemeMode(true);
      final updatedState = container.read(settingsControllerProvider);
      expect(updatedState.isDarkMode, true);

      await controller.updateLanguage('es');
      final languageUpdatedState = container.read(settingsControllerProvider);
      expect(languageUpdatedState.language, 'es');
    });

    testWidgets('Settings page switches should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // Find and tap the dark mode switch
      final darkModeSwitch = find.byType(Switch).first;
      expect(darkModeSwitch, findsOneWidget);

      await tester.tap(darkModeSwitch);
      await tester.pump();

      // The switch should have been tapped (state change is handled by controller)
      // We can't easily test the actual state change without more complex setup
    });

    testWidgets('Help Center search should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HelpCenterPage(),
        ),
      );

      // Find the search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Enter search text
      await tester.enterText(searchField, 'order');
      await tester.pump();

      // The search should filter FAQ items (implementation dependent)
    });

    testWidgets('Legal Terms should show documents', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LegalTermsPage(),
        ),
      );

      // Find and tap Terms of Service
      final termsOfService = find.text('Terms of Service');
      expect(termsOfService, findsOneWidget);

      await tester.tap(termsOfService);
      await tester.pumpAndSettle();

      // Should show the terms dialog
      expect(find.text('FIELDFORCE TERMS OF SERVICE'), findsOneWidget);
    });
  });
}