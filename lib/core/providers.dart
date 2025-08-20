// ⚠️ DEPRECATED: This file contains legacy Appwrite providers
// Use lib/core/fastapi_providers.dart for new FastAPI-based infrastructure
// This file is kept for backward compatibility during migration

import 'package:appwrite/appwrite.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/core/logger.dart';

/// @deprecated Use FastAPIProviders instead
/// This provider is kept for backward compatibility only
final appwriteClientProvider = Provider((ref) {
  Loggers.database.warning('Using deprecated Appwrite client provider. Migrate to FastAPI providers.');
  
  Client client = Client();

  // Only allow self-signed certificates in development
  final isDevelopment = AppwriteConstants.endPoint.contains('localhost') ||
      AppwriteConstants.endPoint.contains('192.168.') ||
      AppwriteConstants.endPoint.contains('127.0.0.1');

  return client
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: isDevelopment);
});

/// @deprecated Use FastAPIProviders instead
final appwriteAccountProvider = Provider((ref) {
  Loggers.database.warning('Using deprecated Appwrite account provider. Migrate to FastAPI providers.');
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

/// @deprecated Use FastAPIProviders instead
final appwriteDatabasesProvider = Provider((ref) {
  Loggers.database.warning('Using deprecated Appwrite databases provider. Migrate to FastAPI providers.');
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

/// @deprecated Use FastAPIProviders instead
final appwriteStorageProvider = Provider((ref) {
  Loggers.database.warning('Using deprecated Appwrite storage provider. Migrate to FastAPI providers.');
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

/// @deprecated Use FastAPIProviders instead
final appwriteFunctionsProvider = Provider((ref) {
  Loggers.database.warning('Using deprecated Appwrite functions provider. Migrate to FastAPI providers.');
  final client = ref.watch(appwriteClientProvider);
  return Functions(client);
});
