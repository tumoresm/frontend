import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend-agnostic constants for the FieldForce application
/// This replaces Appwrite-specific constants with flexible backend configuration
class BackendConstants {
  // API Configuration
  static String get apiBaseUrl {
    final fastApiUrl = dotenv.env['FASTAPI_ENDPOINT'];
    if (fastApiUrl != null && fastApiUrl.isNotEmpty) {
      return fastApiUrl;
    }
    
    // Default to the same host as Appwrite but on port 8000 for FastAPI
    final appwriteEndpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? 'http://192.168.100.5/v1';
    final uri = Uri.parse(appwriteEndpoint);
    return 'http://${uri.host}:8000';
  }

  // Database Configuration
  static String get databaseId => dotenv.env['DATABASE_ID'] ?? 'fieldforce_db';
  
  // Storage Configuration
  static String get storageId => dotenv.env['STORAGE_ID'] ?? 'fieldforce_storage';

  // Request Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // Collection/Table names (backend-agnostic)
  static const String usersCollection = 'users';
  static const String companiesCollection = 'companies';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String ordersHistoryCollection = 'orders_history';
  static const String industriesCollection = 'industries';
  
  // Relationship tables
  static const String repCompanyRelationsCollection = 'rep_company_relations';
  
  // Wallet-related collections
  static const String walletsCollection = 'wallets';
  static const String transactionsCollection = 'transactions';
  static const String bankAccountsCollection = 'bank_accounts';
  static const String withdrawalRequestsCollection = 'withdrawal_requests';

  // API Endpoints
  static String get authEndpoint => '$apiBaseUrl/auth';
  static String get usersEndpoint => '$apiBaseUrl/users';
  static String get companiesEndpoint => '$apiBaseUrl/companies';
  static String get ordersEndpoint => '$apiBaseUrl/orders';
  static String get walletsEndpoint => '$apiBaseUrl/wallets';
  static String get transactionsEndpoint => '$apiBaseUrl/transactions';
  static String get industriesEndpoint => '$apiBaseUrl/industries';

  // Authentication endpoints
  static String get registerEndpoint => '$authEndpoint/register';
  static String get loginEndpoint => '$authEndpoint/login';
  static String get verifyEmailEndpoint => '$authEndpoint/verify-email';
  static String get resendVerificationEndpoint => '$authEndpoint/resend-verification';
  static String get refreshTokenEndpoint => '$authEndpoint/refresh';
  static String get logoutEndpoint => '$authEndpoint/logout';

  // User endpoints
  static String get updateProfileEndpoint => '$usersEndpoint/me';
  static String getUserProfileEndpoint(String userId) => '$usersEndpoint/$userId';
  static String get searchUsersEndpoint => '$usersEndpoint/search';
  static String get checkEmailEndpoint => '$usersEndpoint/check-email';

  // Company endpoints
  static String getCompanyEndpoint(String companyId) => '$companiesEndpoint/$companyId';
  static String getCompanyProductsEndpoint(String companyId) => '$companiesEndpoint/$companyId/products';

  // Order endpoints
  static String getOrderEndpoint(String orderId) => '$ordersEndpoint/$orderId';
  static String getRepOrdersEndpoint(String repId) => '$ordersEndpoint/rep/$repId';

  // Wallet endpoints
  static String getUserWalletEndpoint(String userId) => '$walletsEndpoint/$userId';
  static String getUserTransactionsEndpoint(String userId) => '$transactionsEndpoint/user/$userId';

  // File upload endpoints
  static String get uploadEndpoint => '$apiBaseUrl/upload';
  static String get profileImageUploadEndpoint => '$uploadEndpoint/profile-image';

  // Environment detection
  static bool get isDevelopment {
    final endpoint = apiBaseUrl;
    return endpoint.contains('localhost') ||
        endpoint.contains('192.168.') ||
        endpoint.contains('127.0.0.1') ||
        endpoint.contains('10.0.') ||
        endpoint.contains(':8000') ||
        endpoint.contains(':3000');
  }

  static bool get isProduction => !isDevelopment;

  // Logging configuration
  static bool get enableDebugLogging => isDevelopment;
  static bool get enableNetworkLogging => isDevelopment;

  // Cache configuration
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxCacheSize = 100;

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 500;
  static const int maxDescriptionLength = 1000;

  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Business logic constants
  static const double minCommissionRate = 0.0;
  static const double maxCommissionRate = 100.0;
  static const double minOrderAmount = 0.01;
  static const double maxOrderAmount = 1000000.0;
  static const double minWithdrawalAmount = 10.0;
  static const double maxWithdrawalAmount = 50000.0;

  // Session configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshTokenLifetime = Duration(days: 30);
  static const Duration accessTokenLifetime = Duration(hours: 1);

  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxLoginAttemptsPerHour = 5;

  // Feature flags
  static bool get enableOfflineMode => false; // Future feature
  static bool get enablePushNotifications => false; // Future feature
  static bool get enableAnalytics => false; // Future feature
  static bool get enableCrashReporting => isProduction;

  // Version information
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';
  static const String minSupportedApiVersion = 'v1';

  // Error codes
  static const String errorCodeUnauthorized = 'UNAUTHORIZED';
  static const String errorCodeForbidden = 'FORBIDDEN';
  static const String errorCodeNotFound = 'NOT_FOUND';
  static const String errorCodeValidationError = 'VALIDATION_ERROR';
  static const String errorCodeServerError = 'SERVER_ERROR';
  static const String errorCodeNetworkError = 'NETWORK_ERROR';
  static const String errorCodeTimeout = 'TIMEOUT';

  // Success codes
  static const String successCodeCreated = 'CREATED';
  static const String successCodeUpdated = 'UPDATED';
  static const String successCodeDeleted = 'DELETED';
  static const String successCodeVerified = 'VERIFIED';

  // Notification types
  static const String notificationTypeOrderUpdate = 'ORDER_UPDATE';
  static const String notificationTypePayment = 'PAYMENT';
  static const String notificationTypeVerification = 'VERIFICATION';
  static const String notificationTypePromotion = 'PROMOTION';

  // User roles
  static const String roleRep = 'Rep';
  static const String roleAdmin = 'Admin';
  static const String roleManager = 'Manager';
  static const String roleSupport = 'Support';

  // Order statuses
  static const String orderStatusPending = 'pending';
  static const String orderStatusApproved = 'approved';
  static const String orderStatusPaid = 'paid';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusRejected = 'rejected';
  static const String orderStatusCancelled = 'cancelled';

  // Transaction types
  static const String transactionTypeEarning = 'earning';
  static const String transactionTypePayment = 'payment';
  static const String transactionTypeWithdrawal = 'withdrawal';
  static const String transactionTypeRefund = 'refund';
  static const String transactionTypeCommission = 'commission';
  static const String transactionTypeBonus = 'bonus';

  // Verification statuses
  static const String verificationStatusUnverified = 'unverified';
  static const String verificationStatusPending = 'pending';
  static const String verificationStatusVerified = 'verified';
  static const String verificationStatusRejected = 'rejected';

  // Withdrawal statuses
  static const String withdrawalStatusPending = 'pending';
  static const String withdrawalStatusApproved = 'approved';
  static const String withdrawalStatusProcessing = 'processing';
  static const String withdrawalStatusCompleted = 'completed';
  static const String withdrawalStatusFailed = 'failed';
  static const String withdrawalStatusCancelled = 'cancelled';
  static const String withdrawalStatusRejected = 'rejected';
}