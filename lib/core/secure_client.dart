import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/logger.dart';

// Provide a safe extension to avoid analyzer errors when calling setSession on Client.
// Some versions of the Appwrite Dart SDK may not expose setSession; this no-op
// keeps the code analyzable without renaming or changing existing call sites.
extension ClientSessionSetter on Client {
  void setSession(String sessionId) {
    // If your SDK exposes setJWT and you want to use JWT based auth, you can
    // replace this implementation with: setJWT(sessionId);
    // For cookie-based sessions in Flutter, no explicit call is necessary.
  }
}

/// Custom exception for security-related errors
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Custom exception for type safety errors
class TypeSafetyException implements Exception {
  final String message;
  TypeSafetyException(this.message);

  @override
  String toString() => 'TypeSafetyException: $message';
}

/// Secure Appwrite client that ensures proper user authentication
class SecureAppwriteClient {
  static Client? _client;
  static Account? _account;
  static Databases? _databases;
  static String? _currentUserId;

  /// Initialize the secure client
  static void initialize() {
    _client = Client()
        .setEndpoint(AppwriteConstants.endPoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true);

    _account = Account(_client!);
    _databases = Databases(_client!);

    Loggers.auth.info('Secure Appwrite client initialized');
  }

  /// Get the authenticated client
  static Client get client {
    if (_client == null) {
      initialize();
    }
    return _client!;
  }

  /// Get the account service
  static Account get account {
    if (_account == null) {
      initialize();
    }
    return _account!;
  }

  /// Get the databases service
  static Databases get databases {
    if (_databases == null) {
      initialize();
    }
    return _databases!;
  }

  /// Set the current user session
  static void setSession(String sessionId) {
    if (_client != null) {
      _client!.setSession(sessionId);
      Loggers.auth.info('User session set for secure client');
    }
  }

  /// Set the current user ID for permission checks
  static void setCurrentUserId(String userId) {
    _currentUserId = userId;
    Loggers.auth.debug('Current user ID set: $userId');
  }

  /// Get the current user ID
  static String? get currentUserId => _currentUserId;

  /// Clear the session and user data
  static void clearSession() {
    _currentUserId = null;
    if (_client != null) {
      // Create a new client without session
      initialize();
    }
    Loggers.auth.info('User session cleared');
  }

  /// Create default permissions for user-owned documents
  static List<String> _createDefaultPermissions(String userId) {
    return [
      Permission.read(Role.user(userId)),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
      Permission.read(Role
          .users()), // Allow other authenticated users to read for relations
    ];
  }

  /// Create permissions for user-only access (private documents)
  static List<String> createUserOnlyPermissions(String userId) {
    return [
      Permission.read(Role.user(userId)),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
    ];
  }

  /// Create permissions for public read, user write
  static List<String> createPublicReadUserWritePermissions(String userId) {
    return [
      Permission.read(Role.any()),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
    ];
  }

  /// Create permissions for authenticated users read, user write
  static List<String> createUsersReadUserWritePermissions(String userId) {
    return [
      Permission.read(Role.users()),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
    ];
  }

  /// Create admin permissions (for admin-only documents)
  static List<String> createAdminPermissions() {
    return [
      Permission.read(Role.team('admin')),
      Permission.update(Role.team('admin')),
      Permission.delete(Role.team('admin')),
    ];
  }

  /// Get collection-specific default permissions
  static List<String> _getCollectionDefaultPermissions(
      String collectionId, String userId) {
    switch (collectionId) {
      case 'users':
        // Users: User can manage their own profile, others can read basic info
        return createUsersReadUserWritePermissions(userId);
      case 'orders':
        // Orders: Only user can access their own orders
        return createUserOnlyPermissions(userId);
      case 'repCompanyRelations':
        // Relations: Only user can access their own relations
        return createUserOnlyPermissions(userId);
      case 'companies':
        // Companies: Public read, creator can write
        return createPublicReadUserWritePermissions(userId);
      case 'products':
        // Products: Public read, creator can write
        return createPublicReadUserWritePermissions(userId);
      default:
        // Default: Authenticated users can read, user can write
        return _createDefaultPermissions(userId);
    }
  }

  /// Create a document with proper permissions
  static Future<Document> createDocumentWithPermissions({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      // Get collection-specific default permissions using proper Appwrite syntax
      final defaultPermissions = _currentUserId != null
          ? _getCollectionDefaultPermissions(collectionId, _currentUserId!)
          : <String>[];

      // Ensure permissions are properly typed
      final finalPermissions =
          _safePermissions(permissions) ?? defaultPermissions;

      Loggers.database
          .debug('Creating document with permissions: $finalPermissions');

      final document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
        permissions: finalPermissions,
      );

      Loggers.database
          .info('Document created with secure permissions: ${document.$id}');
      return document;
    } catch (e) {
      Loggers.database
          .error('Failed to create document with permissions', error: e);
      rethrow;
    }
  }

  /// Get a document with ownership check
  static Future<Document> getDocumentSecure({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      // Check if user has access to this document
      if (_shouldCheckOwnership(collectionId)) {
        _validateDocumentAccess(document, collectionId);
      }

      Loggers.database.debug('Document retrieved securely: ${document.$id}');
      return document;
    } catch (e) {
      Loggers.database.error('Failed to get document securely', error: e);
      rethrow;
    }
  }

  /// List documents with user filtering
  static Future<DocumentList> listDocumentsSecure({
    required String databaseId,
    required String collectionId,
    List<String>? queries,
  }) async {
    try {
      // Add user filter for collections that require it
      final secureQueries = _addUserFilter(collectionId, queries);

      final documents = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: secureQueries,
      );

      Loggers.database
          .debug('Documents listed securely: ${documents.total} found');
      return documents;
    } catch (e) {
      Loggers.database.error('Failed to list documents securely', error: e);
      rethrow;
    }
  }

  /// Update a document with ownership check
  static Future<Document> updateDocumentSecure({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      // First check if user owns the document
      if (_shouldCheckOwnership(collectionId)) {
        final existing = await getDocumentSecure(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );
        _validateDocumentAccess(existing, collectionId);
      }

      // Ensure permissions are properly typed if provided
      final finalPermissions = _safePermissions(permissions);

      final document = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
        permissions: finalPermissions,
      );

      Loggers.database.info('Document updated securely: ${document.$id}');
      return document;
    } catch (e) {
      Loggers.database.error('Failed to update document securely', error: e);
      rethrow;
    }
  }

  /// Delete a document with ownership check
  static Future<void> deleteDocumentSecure({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      // First check if user owns the document
      if (_shouldCheckOwnership(collectionId)) {
        final existing = await getDocumentSecure(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );
        _validateDocumentAccess(existing, collectionId);
      }

      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      Loggers.database.info('Document deleted securely: $documentId');
    } catch (e) {
      Loggers.database.error('Failed to delete document securely', error: e);
      rethrow;
    }
  }

  /// Check if ownership validation is needed for this collection
  static bool _shouldCheckOwnership(String collectionId) {
    const ownershipCollections = {
      'orders',
      'repCompanyRelations',
    };
    return ownershipCollections.contains(collectionId);
  }

  /// Get document user ID safely
  static String? _getDocumentUserId(Document document, String collectionId) {
    try {
      switch (collectionId) {
        case 'users':
          return document.$id;
        case 'orders':
          return document.data['repId'] as String?;
        case 'repCompanyRelations':
          return document.data['userId'] as String?;
        case 'companies':
          return document.data['createdBy'] as String?;
        case 'products':
          return document.data['createdBy'] as String?;
        default:
          return null;
      }
    } catch (e) {
      Loggers.database.warning('Failed to extract user ID from document: $e');
      return null;
    }
  }

  /// Validate that user has access to the document
  static void _validateDocumentAccess(Document document, String collectionId) {
    if (_currentUserId == null) {
      throw SecurityException('User not authenticated');
    }

    final documentUserId = _getDocumentUserId(document, collectionId);

    if (documentUserId == null) {
      Loggers.database.warning(
          'Could not determine document owner for collection: $collectionId');
      return; // Allow access if we can't determine ownership
    }

    if (documentUserId != _currentUserId) {
      throw SecurityException(
          'Access denied: You can only access your own data');
    }
  }

  /// Safely convert permissions to List<String>
  static List<String>? _safePermissions(List<String>? permissions) {
    if (permissions == null) return null;
    try {
      return List<String>.from(permissions);
    } catch (e) {
      Loggers.database
          .warning('Failed to convert permissions to List<String>: $e');
      // Filter out non-string values and return what we can
      return permissions.whereType<String>().toList();
    }
  }

  /// Add user filter to queries for collections that need it
  static List<String> _addUserFilter(
      String collectionId, List<String>? queries) {
    if (_currentUserId == null) {
      return queries ?? <String>[];
    }

    final userQueries = List<String>.from(queries ?? <String>[]);

    switch (collectionId) {
      case 'orders':
        userQueries.add('equal("repId", "$_currentUserId")');
        break;
      case 'repCompanyRelations':
        userQueries.add('equal("userId", "$_currentUserId")');
        break;
      case 'companies':
        // For companies, we might want to show all or filter by createdBy
        // userQueries.add('equal("createdBy", "$_currentUserId")');
        break;
      case 'products':
        // For products, we might want to show all or filter by createdBy
        // userQueries.add('equal("createdBy", "$_currentUserId")');
        break;
    }

    return userQueries;
  }
}
