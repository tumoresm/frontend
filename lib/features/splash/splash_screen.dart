import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:fieldforce/constants/assets_constants.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:fieldforce/features/auth/view/pages/verification_page.dart';
import 'package:fieldforce/main.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:fieldforce/utils/utilities.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Expanded(
              flex: 3,
              child: Lottie.asset(
                AssetsConstants.animeSplash,
                fit: BoxFit.contain,
                repeat: true,
                reverse: false,
                animate: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // App title
          const Text(
            'FieldForce',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kPrimary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          const Text(
            'Sales Tracking Made Simple',
            style: TextStyle(
              fontSize: 16,
              color: Colours.greyColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          // Loading indicator
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colours.gradient1),
            ),
          ),
          const Spacer(),
        ],
      ),
      nextScreen: const AppRouter(),
      splashIconSize: double.infinity,
      duration: 3000, // 3 seconds
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Colours.whiteColor,
      animationDuration: const Duration(milliseconds: 1000),
    );
  }
}

// Enhanced App Router with better state management
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a single provider watch to reduce rebuilds
    final authState = ref.watch(appAuthStateProvider);

    return authState.when(
      data: (state) {
        Loggers.config.info('Auth state: ${state.status}');

        switch (state.status) {
          case AuthStatus.authenticated:
            if (state.isProfileComplete) {
              Loggers.config.info(
                  'User authenticated and profile complete - navigating to dashboard');
              return const DashBoardController();
            } else {
              Loggers.config.info(
                  'User authenticated but profile incomplete - navigating to verification');
              return const VerificationPage();
            }
          case AuthStatus.unauthenticated:
            Loggers.config.info('User unauthenticated - navigating to sign in');
            return const SignInPage();
          case AuthStatus.loading:
            Loggers.config.info('Auth state loading - showing loading page');
            return const LoadingPage();
        }
      },
      loading: () {
        Loggers.config
            .info('Auth state provider loading - showing loading page');
        return const LoadingPage();
      },
      error: (error, stackTrace) {
        Loggers.config.error('Auth state error: $error',
            error: error, stackTrace: stackTrace);
        return ErrorPage(
          error: error.toString(),
        );
      },
    );
  }
}

// Enhanced loading page for better UX during auth state loading
class EnhancedLoadingPage extends StatelessWidget {
  const EnhancedLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Smaller Lottie animation for loading state
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                'assets/anime/sales_trackerSplash.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Colours.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colours.gradient1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
