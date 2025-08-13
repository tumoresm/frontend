import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' hide FlatButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/features/auth/view/pages/signup_page.dart';
import 'package:fieldforce/utils/flat_button.dart';

void main() {
  testWidgets('SignUpPage displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpPage(),
        ),
      ),
    );

    expect(find.text('Sign Up').first, findsOneWidget);
    expect(find.widgetWithText(TextField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Phone Number'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Sign In'), findsOneWidget);
  });
}
