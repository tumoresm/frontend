import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/core/secure_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure providers that ensure proper authentication and user data isolation
class SecureProviders {
  /// Provider for secure Appwrite client
  static final secureClientProvider = Provider<Client>((ref) {
    return SecureAppwriteClient.client;
  });

  /// Provider for secure account service
  static final secureAccountProvider = Provider<Account>((ref) {
    return SecureAppwriteClient.account;
  });

  /// Provider for secure databases service
  static final secureDatabasesProvider = Provider<Databases>((ref) {
    return SecureAppwriteClient.databases;
  });

  /// Provider for current user ID
  static final currentUserIdProvider = StateProvider<String?>((ref) {
    return SecureAppwriteClient.currentUserId;
  });

  /// Provider for authentication state
  static final authStateProvider =
      StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
    return AuthStateNotifier();
  });
}

/// Authentication state
enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState.unauthenticated);

  /// Set authentication state
  void setAuthState(AuthState newState) {
    state = newState;
    Loggers.auth.debug('Auth state changed to: $newState');
  }

  /// Handle successful authentication
  void onAuthSuccess(String userId, String sessionId) {
    SecureAppwriteClient.setCurrentUserId(userId);
    SecureAppwriteClient.setSession(sessionId);
    state = AuthState.authenticated;
    Loggers.auth.info('User authenticated successfully: $userId');
  }

  /// Handle authentication failure
  void onAuthFailure() {
    SecureAppwriteClient.clearSession();
    state = AuthState.error;
    Loggers.auth.warning('Authentication failed');
  }

  /// Handle logout
  void onLogout() {
    SecureAppwriteClient.clearSession();
    state = AuthState.unauthenticated;
    Loggers.auth.info('User logged out');
  }
}

/// Secure repository base class
abstract class SecureRepository {
  final Databases _databases;
  final String _databaseId;

  SecureRepository(this._databases, this._databaseId);

  /// Create document with security
  Future<Document> createSecureDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      return await SecureAppwriteClient.createDocumentWithPermissions(
        databaseId: _databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
        permissions: permissions,
      );
    } catch (e) {
      Loggers.database
          .error('Failed to create secure document in $collectionId', error: e);
      rethrow;
    }
  }

  /// Get document with security
  Future<Document> getSecureDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      return await SecureAppwriteClient.getDocumentSecure(
        databaseId: _databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      Loggers.database
          .error('Failed to get secure document from $collectionId', error: e);
      rethrow;
    }
  }

  /// List documents with security
  Future<DocumentList> listSecureDocuments({
    required String collectionId,
    List<String>? queries,
  }) async {
    try {
      return await SecureAppwriteClient.listDocumentsSecure(
        databaseId: _databaseId,
        collectionId: collectionId,
        queries: queries,
      );
    } catch (e) {
      Loggers.database.error(
          'Failed to list secure documents from $collectionId',
          error: e);
      rethrow;
    }
  }

  /// Update document with security
  Future<Document> updateSecureDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      return await SecureAppwriteClient.updateDocumentSecure(
        databaseId: _databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
        permissions: permissions,
      );
    } catch (e) {
      Loggers.database
          .error('Failed to update secure document in $collectionId', error: e);
      rethrow;
    }
  }

  /// Delete document with security
  Future<void> deleteSecureDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await SecureAppwriteClient.deleteDocumentSecure(
        databaseId: _databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      Loggers.database.error(
          'Failed to delete secure document from $collectionId',
          error: e);
      rethrow;
    }
  }
}

/// Secure user repository
class SecureUserRepository extends SecureRepository {
  SecureUserRepository(super.databases, super.databaseId);

  /// Get current user's profile
  Future<Document> getCurrentUserProfile() async {
    final userId = SecureAppwriteClient.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await getSecureDocument(
      collectionId: AppwriteConstants.usersCollection,
      documentId: userId,
    );
  }

  /// Update current user's profile
  Future<Document> updateCurrentUserProfile(Map<String, dynamic> data) async {
    final userId = SecureAppwriteClient.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await updateSecureDocument(
      collectionId: AppwriteConstants.usersCollection,
      documentId: userId,
      data: data,
    );
  }
}

/// Secure orders repository
class SecureOrdersRepository extends SecureRepository {
  SecureOrdersRepository(super.databases, super.databaseId);

  /// Create a new order
  Future<Document> createOrder(Map<String, dynamic> orderData) async {
    final userId = SecureAppwriteClient.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Ensure the order is associated with the current user
    orderData['repId'] = userId;
    orderData['createdAt'] = DateTime.now().toIso8601String();
    orderData['updatedAt'] = DateTime.now().toIso8601String();

    return await createSecureDocument(
      collectionId: AppwriteConstants.ordersCollection,
      documentId: 'unique()',
      data: orderData,
    );
  }

  /// Get user's orders
  Future<DocumentList> getUserOrders() async {
    return await listSecureDocuments(
      collectionId: AppwriteConstants.ordersCollection,
    );
  }

  /// Get specific order
  Future<Document> getOrder(String orderId) async {
    return await getSecureDocument(
      collectionId: AppwriteConstants.ordersCollection,
      documentId: orderId,
    );
  }

  /// Update order
  Future<Document> updateOrder(
      String orderId, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();

    return await updateSecureDocument(
      collectionId: AppwriteConstants.ordersCollection,
      documentId: orderId,
      data: data,
    );
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    await deleteSecureDocument(
      collectionId: AppwriteConstants.ordersCollection,
      documentId: orderId,
    );
  }
}

/// Secure companies repository
class SecureCompaniesRepository extends SecureRepository {
  SecureCompaniesRepository(super.databases, super.databaseId);

  /// Create a new company
  Future<Document> createCompany(Map<String, dynamic> companyData) async {
    final userId = SecureAppwriteClient.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Ensure the company is associated with the current user
    companyData['createdBy'] = userId;

    return await createSecureDocument(
      collectionId: AppwriteConstants.companyCollection,
      documentId: 'unique()',
      data: companyData,
    );
  }

  /// Get all companies (public data)
  Future<DocumentList> getAllCompanies() async {
    return await listSecureDocuments(
      collectionId: AppwriteConstants.companyCollection,
    );
  }

  /// Get user's companies
  Future<DocumentList> getUserCompanies() async {
    final userId = SecureAppwriteClient.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await listSecureDocuments(
      collectionId: AppwriteConstants.companyCollection,
      queries: ['equal("createdBy", "$userId")'],
    );
  }

  /// Update company
  Future<Document> updateCompany(
      String companyId, Map<String, dynamic> data) async {
    return await updateSecureDocument(
      collectionId: AppwriteConstants.companyCollection,
      documentId: companyId,
      data: data,
    );
  }
}

/// Provider for secure user repository
final secureUserRepositoryProvider = Provider<SecureUserRepository>((ref) {
  final databases = ref.watch(SecureProviders.secureDatabasesProvider);
  return SecureUserRepository(databases, AppwriteConstants.databaseId);
});

/// Provider for secure orders repository
final secureOrdersRepositoryProvider = Provider<SecureOrdersRepository>((ref) {
  final databases = ref.watch(SecureProviders.secureDatabasesProvider);
  return SecureOrdersRepository(databases, AppwriteConstants.databaseId);
});

/// Provider for secure companies repository
final secureCompaniesRepositoryProvider =
    Provider<SecureCompaniesRepository>((ref) {
  final databases = ref.watch(SecureProviders.secureDatabasesProvider);
  return SecureCompaniesRepository(databases, AppwriteConstants.databaseId);
});
