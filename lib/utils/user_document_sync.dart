// DEPRECATED: This file is no longer needed after FastAPI migration
// User data is now managed by FastAPI backend, not Appwrite
// This file is kept for reference but should not be used

import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DEPRECATED: Utility class that was used to sync user documents between Appwrite Auth and Database
/// After FastAPI migration, user data is managed by the FastAPI backend
class UserDocumentSync {
  /// DEPRECATED: This method is no longer needed
  static Future<bool> checkUserDocumentExists(WidgetRef ref) async {
    Loggers.database.warning(
        'UserDocumentSync.checkUserDocumentExists is deprecated after FastAPI migration');
    return false;
  }

  /// DEPRECATED: This method is no longer needed
  static Future<dynamic> createUserDocumentIfMissing(WidgetRef ref) async {
    Loggers.database.warning(
        'UserDocumentSync.createUserDocumentIfMissing is deprecated after FastAPI migration');
    return null;
  }

  /// DEPRECATED: This method is no longer needed
  static Future<List<dynamic>> findOrphanedAuthUsers(WidgetRef ref) async {
    Loggers.database.warning(
        'UserDocumentSync.findOrphanedAuthUsers is deprecated after FastAPI migration');
    return [];
  }

  /// DEPRECATED: This method is no longer needed
  static Future<bool> syncCurrentUser(WidgetRef ref) async {
    Loggers.database.warning(
        'UserDocumentSync.syncCurrentUser is deprecated after FastAPI migration');
    return false;
  }
}

/// DEPRECATED: Provider for user document sync utility
/// This is no longer needed after FastAPI migration
final userDocumentSyncProvider = Provider((ref) {
  Loggers.database.warning(
      'userDocumentSyncProvider is deprecated after FastAPI migration');
  return UserDocumentSync();
});