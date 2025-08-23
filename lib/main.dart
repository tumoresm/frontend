import 'package:fieldforce/features/splash/splash_screen.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/notifications/service/local_notification_service.dart';
import 'package:fieldforce/theme/app_theme.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;

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
    final providerName = provider.name ?? provider.runtimeType.toString();
    Loggers.config.error('Provider failed: $providerName', error: error, stackTrace: stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

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

  // Initialize notification service
  try {
    await LocalNotificationService().initialize(
      onNotificationTapped: (payload) {
        Loggers.config.info('Notification tapped: $payload');
        // Handle notification tap here
      },
    );
    await LocalNotificationService().createNotificationChannels();
    Loggers.config.info('Notification service initialized successfully');
  } catch (e) {
    Loggers.config.error('Failed to initialize notification service: $e');
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
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// AppRouter is now defined in splash_screen.dart

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
}, name: 'appAuthStateProvider');
