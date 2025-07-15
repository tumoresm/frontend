import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/viewmodel/auth_controller.dart';
import 'package:fieldforce/theme/app_theme.dart';
import 'package:fieldforce/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/view/pages/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FieldForceApp(),
    ),
  );
}

class FieldForceApp extends ConsumerWidget {
  const FieldForceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FieldForce',
      theme: AppTheme.darkThemeMode,
      home: ref.watch(currentUserProvider).when(
            data: (user) {
              if (user != null) {
                return const HomePage();
              }
              return const SignInPage();
            },
            error: (error, st) => ErrorPage(
              error: error.toString(),
            ),
            loading: () => const LoadingPage(),
          ),
      debugShowCheckedModeBanner: false,
    );
  }
}
