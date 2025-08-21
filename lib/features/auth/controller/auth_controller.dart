// Removed unused Appwrite imports after FastAPI migration
import 'package:fieldforce/features/auth/controller/auth_repository.dart';
import 'package:fieldforce/constants/constants.dart';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/features/auth/view/pages/email_verification_page.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/core/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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

/// ✅ FIX: Auto-refresh provider that detects session changes using FastAPI session
final currentUserProvider = FutureProvider.autoDispose((ref) async {
  try {
    final sessionManager = SessionManager.instance;
    final isLoggedIn = await sessionManager.isLoggedIn();

    if (!isLoggedIn) {
      Loggers.auth.debug('No active session found');
      return null;
    }

    final userData = await sessionManager.getUserData();
    if (userData != null) {
      Loggers.auth
          .debug('currentUserProvider: ${userData['email'] ?? 'No email'}');
      return userData;
    }

    Loggers.auth.debug('No user data found in session');
    return null;
  } catch (e) {
    Loggers.auth.debug('No current user found: $e');
    return null;
  }
}, name: 'currentUserProvider');

/// ✅ FIX: Auto-refresh provider that fetches user details from FastAPI session
final currentUserDetailsProvider =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  try {
    // Get current user from the session-based provider
    final currentUser = await ref.watch(currentUserProvider.future);

    if (currentUser == null) {
      Loggers.auth.debug('No current user found');
      return null;
    }

    // Convert session data to UserModel
    final userData = currentUser;
    final profile = userData['profile'] as Map<String, dynamic>?;

    final userModel = UserModel(
      id: userData['userId'] ?? '',
      email: userData['email'] ?? '',
      fullName: userData['fullName'] ?? '',
      phoneNumber: profile?['phoneNumber'] ?? '',
      role: profile?['role'] ?? 'Rep',
      address: profile?['address'] ?? '',
      idNumber: profile?['idNumber'],
      profileImage: profile?['profileImage'],
      selectedAvatar: profile?['selectedAvatar'],
      verificationStatus:
          userData['verificationStatus'] ?? VerificationStatus.unverified,
      myCompaniesPortfolio: [],
      createdAt: null,
      updatedAt: null,
    );

    Loggers.database.info('UserModel created from session: ${userModel.email}');
    return userModel;
  } catch (e, stackTrace) {
    Loggers.auth.error('Error in currentUserDetailsProvider',
        error: e, stackTrace: stackTrace);
    return null;
  }
}, name: 'currentUserDetailsProvider');

/// ✅ FIX: Independent provider that fetches user details by ID using FastAPI session
final userDetailsProvider =
    FutureProvider.family<UserModel?, String>((ref, String uid) async {
  try {
    // Get user data from FastAPI session
    final sessionManager = SessionManager.instance;
    final userData = await sessionManager.getUserData();

    if (userData == null) {
      Loggers.database.warning('No user data found in session');
      return null;
    }

    // Check if the requested UID matches the current session user
    if (userData['userId'] != uid) {
      Loggers.database.warning('Requested UID does not match session user');
      return null;
    }

    // Convert session data to UserModel
    final profile = userData['profile'] as Map<String, dynamic>?;

    final userModel = UserModel(
      id: userData['userId'] ?? '',
      email: userData['email'] ?? '',
      fullName: userData['fullName'] ?? '',
      phoneNumber: profile?['phoneNumber'] ?? '',
      role: profile?['role'] ?? 'Rep',
      address: profile?['address'] ?? '',
      idNumber: profile?['idNumber'],
      profileImage: profile?['profileImage'],
      selectedAvatar: profile?['selectedAvatar'],
      verificationStatus:
          userData['verificationStatus'] ?? VerificationStatus.unverified,
      myCompaniesPortfolio: [],
      createdAt: null,
      updatedAt: null,
    );

    return userModel;
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
      userDetails.idNumber != null &&
      userDetails.idNumber!.isNotEmpty;
}, name: 'isProfileCompleteProvider');

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

  // Get current user from session instead of Appwrite
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await SessionManager.instance.getUserData();
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      Loggers.database.debug('Fetching user data for UID: $uid');

      // Get user data from FastAPI session
      final sessionManager = SessionManager.instance;
      final userData = await sessionManager.getUserData();

      if (userData == null) {
        Loggers.database.warning('No user data found in session');
        return null;
      }

      // Check if the requested UID matches the current session user
      if (userData['userId'] != uid) {
        Loggers.database.warning('Requested UID does not match session user');
        return null;
      }

      // Convert session data to UserModel
      final profile = userData['profile'] as Map<String, dynamic>?;

      final userModel = UserModel(
        id: userData['userId'] ?? '',
        email: userData['email'] ?? '',
        fullName: userData['fullName'] ?? '',
        phoneNumber: profile?['phoneNumber'] ?? '',
        role: profile?['role'] ?? 'Rep',
        address: profile?['address'] ?? '',
        idNumber: profile?['idNumber'],
        profileImage: profile?['profileImage'],
        selectedAvatar: profile?['selectedAvatar'],
        verificationStatus:
            userData['verificationStatus'] ?? VerificationStatus.unverified,
        myCompaniesPortfolio: [],
        createdAt: null,
        updatedAt: null,
      );

      Loggers.database
          .info('UserModel created from session: ${userModel.email}');
      return userModel;
    } catch (e, stackTrace) {
      Loggers.database
          .error('Error in getUserData', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String? selectedAvatar,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      selectedAvatar: selectedAvatar,
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
              'Account created successfully! A verification code has been sent to your email.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmailVerificationPage(email: email)),
          );
        }
        return true; // Return true on success
      },
    );
  }

  /// Email verification is now handled by FastAPI backend
  /// This method is kept for backward compatibility but uses FastAPI
  Future<void> _sendEmailVerification() async {
    try {
      // Get current user email from session
      final userData = await SessionManager.instance.getUserData();
      if (userData == null) {
        throw Exception('No user session found');
      }

      final email = userData['email'] as String;
      Loggers.auth.info('Requesting email verification resend for: $email');

      // This method should not be called directly anymore
      // Use resendVerificationCode with proper context instead
      Loggers.auth.warning(
          '_sendEmailVerification called - use resendVerificationCode instead');
      throw Exception('Use resendVerificationCode method instead');
    } catch (e) {
      Loggers.auth.error('Failed to send email verification', error: e);
      rethrow;
    }
  }

  /// Updates user profile with additional verification information
  /// Uses FastAPI server for profile updates only
  Future<bool> updateUserProfile({
    required String userId,
    required String address,
    required String idNumber,
    required File? profileImage,
    required String role,
    required BuildContext context,
    required String verificationStatus,
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

      if (idNumber.trim().isEmpty) {
        if (context.mounted) {
          showSnackBar(context, 'ID Number is required.');
        }
        return false;
      }

      // Validate ID Number format (13 digits)
      if (!RegExp(r'^\d{13}$').hasMatch(idNumber)) {
        if (context.mounted) {
          showSnackBar(context, 'ID Number must be a 13-digit number.');
        }
        return false;
      }

      // Update profile via FastAPI server only
      Loggers.database.info('Updating profile via FastAPI server...');
      final success = await _updateProfileViaAPI(
        userId: userId,
        address: address,
        idNumber: idNumber,
        profileImage: profileImage,
        role: role,
      );

      if (success) {
        Loggers.database.info('Profile updated successfully for user: $userId');

        // Update local session data to reflect the changes
        await SessionManager.instance.updateUserProfile(
          address: address,
          idNumber: idNumber,
          role: role,
          profileImage: profileImage?.path,
        );

        // Force refresh of providers to pick up the updated session data
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(currentUserDetailsProvider);
        _ref.invalidate(isProfileCompleteProvider);

        if (context.mounted) {
          showSnackBar(
              context, 'Profile updated successfully! Awaiting verification.');
        }

        // Providers have been invalidated and will refresh with updated data
        Loggers.database
            .info('Profile updated - providers invalidated and will refresh');

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
    required String idNumber,
    required File? profileImage,
    required String role,
  }) async {
    try {
      Loggers.database
          .info('Updating profile via FastAPI server for user: $userId');

      final endpoint = ApiConstants.updateProfileEndpoint;
      Loggers.database.debug('FastAPI endpoint: $endpoint');

      // Get current user session for authentication
      final sessionManager = SessionManager.instance;
      final accessToken = await sessionManager.getAccessToken();

      if (accessToken == null) {
        Loggers.database.error('No access token found for API request');
        return false;
      }

      // Check if we have a profile image to upload
      if (profileImage != null) {
        // Use multipart for file upload
        final request = http.MultipartRequest('PATCH', Uri.parse(endpoint));
        request.headers.addAll({
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        });

        request.fields['address'] = address.trim();
        request.fields['idNumber'] = idNumber.trim();
        request.fields['role'] = role;
        request.fields['verificationStatus'] = VerificationStatus.pending;

        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ));

        final response =
            await request.send().timeout(ApiConstants.requestTimeout);
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(responseBody);
          Loggers.database.info(
              'Profile updated successfully via API: ${responseData['message'] ?? 'Success'}');
          return true;
        } else {
          Loggers.database.error(
              'API profile update failed: HTTP ${response.statusCode}: $responseBody');
          return false;
        }
      } else {
        // Use JSON for data-only update
        final requestBody = {
          'address': address.trim(),
          'idNumber': idNumber.trim(),
          'role': role,
          'verificationStatus': VerificationStatus.pending,
        };

        final response = await http
            .patch(
              Uri.parse(endpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(ApiConstants.requestTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          Loggers.database.info(
              'Profile updated successfully via API: ${responseData['message'] ?? 'Success'}');
          return true;
        } else {
          Loggers.database.error(
              'API profile update failed: HTTP ${response.statusCode}: ${response.body}');
          return false;
        }
      }
    } catch (e) {
      Loggers.database.error('Error updating profile via API', error: e);
      return false;
    }
  }

  /// Navigate to dashboard with proper context checking
  Future<void> _navigateToDashboard(BuildContext context) async {
    if (context.mounted) {
      Loggers.navigation.info('Navigating directly to dashboard...');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashBoardController()),
        (route) => false,
      );
      Loggers.navigation.info('Direct navigation to dashboard completed');
    } else {
      Loggers.navigation
          .warning('Context not mounted, scheduling navigation for next frame');
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
        Loggers.auth.info('FastAPI sign-in successful');

        // Save session data
        if (r.data != null) {
          await SessionManager.instance.saveSession(r.data!);
          Loggers.auth.info('Session saved successfully');
        }

        if (context.mounted) {
          showSnackBar(context, 'Sign in successful!');
        }

        Loggers.navigation.info('Sign-in successful, preparing navigation...');

        // Wait a moment for the session to be established
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ FIX: Verify user data is available from session
        try {
          final userData = await SessionManager.instance.getUserData();
          if (userData != null) {
            Loggers.auth.info('User session verified: ${userData['email']}');
          } else {
            Loggers.auth.warning('No user data found in session after sign-in');
          }
        } catch (e) {
          Loggers.auth
              .warning('Could not verify user session after sign-in', error: e);
        }

        // ✅ FIX: Navigate to dashboard
        await _navigateToDashboard(context);
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
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (context.mounted) {
                navigator.pop();
              }
              try {
                // Get current user email from session
                final userData = await SessionManager.instance.getUserData();
                if (userData != null) {
                  final email = userData['email'] as String;
                  final success = await resendVerificationCode(
                    email: email,
                    context: context,
                  );

                  if (success && context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Verification email sent! Please check your inbox.'),
                      ),
                    );
                  }
                } else if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('No user session found.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to send verification email. Please try again.'),
                    ),
                  );
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
        content: const Text(
            'Your session will be deleted. Are you sure you want to logout?'),
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
      state = true; // Show loading state
      try {
        // First, call server-side logout to invalidate server session
        await _logoutFromServer();
        
        // Then clear local session
        await SessionManager.instance.clearSession();
        
        // Invalidate all auth-related providers to force refresh
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(currentUserDetailsProvider);
        _ref.invalidate(isProfileCompleteProvider);
        
        Loggers.auth.info('Complete logout successful - server and local session cleared');

        if (context.mounted) {
          showSnackBar(context, 'Logged out successfully');
          Navigator.pushAndRemoveUntil(
            context,
            SignInPage.route(),
            (route) => false,
          );
        }
      } catch (e) {
        Loggers.auth.error('Error during logout', error: e);
        
        // Even if server logout fails, clear local session
        try {
          await SessionManager.instance.clearSession();
          _ref.invalidate(currentUserProvider);
          _ref.invalidate(currentUserDetailsProvider);
          _ref.invalidate(isProfileCompleteProvider);
          
          if (context.mounted) {
            showSnackBar(context, 'Logged out (local session cleared)');
            Navigator.pushAndRemoveUntil(
              context,
              SignInPage.route(),
              (route) => false,
            );
          }
        } catch (localError) {
          Loggers.auth.error('Failed to clear local session', error: localError);
          if (context.mounted) {
            showSnackBar(context, 'Logout failed. Please try again.');
          }
        }
      } finally {
        state = false; // Reset loading state
      }
    }
  }

  /// Logout from server to invalidate server-side session
  Future<void> _logoutFromServer() async {
    try {
      final sessionManager = SessionManager.instance;
      final accessToken = await sessionManager.getAccessToken();
      
      if (accessToken == null) {
        Loggers.auth.warning('No access token found for server logout');
        return;
      }

      final endpoint = ApiConstants.logoutEndpoint;
      Loggers.auth.info('Calling server logout at: $endpoint');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        Loggers.auth.info('Server logout successful');
      } else {
        Loggers.auth.warning('Server logout returned status: ${response.statusCode}');
        // Don't throw error - we'll still clear local session
      }
    } catch (e) {
      Loggers.auth.warning('Server logout failed: $e');
      // Don't throw error - we'll still clear local session
    }
  }

  Future<void> forgotPassword(
      {required String email, required BuildContext context}) async {
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

  /// Verify email with 8-digit code
  Future<bool> verifyEmail({
    required String email,
    required String code,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.verifyEmail(
      email: email,
      code: code,
    );
    state = false;

    return res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
        return false;
      },
      (r) {
        if (context.mounted) {
          showSnackBar(context, r.message);

          // Navigate to sign in page after successful verification
          if (r.success && r.data?.requiresLogin == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
              (route) => false,
            );
          }
        }
        return r.success;
      },
    );
  }

  /// Resend verification code
  Future<bool> resendVerificationCode({
    required String email,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authRepository.resendVerification(
      email: email,
    );
    state = false;

    return res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
        return false;
      },
      (r) {
        if (context.mounted) {
          showSnackBar(context, r.message);
        }
        return r.success;
      },
    );
  }
}
