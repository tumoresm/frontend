import 'package:appwrite/appwrite.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appwriteClientProvider = Provider((ref) {
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

final appwriteAccountProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabasesProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

final appwriteFunctionsProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Functions(client);
});
