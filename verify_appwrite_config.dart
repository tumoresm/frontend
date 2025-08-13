import 'package:appwrite/appwrite.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/constants/verification_constants.dart';
import 'package:fieldforce/core/logger.dart';

/// Utility script to verify Appwrite configuration and permissions
/// /// Run this to check if your Appwrite setup is correct for the FieldForce app
/// class AppwriteConfigVerifier {
///   late Client client;  
/// late Account account;
///  late Databases databases;
/// 
///  AppwriteConfigVerifier() {
///    client = Client()
///         .setEndpoint(AppwriteConstants.endPoint)
///         .setProject(AppwriteConstants.projectId)
///         .setSelfSigned(status: true);
///     
///     account = Account(client);
///     databases = Databases(client);
///   }
/// 
/// Verify basic connectivity to Appwrite
///   Future<bool> verifyConnectivity() async {
///     try {
///       print('🔍 Testing connectivity to Appwrite...');
///       print('   Endpoint: ${AppwriteConstants.endPoint}');
///       print('   Project ID: ${AppwriteConstants.projectId}');
///       
///       // Try to get project info (this doesn't require authentication)
///       await client.call(
///         method: 'GET',
///         path: '/health',
///       );
///       
///       print('✅ Successfully connected to Appwrite server');
///       return true;
///     } catch (e) {
///       print('❌ Failed to connect to Appwrite server: $e');
///       print('   Please check:');
///       print('   - Appwrite server is running');
///       print('   - Endpoint URL is correct');
///       print('   - Network connectivity');
///       return false;
///     }
///   }
/// 
/// Verify database and collections exist
///   Future<bool> verifyDatabase() async {
///     try {
///       print('🔍 Verifying database configuration...');
///       print('   Database ID: ${AppwriteConstants.databaseId}');
///       
///       // This will fail if database doesn't exist or we don't have access
///       final collections = await databases.listCollections(
///         databaseId: AppwriteConstants.databaseId,
///       );
///       
///       print('✅ Database exists and is accessible');
///       print('   Found ${collections.total} collections');
///       
///       // Check for required collections
///       final requiredCollections = [
///         AppwriteConstants.usersCollection,
///         AppwriteConstants.companyCollection,
///         AppwriteConstants.ordersCollection,
///         AppwriteConstants.productsCollection,
///       ];
///       
///       final existingCollections = collections.collections.map((c) => c.$id).toList();
///       
///       for (final required in requiredCollections) {
///         if (existingCollections.contains(required)) {
///           print('   ✅ Collection \"$required\" exists');
///         } else {
///           print('   ❌ Collection \"$required\" is missing');
///         }
///       }
///       
///       return true;
///     } catch (e) {
///       print('❌ Failed to access database: $e');
///       print('   Please check:');
///       print('   - Database ID is correct');
///       print('   - Database exists in Appwrite console');
///       print('   - Required collections are created');
///       return false;
///     }
///   }
/// 
/// Test user authentication flow
///   Future<bool> testAuthFlow() async {
///     try {
///       print('🔍 Testing authentication flow...');
///       
///       // Try to get current user (should fail if not authenticated)
///       try {
///         final user = await account.get();
///         print('✅ User is already authenticated: ${user.email}');
///         return await testUserDocumentAccess(user.$id);
///       } catch (e) {
///         print('ℹ️  No current user session (this is normal)');
///         print('   To test full auth flow, sign in through the app first');
///         return true;
///       }
///     } catch (e) {
///       print('❌ Authentication test failed: $e');
///       return false;
///     }
///   }
/// 
/// Test user document access and creation permissions
///   Future<bool> testUserDocumentAccess(String userId) async {
///     try {
///       print('🔍 Testing user document access...');
///       print('   User ID: $userId');
///       
///       // Try to get user document
///       try {
///         final document = await databases.getDocument(
///           databaseId: AppwriteConstants.databaseId,
///           collectionId: AppwriteConstants.usersCollection,
///           documentId: userId,
///         );
///         
///         print('✅ User document exists and is accessible');
///         print('   Email: ${document.data['email']}');
///         print('   Role: ${document.data['role']}');
///         return true;
///       } catch (e) {
///         if (e.toString().contains('document_not_found')) {
///           print('⚠️  User document not found - this is the issue we're fixing');
///           return await testDocumentCreation(userId);
///         } else {
///           print('❌ Failed to access user document: $e');
///           return false;
///         }
///       }
///     } catch (e) {
///       print('❌ User document test failed: $e');
///       return false;
///     }
///   }
/// 
/// Test document creation permissions
///   Future<bool> testDocumentCreation(String userId) async {
///     try {
///       print('🔍 Testing document creation permissions...');
///       
///       final testData = {
///         'email': 'test@example.com',
///         'fullName': 'Test User',
///         'phoneNumber': '+1234567890',
///         'role': 'Rep',
///         'address': '',
///         'idDocumentUrl': '',
///         'profileImageUrl': '',
///         'verificationStatus': VerificationStatus.unverified,
///         'myCompaniesPortfolio': [],
///         'createdAt': DateTime.now().toIso8601String(),
///         'updatedAt': DateTime.now().toIso8601String(),
///       };
///       
///       // Try to create a test document
/// 
///      final document = await databases.createDocument(
///         databaseId: AppwriteConstants.databaseId,
///         collectionId: AppwriteConstants.usersCollection,
///         documentId: userId,
///         data: testData,
///       );
///       
///       print('✅ Document creation successful');
///       print('   Document ID: ${document.$id}');
///       
///       // Clean up test document
///       try {
///         await databases.deleteDocument(
///           databaseId: AppwriteConstants.databaseId,
///           collectionId: AppwriteConstants.usersCollection,
///           documentId: userId,
///         );
///         print('✅ Test document cleaned up');
///       } catch (e) {
///         print('⚠️  Could not clean up test document: $e');
///       }
///       
///       return true;
///     } catch (e) {
///       if (e.toString().contains('user_unauthorized') || e.toString().contains('401')) {
///         print('❌ PERMISSION ERROR: Cannot create user documents');
///         print('   This is the exact issue we're fixing!');
///         print('   Please configure collection permissions:');
///         print('   1. Go to Appwrite Console → Database → users collection');
///         print('   2. Go to Settings → Permissions');
///         print('   3. Add Create permission: \"users\" or \"user:*\"');
///         print('   4. Add Read permission: \"users\"');
///         print('   5. Add Update permission: \"user:*\"');
///         print('   6. Add Delete permission: \"user:*\"');
///       } else {
///         print('❌ Document creation failed: $e');
///       }
///       return false;
///     }
///   }
/// 
///  Run all verification tests
///   Future<void> runAllTests() async {
///     print('🚀 FieldForce Appwrite Configuration Verifier');
///     print('=' * 50);
///     
///     final results = <String, bool>{};
///     
///     results['Connectivity'] = await verifyConnectivity();
///     results['Database'] = await verifyDatabase();
///     results['Authentication'] = await testAuthFlow();
///     
///     print('📊 Test Results Summary:');
///     print('=' * 30);
///     
///     bool allPassed = true;
///     for (final entry in results.entries) {
///       final status = entry.value ? '✅ PASS' : '❌ FAIL';
///       print('   ${entry.key}: $status');
///       if (!entry.value) allPassed = false;
///     }
///     
///     print('' + '=' * 50);
///     if (allPassed) {
///       print('🎉 All tests passed! Your Appwrite configuration looks good.');
///     } else {
///       print('⚠️  Some tests failed. Please review the issues above.');
///       print('   The authentication fix should resolve permission issues.');
///     }
///   }
/// }
/// 
/// Main function to run the verification
/// void main() async {
///   final verifier = AppwriteConfigVerifier();
///   await verifier.runAllTests();
/// }
/// 