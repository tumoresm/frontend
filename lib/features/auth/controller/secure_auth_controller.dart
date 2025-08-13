import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/features/auth/controller/auth_repository.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:fieldforce/core/secure_client.dart';
import 'package:fieldforce/core/secure_providers.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureAuthControllerProvider =
    StateNotifierProvider<SecureAuthController, bool>((ref) {
  return SecureAuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

final secureCurrentUserProvider = FutureProvider((ref) {
  final authController = ref.watch(secureAuthControllerProvider.notifier);
  return authController.getCurrentUser();
});

/// Provides the full [UserModel] details for the currently logged-in user with security
final secureCurrentUserDetailsProvider = FutureProvider<UserModel?>((ref) async {
  try {
    // Get the auth controller to check current user
    final authController = ref.read(secureAuthControllerProvider.notifier);
    
    // Get current user from Appwrite directly
    final currentUser = await authController.getCurrentUser();
    
    if (currentUser == null) {
      Loggers.auth.debug('No current user found');
      return null;
    }
    
    Loggers.auth.debug('Current user ID: ${currentUser.$id}');
    
    // Set the user ID in secure client
    SecureAppwriteClient.setCurrentUserId(currentUser.$id);
    
    // Add a small delay to ensure the session is fully established
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Fetch user details from database using secure client
    return await authController.getUserDataSecure(currentUser.$id);
  } catch (e, stackTrace) {
    Loggers.auth.error('Error in secureCurrentUserDetailsProvider', error: e, stackTrace: stackTrace);
    Loggers.auth.debug('Error type: ${e.runtimeType}');
    return null;
  }
});

final secureUserDetailsProvider = FutureProvider.family<UserModel?, String>((ref, String uid) {
  final authController = ref.watch(secureAuthControllerProvider.notifier);
  return authController.getUserDataSecure(uid);
});

class SecureAuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  SecureAuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  //state = isLoading

  //_account.get() !=null ? HomePage : SignIn
  Future<model.User?> getCurrentUser() => _authRepository.currentUser();

  Future<UserModel?> getUserDataSecure(String uid) async {
    try {
      Loggers.database.debug('Fetching user data securely for UID: $uid');
      
      // Use secure client to get user document
      final document = await SecureAppwriteClient.getDocumentSecure(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: uid,
      );
      
      Loggers.database.debug('Document received successfully');
      Loggers.database.debug('Document ID: ${document.$id}');
      Loggers.database.debug('Document data type: ${document.data.runtimeType}');
      
      // Safely access document data
      final data = document.data;
      if (data.isEmpty) {
        Loggers.database.warning('Document data is empty for user $uid');
        return null;
      }
      
      Loggers.database.debug('Document data keys: ${data.keys.toList()}');
      Loggers.database.debug('Document data: $data');
      
      // Add the document ID to the data for UserModel creation
      final dataWithId = Map<String, dynamic>.from(data);
      dataWithId['\$id'] = document.$id;
      
      final updatedUser = UserModel.fromMap(dataWithId);
      Loggers.database.info('UserModel created successfully: ${updatedUser.email}');
      return updatedUser;
    } catch (e, stackTrace) {
      // Handle all errors generically to avoid nullable type issues
      Loggers.database.error('Error in getUserDataSecure', error: e, stackTrace: stackTrace);
      Loggers.database.debug('Error type: ${e.runtimeType}');
      
      // Provide more specific error handling
      if (e.toString().contains('document_not_found') || e.toString().contains('404')) {
        Loggers.database.warning('Document not found for user $uid');
        Loggers.database.info('This usually means the user document was not created during registration');
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        Loggers.database.warning('Unauthorized access to user document');
        Loggers.database.info('This usually means the user session is invalid or expired');
      } else if (e.toString().contains('Access denied')) {
        Loggers.database.warning('Access denied to user document');
        Loggers.database.info('User can only access their own data');
      } else if (e.toString().contains('LateInitializationError')) {
        Loggers.database.warning('This appears to be a LateInitializationError');
        Loggers.database.warning('This suggests a late variable in Appwrite Document class is not initialized');
      }
      
      return null; // Return null instead of rethrowing to prevent app crash
    }
  }

  void signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String idDocumentUrl,
    required String role,
    required String address,
    required String profileImageUrl,
    List<String> myCompaniesPortfolio = const <String>[],
    required BuildContext context,
  }) async {
    state = true;
    
    // Update auth state
    _ref.read(SecureProviders.authStateProvider.notifier).setAuthState(AuthState.authenticating);
    
    final res = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      idDocumentUrl: idDocumentUrl,
      role: role,
      address: address,
      profileImageUrl: profileImageUrl,
      myCompaniesPortfolio: [],
    );
    
    state = false;  // Reset loading state
    
    res.fold(
      (l) {
        _ref.read(SecureProviders.authStateProvider.notifier).onAuthFailure();
        showSnackBar(context, l.message);
      },
      (r) async {
        showSnackBar(context, 'Account created! Please login.');
        Navigator.push(context, SignInPage.route());
      },
    );
  }

  void signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    
    // Update auth state
    _ref.read(SecureProviders.authStateProvider.notifier).setAuthState(AuthState.authenticating);
    
    final res = await _authRepository.signIn(
      email: email,
      password: password,
    );
    
    state = false;
    
    res.fold(
      (l) {
        _ref.read(SecureProviders.authStateProvider.notifier).onAuthFailure();
        showSnackBar(context, l.message);
      },
      (r) async {
        showSnackBar(context, 'Sign in successful!');
        
        Loggers.navigation.info('Sign-in successful, preparing secure navigation...');
        
        try {
          // Get current user to set up secure client
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            // Set up secure client with user session
            _ref.read(SecureProviders.authStateProvider.notifier).onAuthSuccess(
              currentUser.$id,
              r.$id, // session ID
            );
            
            Loggers.auth.info('Secure client configured for user: ${currentUser.$id}');
          }
        } catch (e) {
          Loggers.auth.error('Failed to configure secure client', error: e);
        }
        
        // Wait a moment for the session to be established
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Simple, reliable navigation
        if (context.mounted) {
          Loggers.navigation.info('Navigating to dashboard...');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashBoardController()),
            (route) => false,
          );
          Loggers.navigation.info('Navigation completed');
        } else {
          Loggers.navigation.warning('Context not mounted, scheduling navigation for next frame');
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashBoardController()),
                (route) => false,
              );
            }
          });
        }
      },
    );
  }

  void logout(BuildContext context) async {
    final res = await _authRepository.logout();
    
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // Clear secure client session
        _ref.read(SecureProviders.authStateProvider.notifier).onLogout();
        
        Navigator.pushAndRemoveUntil(
          context,
          SignInPage.route(),
          (route) => false,
        );
      },
    );
  }
}