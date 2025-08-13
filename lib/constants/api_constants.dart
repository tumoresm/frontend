import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs - use environment variable or fallback
  static String get baseUrl {
    // Check if FastAPI URL is explicitly set in environment
    final fastApiUrl = dotenv.env['FASTAPI_ENDPOINT'];
    if (fastApiUrl != null && fastApiUrl.isNotEmpty) {
      return fastApiUrl;
    }
    
    // Default to the same host as Appwrite but on port 8000 for FastAPI
    final appwriteEndpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? 'http://192.168.100.5/v1';
    // Extract the host from Appwrite endpoint and use port 8000
    final uri = Uri.parse(appwriteEndpoint);
    return 'http://${uri.host}:8000';
  }

  // Auth endpoints
  static String get registerEndpoint => '$baseUrl/auth/register';
  static String get loginEndpoint => '$baseUrl/auth/login';
  
  // User profile endpoints
  static String updateProfileEndpoint(String userId) => '$baseUrl/users/$userId';
  static String getUserProfileEndpoint(String userId) => '$baseUrl/users/$userId';

  // Request timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
