import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/view/pages/verification_page.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/theme/app_theme.dart';
import 'package:fieldforce/utils/utilities.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/home/controller/dashboard_controller.dart';

// Performance monitoring
class PerformanceProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log provider updates for performance monitoring
    if (provider.name?.contains('currentUser') == true) {
      Loggers.config.debug('Provider updated: ${provider.name}');
    }
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    Loggers.config.error('Provider failed: ${provider.name}', error: error);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Performance optimizations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    Loggers.config.info('Environment variables loaded successfully');
  } catch (e) {
    Loggers.config.warning('Could not load .env file: $e');
    Loggers.config.info('Using default values for configuration');
  }

  runApp(
    ProviderScope(
      observers: [PerformanceProviderObserver()],
      child: const FieldForceApp(),
    ),
  );
}

class FieldForceApp extends StatelessWidget {
  const FieldForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FieldForce',
          theme: AppTheme.darkThemeMode,
          home: const AppRouter(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Separate router widget to optimize performance
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a single provider watch to reduce rebuilds
    final authState = ref.watch(appAuthStateProvider);

    return authState.when(
      data: (state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            if (state.isProfileComplete) {
              return const DashBoardController();
            } else {
              return const VerificationPage();
            }
          case AuthStatus.unauthenticated:
            return const SignInPage();
          case AuthStatus.loading:
            return const LoadingPage();
        }
      },
      loading: () => const LoadingPage(),
      error: (error, stackTrace) => ErrorPage(
        error: error.toString(),
      ),
    );
  }
}

// Combined auth state to reduce provider watchers
enum AuthStatus { loading, authenticated, unauthenticated }

class AppAuthState {
  final AuthStatus status;
  final bool isProfileComplete;
  final String? error;

  const AppAuthState({
    required this.status,
    this.isProfileComplete = false,
    this.error,
  });
}

// Single provider that combines auth and profile state
final appAuthStateProvider = FutureProvider<AppAuthState>((ref) async {
  try {
    final user = await ref.watch(currentUserProvider.future);

    if (user == null) {
      return const AppAuthState(status: AuthStatus.unauthenticated);
    }

    final isComplete = await ref.watch(isProfileCompleteProvider.future);

    return AppAuthState(
      status: AuthStatus.authenticated,
      isProfileComplete: isComplete,
    );
  } catch (e) {
    Loggers.config.error('Auth state error: $e');
    return const AppAuthState(status: AuthStatus.unauthenticated);
  }
});
