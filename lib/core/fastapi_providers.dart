import 'package:fieldforce/core/session_manager.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// FastAPI-based providers that replace Appwrite infrastructure
/// These providers use JWT tokens and session management instead of Appwrite

/// Provider for HTTP client with authentication
final authenticatedHttpClientProvider = Provider<AuthenticatedHttpClient>((ref) {
  return AuthenticatedHttpClient();
});

/// Provider for current user session state
final sessionStateProvider = StateNotifierProvider<SessionStateNotifier, SessionState>((ref) {
  return SessionStateNotifier();
});

/// Provider for authentication headers
final authHeadersProvider = FutureProvider<Map<String, String>>((ref) async {
  return await SessionManager.instance.getAuthHeaders();
});

/// Provider for current user ID from session
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  try {
    final userData = await SessionManager.instance.getUserData();
    return userData?['userId'] as String?;
  } catch (e) {
    Loggers.auth.debug('No current user ID found: $e');
    return null;
  }
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  return await SessionManager.instance.isLoggedIn();
});

/// Session state enum
enum SessionState {
  unauthenticated,
  authenticating,
  authenticated,
  error,
  expired,
}

/// Session state notifier for FastAPI authentication
class SessionStateNotifier extends StateNotifier<SessionState> {
  SessionStateNotifier() : super(SessionState.unauthenticated) {
    _checkInitialAuthState();
  }

  /// Check initial authentication state
  Future<void> _checkInitialAuthState() async {
    try {
      final isLoggedIn = await SessionManager.instance.isLoggedIn();
      if (isLoggedIn) {
        final userData = await SessionManager.instance.getUserData();
        if (userData != null) {
          state = SessionState.authenticated;
          Loggers.auth.info('Initial auth state: authenticated');
        } else {
          state = SessionState.unauthenticated;
          Loggers.auth.info('Initial auth state: unauthenticated (no user data)');
        }
      } else {
        state = SessionState.unauthenticated;
        Loggers.auth.info('Initial auth state: unauthenticated');
      }
    } catch (e) {
      Loggers.auth.error('Error checking initial auth state: $e');
      state = SessionState.error;
    }
  }

  /// Set authentication state
  void setAuthState(SessionState newState) {
    state = newState;
    Loggers.auth.debug('Session state changed to: $newState');
  }

  /// Handle successful authentication
  void onAuthSuccess() {
    state = SessionState.authenticated;
    Loggers.auth.info('User authenticated successfully');
  }

  /// Handle authentication failure
  void onAuthFailure() {
    state = SessionState.error;
    Loggers.auth.warning('Authentication failed');
  }

  /// Handle logout
  void onLogout() {
    state = SessionState.unauthenticated;
    Loggers.auth.info('User logged out');
  }

  /// Handle session expiry
  void onSessionExpired() {
    state = SessionState.expired;
    Loggers.auth.warning('Session expired');
  }

  /// Set authenticating state
  void setAuthenticating() {
    state = SessionState.authenticating;
    Loggers.auth.debug('Setting authenticating state');
  }
}

/// HTTP client with automatic authentication
class AuthenticatedHttpClient {
  /// Make authenticated GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final headers = await _getHeaders(additionalHeaders);
    final uri = _buildUri(endpoint);
    
    Loggers.network.debug('GET request to: $uri');
    
    return await http.get(
      uri,
      headers: headers,
    ).timeout(timeout ?? ApiConstants.requestTimeout);
  }

  /// Make authenticated POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final headers = await _getHeaders(additionalHeaders);
    final uri = _buildUri(endpoint);
    
    Loggers.network.debug('POST request to: $uri');
    
    return await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout ?? ApiConstants.requestTimeout);
  }

  /// Make authenticated PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final headers = await _getHeaders(additionalHeaders);
    final uri = _buildUri(endpoint);
    
    Loggers.network.debug('PATCH request to: $uri');
    
    return await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout ?? ApiConstants.requestTimeout);
  }

  /// Make authenticated PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final headers = await _getHeaders(additionalHeaders);
    final uri = _buildUri(endpoint);
    
    Loggers.network.debug('PUT request to: $uri');
    
    return await http.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout ?? ApiConstants.requestTimeout);
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final headers = await _getHeaders(additionalHeaders);
    final uri = _buildUri(endpoint);
    
    Loggers.network.debug('DELETE request to: $uri');
    
    return await http.delete(
      uri,
      headers: headers,
    ).timeout(timeout ?? ApiConstants.requestTimeout);
  }

  /// Get headers with authentication
  Future<Map<String, String>> _getHeaders(Map<String, String>? additionalHeaders) async {
    final authHeaders = await SessionManager.instance.getAuthHeaders();
    final headers = Map<String, String>.from(authHeaders);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  /// Build URI from endpoint
  Uri _buildUri(String endpoint) {
    if (endpoint.startsWith('http')) {
      return Uri.parse(endpoint);
    } else {
      return Uri.parse('${ApiConstants.baseUrl}$endpoint');
    }
  }
}

/// Base repository class for FastAPI operations
abstract class FastAPIRepository {
  final AuthenticatedHttpClient _httpClient;

  FastAPIRepository(this._httpClient);

  /// Handle API response and extract data
  T handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String? operation,
  }) {
    final operationName = operation ?? 'API operation';
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        
        if (data is Map<String, dynamic>) {
          return fromJson(data);
        } else {
          throw Exception('Invalid response format for $operationName');
        }
      } catch (e) {
        Loggers.database.error('Error parsing response for $operationName: $e');
        throw Exception('Failed to parse response for $operationName');
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
      Loggers.database.error('$operationName failed: HTTP ${response.statusCode}: $errorMessage');
      throw Exception('$operationName failed: $errorMessage');
    }
  }

  /// Handle API response for list operations
  List<T> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String? operation,
  }) {
    final operationName = operation ?? 'API list operation';
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseData = jsonDecode(response.body);
        List<dynamic> dataList;
        
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          dataList = responseData['data'] ?? responseData['items'] ?? [];
        } else {
          throw Exception('Invalid response format for $operationName');
        }
        
        return dataList
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        Loggers.database.error('Error parsing list response for $operationName: $e');
        throw Exception('Failed to parse list response for $operationName');
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
      Loggers.database.error('$operationName failed: HTTP ${response.statusCode}: $errorMessage');
      throw Exception('$operationName failed: $errorMessage');
    }
  }

  /// Handle void API responses
  void handleVoidResponse(
    http.Response response, {
    String? operation,
  }) {
    final operationName = operation ?? 'API operation';
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Loggers.database.info('$operationName completed successfully');
      return;
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
      Loggers.database.error('$operationName failed: HTTP ${response.statusCode}: $errorMessage');
      throw Exception('$operationName failed: $errorMessage');
    }
  }
}

/// Security utilities for FastAPI operations
class FastAPISecurity {
  /// Validate user access to resource
  static Future<bool> validateUserAccess(String resourceUserId) async {
    try {
      final userData = await SessionManager.instance.getUserData();
      final currentUserId = userData?['userId'] as String?;
      
      if (currentUserId == null) {
        Loggers.auth.warning('No current user ID found for access validation');
        return false;
      }
      
      final hasAccess = currentUserId == resourceUserId;
      if (!hasAccess) {
        Loggers.auth.warning('Access denied: User $currentUserId cannot access resource owned by $resourceUserId');
      }
      
      return hasAccess;
    } catch (e) {
      Loggers.auth.error('Error validating user access: $e');
      return false;
    }
  }

  /// Get current user ID safely
  static Future<String?> getCurrentUserId() async {
    try {
      final userData = await SessionManager.instance.getUserData();
      return userData?['userId'] as String?;
    } catch (e) {
      Loggers.auth.debug('No current user ID found: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      return await SessionManager.instance.isLoggedIn();
    } catch (e) {
      Loggers.auth.debug('Error checking authentication: $e');
      return false;
    }
  }

  /// Ensure user is authenticated
  static Future<void> ensureAuthenticated() async {
    final isAuth = await isAuthenticated();
    if (!isAuth) {
      throw Exception('User not authenticated');
    }
  }
}

/// Provider for FastAPI security utilities
final fastapiSecurityProvider = Provider<FastAPISecurity>((ref) {
  return FastAPISecurity();
});