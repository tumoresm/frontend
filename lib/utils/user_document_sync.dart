import 'package:appwrite/models.dart' as models;
import 'package:fieldforce/core/providers.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:fieldforce/constants/verification_constants.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utility class to sync user documents between Appwrite Auth and Database
class UserDocumentSync {
  /// Check if user document exists for the current authenticated user
  static Future<bool> checkUserDocumentExists(WidgetRef ref) async {
    try {
      final account = ref.read(appwriteAccountProvider);
      final databases = ref.read(appwriteDatabasesProvider);

      // Get current authenticated user
      final currentUser = await account.get();
      Loggers.database.info(
          'Checking document for user: ${currentUser.email} (${currentUser.$id})');

      // Try to fetch user document
      try {
        await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: currentUser.$id,
        );
        Loggers.database.info('✅ User document exists');
        return true;
      } catch (e) {
        if (e.toString().contains('document_not_found') ||
            e.toString().contains('404')) {
          Loggers.database.warning('❌ User document not found');
          return false;
        } else {
          Loggers.database.error('Error checking user document', error: e);
          rethrow;
        }
      }
    } catch (e) {
      Loggers.database.error('Error in checkUserDocumentExists', error: e);
      return false;
    }
  }

  /// Create user document for authenticated user if it doesn't exist
  static Future<UserModel?> createUserDocumentIfMissing(WidgetRef ref) async {
    try {
      final account = ref.read(appwriteAccountProvider);
      final databases = ref.read(appwriteDatabasesProvider);

      // Get current authenticated user
      final currentUser = await account.get();

      // Check if document already exists
      final exists = await checkUserDocumentExists(ref);
      if (exists) {
        Loggers.database.info('User document already exists, fetching...');
        final document = await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: currentUser.$id,
        );

        final dataWithId = Map<String, dynamic>.from(document.data);
        dataWithId['\$id'] = document.$id;
        return UserModel.fromMap(dataWithId);
      }

      // Create missing document
      Loggers.database
          .info('Creating missing user document for: ${currentUser.email}');

      final userData = {
        'email': currentUser.email,
        'fullName': currentUser.name.isNotEmpty ? currentUser.name : 'User',
        'phoneNumber': currentUser.phone.isNotEmpty ? currentUser.phone : '',
        'role': 'Rep',
        'address': '',
        'idDocumentUrl': '',
        'profileImageUrl': '',
        'verificationStatus': VerificationStatus.unverified,
        'myCompaniesPortfolio': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final document = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: currentUser.$id,
        data: userData,
      );

      Loggers.database.info('✅ Successfully created user document');

      final dataWithId = Map<String, dynamic>.from(document.data);
      dataWithId['\$id'] = document.$id;
      return UserModel.fromMap(dataWithId);
    } catch (e) {
      Loggers.database.error('Error in createUserDocumentIfMissing', error: e);
      return null;
    }
  }

  /// List all authenticated users without corresponding documents
  static Future<List<models.User>> findOrphanedAuthUsers(WidgetRef ref) async {
    try {
      // Note: This would require admin privileges to list all users
      // For now, we can only check the current user
      Loggers.database.info('Checking current user for orphaned status...');

      final account = ref.read(appwriteAccountProvider);
      final currentUser = await account.get();

      final exists = await checkUserDocumentExists(ref);
      if (!exists) {
        Loggers.database.warning(
            'Current user is orphaned (no document): ${currentUser.email}');
        return [currentUser];
      }

      return [];
    } catch (e) {
      Loggers.database.error('Error in findOrphanedAuthUsers', error: e);
      return [];
    }
  }

  /// Sync current user data between Auth and Database
  static Future<bool> syncCurrentUser(WidgetRef ref) async {
    try {
      Loggers.database.info('Starting user sync process...');

      final account = ref.read(appwriteAccountProvider);
      final databases = ref.read(appwriteDatabasesProvider);

      // Get current authenticated user
      final currentUser = await account.get();
      Loggers.database.info('Syncing user: ${currentUser.email}');

      // Try to get existing document
      try {
        final document = await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: currentUser.$id,
        );

        // Update document with latest auth info
        await databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: currentUser.$id,
          data: {
            'email': currentUser.email,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        Loggers.database.info('✅ User document updated');
        return true;
      } catch (e) {
        if (e.toString().contains('document_not_found') ||
            e.toString().contains('404')) {
          // Create missing document
          final created = await createUserDocumentIfMissing(ref);
          return created != null;
        } else {
          rethrow;
        }
      }
    } catch (e) {
      Loggers.database.error('Error in syncCurrentUser', error: e);
      return false;
    }
  }
}

/// Provider for user document sync utility
final userDocumentSyncProvider = Provider((ref) {
  return UserDocumentSync();
});
