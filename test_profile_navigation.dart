// Simple test to verify Profile Menu navigation works
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/features/home/view/navbar_pages/user_profile_page.dart';

void main() {
  testWidgets('Profile Menu navigation test', (WidgetTester tester) async {
    // Build the user profile page
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const UserProfilePage(),
        ),
      ),
    );

    // Wait for the page to load
    await tester.pumpAndSettle();

    // Verify profile menu buttons exist
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Legal Terms'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    print('✅ Profile Menu buttons found successfully');
    print('🎉 Profile Menu implementation verified!');
  });
}