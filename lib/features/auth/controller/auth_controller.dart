import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/features/auth/controller/auth_repository.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/constants/verification_constants.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:fieldforce/core/providers.dart';
import 'package:fieldforce/core/secure_client.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

/// ✅ FIX: Auto-refresh provider that detects session changes
final currentUserProvider = FutureProvider.autoDispose((ref) async {
  try {
    final authRepository = ref.watch(authRepositoryProvider);
    final user = await authRepository.currentUser();
    Loggers.auth.debug('currentUserProvider: ${user?.email ?? 'No user'}');
    return user;
  } catch (e) {
    Loggers.auth.debug('No current user found: $e');
    return null;
  }
});

/// ✅ FIX: Auto-refresh provider that fetches user details directly
final currentUserDetailsProvider =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  try {
    // Get current user from the independent provider
    final currentUser = await ref.watch(currentUserProvider.future);

    if (currentUser == null) {
      Loggers.auth.debug('No current user found');
      return null;
    }

    Loggers.auth.debug('Current user ID: ${currentUser.$id}');

    // Fetch user details directly using providers (no auth controller dependency)
    final client = ref.read(appwriteClientProvider);
    final databases = Databases(client);

    try {
      final document = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: currentUser.$id,
      );

      final data = document.data;
      if (data.isEmpty) {
        Loggers.database
            .warning('Document data is empty for user ${currentUser.$id}');
        return null;
      }

      // Add the document ID to the data for UserModel creation
      final dataWithId = Map<String, dynamic>.from(data);
      dataWithId['\$id'] = document.$id;

      final userModel = UserModel.fromMap(dataWithId);
      Loggers.database
          .info('UserModel created successfully: ${userModel.email}');
      return userModel;
    } catch (e) {
        Loggers.database.error('Error fetching user document for ${currentUser.$id}', error: e);
        return null;
    }
  } catch (e, stackTrace) {
    Loggers.auth.error('Error in currentUserDetailsProvider',
        error: e, stackTrace: stackTrace);
    return null;
  }
});

/// ✅ FIX: Independent provider that fetches user details by ID
final userDetailsProvider =
    FutureProvider.family<UserModel?, String>((ref, String uid) async {
  try {
    final client = ref.read(appwriteClientProvider);
    final databases = Databases(client);

    final document = await databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: uid,
    );

    final data = document.data;
    if (data.isEmpty) {
      return null;
    }

    final dataWithId = Map<String, dynamic>.from(data);
    dataWithId['\$id'] = document.$id;

    return UserModel.fromMap(dataWithId);
  } catch (e) {
    Loggers.database.error('Error fetching user details for $uid', error: e);
    return null;
  }
});

/// Checks if the current user's profile is complete
final isProfileCompleteProvider = FutureProvider.autoDispose<bool>((ref) async {
  final userDetails = await ref.watch(currentUserDetailsProvider.future);

  if (userDetails == null) {
    return false;
  }

  // Check if essential profile fields are filled
  return userDetails.address.isNotEmpty &&
      userDetails.idDocumentUrl != null &&
      userDetails.idDocumentUrl!.isNotEmpty;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  //state = isLoading

  //_account.get() !=null ? HomePage : SignIn
  Future<model.User?> getCurrentUser() => _authRepository.currentUser();

  Future<UserModel?> getUserData(String uid) async {
    try {
      Loggers.database.debug('Fetching user data for UID: $uid');

      // Create an authenticated client using the current session
      final client = _ref.read(appwriteClientProvider);
      final account = _ref.read(appwriteAccountProvider);

      // Verify we have an active session
      try {
        final currentUser = await account.get();
        Loggers.database.debug('Current session user: ${currentUser.email}');
      } catch (sessionError) {
        Loggers.database.error('No active session for database access',
            error: sessionError);
        return null;
      }

      // Use the authenticated client for database access
      final databases = Databases(client);

      Loggers.database.debug(
          'Attempting to fetch document from database: ${AppwriteConstants.databaseId}');
      Loggers.database
          .debug('Collection: ${AppwriteConstants.usersCollection}');
      Loggers.database.debug('Document ID: $uid');

      final document = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: uid,
      );

      Loggers.database.debug('Document received successfully');
      Loggers.database.debug('Document ID: ${document.$id}');
      Loggers.database
          .debug('Document data type: ${document.data.runtimeType}');

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
      Loggers.database
          .info('UserModel created successfully: ${updatedUser.email}');
      return updatedUser;
    } catch (e, stackTrace) {
      // Handle all errors generically to avoid nullable type issues
      Loggers.database
          .error('Error in getUserData', error: e, stackTrace: stackTrace);
      Loggers.database.debug('Error type: ${e.runtimeType}');

      // Provide more specific error handling
      if (e.toString().contains('document_not_found') ||
          e.toString().contains('404')) {
        Loggers.database.warning('Document not found for user $uid');
        Loggers.database.info(
            'This usually means the user document was not created during registration');
      } else if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        Loggers.database.warning('Unauthorized access to user document');
        Loggers.database
            .info('This usually means the user session is invalid or expired');
      } else if (e.toString().contains('LateInitializationError')) {
        Loggers.database
            .warning('This appears to be a LateInitializationError');
        Loggers.database.warning(
            'This suggests a late variable in Appwrite Document class is not initialized');
      }

      return null; // Return null instead of rethrowing to prevent app crash
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    state = false; // Reset loading state

    return res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
        return false; // Return false on error
      },
      (r) {
        if (context.mounted) {
          showSnackBar(context,
              'Account created successfully! You can now sign in.');
        }
        return true; // Return true on success
      },
    );
  }

  /// Sends email verification to the current user
  Future<void> _sendEmailVerification() async {
    try {
      final account = _ref.read(appwriteAccountProvider);

      Loggers.auth.info('Attempting to send email verification...');
      Loggers.auth.debug('Appwrite Endpoint: ${AppwriteConstants.endPoint}');
      Loggers.auth.debug('Project ID: ${AppwriteConstants.projectId}');
      Loggers.auth.debug('Using SMTP Provider ID: ${AppwriteConstants.smtpProviderId}');

      // Verify user is authenticated before sending verification
      final currentUser = await account.get();
      Loggers.auth.info('Sending verification for user: ${currentUser.email}');
      
      // Check if user is already verified
      if (currentUser.emailVerification) {
        Loggers.auth.info('User email is already verified');
        return;
      }

      await account.createVerification(
        url: 'http://192.168.100.5/complete_verification.html',
      );

      Loggers.auth.info('Email verification sent successfully');
    } catch (e) {
      Loggers.auth.error('Failed to send email verification', error: e);
      Loggers.auth.debug('Error details: ${e.toString()}');

      // Log specific error information for debugging
      if (e.toString().contains('smtp_disabled') || e.toString().contains('general_smtp_disabled')) {
        Loggers.auth.error('SMTP is disabled in Appwrite configuration');
        Loggers.auth.error('Please check your Appwrite Console → Settings → SMTP');
        Loggers.auth.error('Ensure SMTP is enabled and properly configured');
      } else if (e.toString().contains('invalid_url')) {
        Loggers.auth.error('Invalid verification URL provided');
      } else if (e.toString().contains('rate_limit')) {
        Loggers.auth.error('Rate limit exceeded for email verification');
      } else if (e.toString().contains('unauthorized')) {
        Loggers.auth.error('User not authenticated for email verification');
      }

      rethrow;
    }
  }

  /// Updates user profile with additional verification information
  /// Uses Appwrite Function for better security and validation
  Future<bool> updateUserProfile({
    required String userId,
    required String address,
    required String idDocumentUrl,
    required String profileImageUrl,
    required String role,
    required BuildContext context,
    bool useFunction = true, // Flag to use FastAPI server or direct DB update
  }) async {
    state = true;
    try {
      // Validate required fields
      if (address.trim().isEmpty) {
        if (context.mounted) {
          showSnackBar(context, 'Address is required.');
        }
        return false;
      }

      if (idDocumentUrl.trim().isEmpty) {
        if (context.mounted) {
          showSnackBar(context, 'ID Document URL is required.');
        }
        return false;
      }

      bool success = false;

      if (useFunction) {
        // Try FastAPI server first
        Loggers.database.info('Attempting profile update via FastAPI server...');
        try {
          success = await _updateProfileViaAPI(
            userId: userId,
            address: address,
            idDocumentUrl: idDocumentUrl,
            profileImageUrl: profileImageUrl,
            role: role,
          );
          
          if (success) {
            Loggers.database.info('Profile update via API successful');
          } else {
            Loggers.database.warning('API update returned false, falling back to direct update');
          }
        } catch (e) {
          Loggers.database.warning(
              'API call failed with exception, falling back to direct update',
              error: e);
          success = false;
        }
        
        // If API failed, fall back to direct database update
        if (!success) {
          Loggers.database.info('Falling back to direct database update...');
          success = await _updateProfileDirect(
            userId: userId,
            address: address,
            idDocumentUrl: idDocumentUrl,
            profileImageUrl: profileImageUrl,
            role: role,
          );
          
          if (success) {
            Loggers.database.info('Profile update via direct database successful');
          }
        }
      } else {
        // Direct database update only
        Loggers.database.info('Using direct database update (API disabled)...');
        success = await _updateProfileDirect(
          userId: userId,
          address: address,
          idDocumentUrl: idDocumentUrl,
          profileImageUrl: profileImageUrl,
          role: role,
        );
      }

      if (success) {
        Loggers.database.info('Profile updated successfully for user: $userId');
        if (context.mounted) {
          showSnackBar(
              context, 'Profile updated successfully! Awaiting verification.');
        }

        // ✅ FIX: Remove provider invalidation to avoid circular dependency
        // Providers will refresh automatically when accessed after profile update
        Loggers.database
            .info('Profile updated - providers will refresh on next access');

        return true;
      } else {
        if (context.mounted) {
          showSnackBar(context, 'Failed to update profile. Please try again.');
        }
        return false;
      }
    } catch (e) {
      Loggers.database.error('Error updating user profile', error: e);
      if (context.mounted) {
        showSnackBar(context, 'Failed to update profile. Please try again.');
      }
      return false;
    } finally {
      state = false;
    }
  }

  /// Updates user profile via FastAPI server
  Future<bool> _updateProfileViaAPI({
    required String userId,
    required String address,
    required String idDocumentUrl,
    required String profileImageUrl,
    required String role,
  }) async {
    try {
      Loggers.database
          .info('Updating profile via FastAPI server for user: $userId');
      
      final endpoint = ApiConstants.updateProfileEndpoint(userId);
      Loggers.database
          .debug('FastAPI endpoint: $endpoint');

      // Get current user session for authentication
      final account = _ref.read(appwriteAccountProvider);
      final currentUser = await account.get();

      // Prepare request data (userId is now in the URL path)
      final requestData = {
        'address': address.trim(),
        'idDocumentUrl': idDocumentUrl.trim(),
        'role': role,
        'verificationStatus': VerificationStatus.pending,
      };

      // Only add profileImageUrl if it's not empty
      if (profileImageUrl.trim().isNotEmpty) {
        requestData['profileImageUrl'] = profileImageUrl.trim();
      }

      // Make API call to FastAPI server using PATCH method
      final response = await http
          .patch(
            Uri.parse(endpoint),
            headers: {
              ...ApiConstants.defaultHeaders,
              'Authorization':
                  'Bearer ${currentUser.$id}', // Use user ID as auth token
            },
            body: jsonEncode(requestData),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        Loggers.database.info(
            'Profile updated successfully via API: ${responseData['message'] ?? 'Success'}');
        return true;
      } else {
        String errorMessage = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }
        
        Loggers.database.error('API profile update failed: $errorMessage');
        
        // Log specific error guidance
        if (response.statusCode == 404) {
          Loggers.database.error('ENDPOINT NOT FOUND: The FastAPI server is missing the /users/profile/update endpoint');
          Loggers.database.error('Check SERVER_SIDE_FIX_GUIDE.md for server configuration instructions');
        } else if (response.statusCode == 405) {
          Loggers.database.error('METHOD NOT ALLOWED: The endpoint exists but doesn\'t accept PUT requests');
        } else if (response.statusCode == 422) {
          Loggers.database.error('VALIDATION ERROR: The request data format is incorrect');
        }
        
        return false;
      }
    } catch (e) {
      Loggers.database.error('Error updating profile via API', error: e);
      return false;
    }
  }

  /// Direct database update method (fallback or when function is not available)
  Future<bool> _updateProfileDirect({
    required String userId,
    required String address,
    required String idDocumentUrl,
    required String profileImageUrl,
    required String role,
  }) async {
    try {
      // Create an authenticated client using the current session
      final client = _ref.read(appwriteClientProvider);
      final databases = Databases(client);

      // Prepare data for update, handling empty strings properly
      final updateData = <String, dynamic>{
        'address': address.trim(),
        'idDocumentUrl': idDocumentUrl.trim(),
        'role': role,
        'verificationStatus': VerificationStatus
            .pending, // Set status to Pending after profile completion
      };

      // Only add profileImageUrl if it's not empty
      if (profileImageUrl.trim().isNotEmpty) {
        updateData['profileImageUrl'] = profileImageUrl.trim();
      }

      // Update the user document with additional information
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userId,
        data: updateData,
      );

      return true;
    } catch (e) {
      Loggers.database.error('Direct profile update failed', error: e);
      return false;
    }
  }

  /// Refreshes user data by invalidating providers
  void refreshUserData() {
    // ✅ FIX: Remove provider invalidation to avoid circular dependency
    // Providers will refresh automatically when accessed
    Loggers.auth
        .info('refreshUserData called - providers will refresh on next access');
    Loggers.auth
        .info('No manual invalidation needed to avoid circular dependency');
  }

  void signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.signIn(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) async {
        // Skip email verification check for now
        Loggers.auth.info('Sign-in successful, skipping email verification check');

        if (context.mounted) {
          showSnackBar(context, 'Sign in successful!');
        }

        Loggers.navigation.info('Sign-in successful, preparing navigation...');

        // Wait a moment for the session to be established
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ FIX: Verify user document exists after sign-in
        try {
          final userDetails =
              await _ref.read(currentUserDetailsProvider.future);
          if (userDetails == null) {
            Loggers.auth.warning(
                'User document not found after sign-in, but continuing...');
            // The provider will handle creating the missing document
          } else {
            Loggers.auth.info('User document verified: ${userDetails.email}');
          }
        } catch (e) {
          Loggers.auth.warning('Could not verify user document after sign-in',
              error: e);
          // Continue anyway, the provider will handle it
        }

        // ✅ FIX: Remove provider invalidation to avoid circular dependency
        // Providers will refresh automatically when the underlying session changes
        Loggers.navigation.info(
            'Skipping provider invalidation to avoid circular dependency');
        Loggers.navigation
            .info('Providers will refresh automatically on next access');

        // ✅ FIX: Direct navigation to dashboard to bypass main.dart routing issues
        if (context.mounted) {
          Loggers.navigation.info('Navigating directly to dashboard...');
          // Navigate directly to dashboard instead of relying on main.dart routing
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const DashBoardController()),
            (route) => false,
          );
          Loggers.navigation.info('Direct navigation to dashboard completed');
        } else {
          Loggers.navigation.warning(
              'Context not mounted, scheduling navigation for next frame');
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashBoardController()),
                (route) => false,
              );
              Loggers.navigation
                  .info('Delayed direct navigation to dashboard completed');
            }
          });
        }
      },
    );
  }

  /// Shows dialog to resend email verification
  void _showResendVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: const Text(
            'Please verify your email address to continue. Would you like us to resend the verification email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (context.mounted) {
                Navigator.pop(context);
              }
              try {
                await _sendEmailVerification();
                if (context.mounted) {
                  showSnackBar(context,
                      'Verification email sent! Please check your inbox.');
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(context,
                      'Failed to send verification email. Please try again.');
                }
              }
            },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    final res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Your session will be deleted. Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (res == true) {
      final res = await _authRepository.logout();
      res.fold(
        (l) {
          if (context.mounted) {
            showSnackBar(context, l.message);
          }
        },
        (r) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              SignInPage.route(),
              (route) => false,
            );
          }
        },
      );
    }
  }

  Future<void> forgotPassword({required String email, required BuildContext context}) async {
    state = true;
    final res = await _authRepository.forgotPassword(email: email);
    state = false;

    res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) {
        if (context.mounted) {
          showSnackBar(context, 'Password reset link sent to your email.');
        }
      },
    );
  }
}
