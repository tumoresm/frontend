import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/core/providers.dart';
import 'package:fieldforce/core/failure.dart';
import 'package:fieldforce/core/type_defs.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:fieldforce/constants/verification_constants.dart';
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    account: ref.watch(appwriteAccountProvider),
    databases: ref.watch(appwriteDatabasesProvider),
  );
});

class AuthRepository {
  final Account _account;
  final Databases _databases;

  AuthRepository({
    required Account account,
    required Databases databases,
  })  : _account = account,
        _databases = databases;

  FutureEither<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String address = '', // ✅ OPTIONAL for initial signup
    String idDocumentUrl = '', // ✅ OPTIONAL for initial signup
    String role = 'Rep', // ✅ OPTIONAL with default
    String profileImageUrl = '', // ✅ OPTIONAL with default
    List<String>? myCompaniesPortfolio,
  }) async {
    try {
      // Validate input parameters
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        return left(Failure(
            'Email, password, and full name are required fields.',
            StackTrace.current));
      }

      // Additional validation
      if (phoneNumber.isEmpty) {
        return left(Failure('Phone number is required.', StackTrace.current));
      }

      // Basic email validation
      if (!email.contains('@') || !email.contains('.')) {
        return left(
            Failure('Please enter a valid email address.', StackTrace.current));
      }

      // Password strength validation
      if (password.length < 8) {
        return left(Failure('Password must be at least 8 characters long.',
            StackTrace.current));
      }

      Loggers.auth.info('Creating Appwrite account for: $email');

      // Create Appwrite account
      final user = await _account.create(
        userId: ID.unique(),
        email: email.trim().toLowerCase(),
        password: password,
        name: fullName.trim(),
      );

      Loggers.auth.info('Appwrite account created successfully: ${user.$id}');

      // Create user document in database
      final userData = {
        'email': email.trim().toLowerCase(),
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'address': address.trim(),
        'idDocumentUrl': idDocumentUrl.isEmpty ? '' : idDocumentUrl.trim(),
        'role': role,
        'profileImageUrl':
            profileImageUrl.isEmpty ? '' : profileImageUrl.trim(),
        'verificationStatus': VerificationStatus.unverified,
        'myCompaniesPortfolio': myCompaniesPortfolio ?? [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      try {
        final document = await _databases.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: user.$id,
          data: userData,
        );

        Loggers.auth.info('User document created successfully in database');

        // Create UserModel from the document
        final dataWithId = Map<String, dynamic>.from(document.data);
        dataWithId['\$id'] = document.$id;

        final userModel = UserModel.fromMap(dataWithId);

        Loggers.auth.info('User registration completed successfully');
        return right(userModel);
      } catch (dbError) {
        Loggers.auth.error('Failed to create user document in database',
            error: dbError);
        // Account was created but document creation failed
        // Try to delete the account to maintain consistency
        try {
          await _account.deleteIdentity(identityId: user.$id);
          Loggers.auth.info('Cleaned up orphaned account after database error');
        } catch (cleanupError) {
          Loggers.auth.warning('Could not clean up orphaned account',
              error: cleanupError);
        }

        return left(Failure(
            'Account creation failed. Please try again.', StackTrace.current));
      }
    } on AppwriteException catch (e, stackTrace) {
      String errorMessage = e.message ?? 'Registration failed';

      // Handle specific Appwrite error cases
      if (e.code == 409) {
        errorMessage =
            'An account with this email already exists. Please use a different email or try logging in.';
      } else if (e.code == 400) {
        errorMessage =
            'Invalid registration data. Please check your information and try again.';
      } else if (e.code == 429) {
        errorMessage =
            'Too many registration attempts. Please wait a moment and try again.';
      } else if (e.code == 500) {
        errorMessage = 'Server error occurred. Please try again later.';
      }

      Loggers.auth.error('Appwrite registration error: ${e.message}', error: e);
      return left(Failure(errorMessage, stackTrace));
    } catch (e, stackTrace) {
      String errorMessage = 'An unexpected error occurred during registration.';

      if (e.toString().contains('timeout')) {
        errorMessage = 'Registration request timed out. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Network connection failed. Please check your internet connection.';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage =
            'SSL connection failed. Please check your internet connection.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Please try again later.';
      }

      Loggers.auth.error('Unexpected registration error', error: e);
      return left(Failure(errorMessage, stackTrace));
    }
  }

  FutureEither<Session> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input parameters
      if (email.isEmpty || password.isEmpty) {
        return left(
            Failure('Email and password are required.', StackTrace.current));
      }

      // Basic email validation
      if (!email.contains('@') || !email.contains('.')) {
        return left(
            Failure('Please enter a valid email address.', StackTrace.current));
      }

      Loggers.auth.info('Attempting to sign in with Appwrite: $email');

      // First, check if there's already an active session
      try {
        final existingUser = await _account.get();
        if (existingUser.email == email) {
          Loggers.auth.info('Already signed in with the same email');
          // Try to get the current session
          try {
            final sessions = await _account.listSessions();
            if (sessions.sessions.isNotEmpty) {
              Loggers.auth.info('Using existing session');
              return right(sessions.sessions.first);
            }
          } catch (sessionError) {
            Loggers.auth.warning(
                'Could not retrieve existing session, will create new one');
          }
        } else {
          Loggers.auth.info(
              'Different user signed in (${existingUser.email}), clearing session');
          await _account.deleteSession(sessionId: 'current');
        }
      } catch (e) {
        // No existing session found, proceed with new sign-in
        Loggers.auth
            .info('No existing session found, proceeding with new sign-in');
      }

      // Create new session
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      Loggers.auth.info('Sign-in successful! Session ID: ${session.$id}');
      Loggers.auth.debug('Session user ID: ${session.userId}');

      // Verify the session by immediately checking current user
      try {
        final currentUser = await _account.get();
        Loggers.auth
            .info('Session verification successful: ${currentUser.email}');
      } catch (verificationError) {
        // Session verification failed - this is concerning
        Loggers.auth
            .warning('Session verification failed', error: verificationError);
        // Don't fail the sign-in, but log the issue
      }

      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      // Handle specific error cases
      if (e.code == 401) {
        if (e.message != null && e.message!.contains('session is active')) {
          // Try to clear existing session and retry once
          try {
            await _account.deleteSession(sessionId: 'current');
            Loggers.auth.info('Cleared existing session, retrying sign-in');

            // Add a small delay before retry
            await Future.delayed(const Duration(milliseconds: 500));

            final session = await _account.createEmailPasswordSession(
              email: email,
              password: password,
            );
            Loggers.auth
                .info('Retry sign-in successful! Session ID: ${session.$id}');
            return right(session);
          } catch (retryError) {
            Loggers.auth.error('Retry failed', error: retryError);
            return left(Failure(
                'Failed to clear existing session and retry. Please try again.',
                stackTrace));
          }
        } else {
          return left(Failure(
              'Invalid email or password. Please check your credentials and try again.',
              stackTrace));
        }
      } else if (e.code == 429) {
        return left(Failure(
            'Too many sign-in attempts. Please wait a moment and try again.',
            stackTrace));
      } else if (e.code == 500) {
        return left(Failure(
            'Server error occurred. Please try again later.', stackTrace));
      }

      // Generic Appwrite error
      return left(Failure(
          e.message ?? 'Sign-in failed. Please try again.', stackTrace));
    } on TimeoutException catch (e, stackTrace) {
      return left(Failure(
          'Sign-in request timed out. Please check your internet connection and try again.',
          stackTrace));
    } catch (e, stackTrace) {
      String errorMessage = 'Unexpected error during sign-in.';

      if (e.toString().contains('timeout')) {
        errorMessage = 'Sign-in request timed out. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Network connection failed. Please check your internet connection.';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage =
            'SSL connection failed. Please check your internet connection.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage =
            'Cannot connect to authentication server. Please try again later.';
      }

      return left(Failure(errorMessage, stackTrace));
    }
  }

  Future<User?> currentUser() async {
    try {
      Loggers.auth.debug('Attempting to get current user from Appwrite...');
      final user = await _account.get();
      Loggers.auth.info('Successfully got current user: ${user.email}');
      return user;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // No authenticated session - this is expected when user is not signed in
        Loggers.auth.debug('No authenticated session found');
        return null;
      }
      // For other Appwrite exceptions, rethrow with context
      Loggers.auth.error('Appwrite error getting current user', error: e);
      rethrow;
    } catch (e) {
      // For unexpected errors, log and rethrow
      Loggers.auth.error('Unexpected error getting current user', error: e);
      rethrow;
    }
  }

  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      Loggers.auth.info('Successfully logged out');
      return right(());
    } on AppwriteException catch (e, stackTrace) {
      String errorMessage = e.message ?? 'Logout failed';

      // Handle specific logout error cases
      if (e.code == 401) {
        errorMessage = 'No active session to logout from';
      } else if (e.code == 404) {
        errorMessage = 'Session not found - user may already be logged out';
      } else if (e.code == 500) {
        errorMessage = 'Server error during logout. Please try again.';
      }

      return left(Failure(errorMessage, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(
          'Unexpected error during logout: ${e.toString()}', stackTrace));
    }
  }

  FutureEitherVoid forgotPassword({required String email}) async {
    try {
      Loggers.auth.info('Attempting to initiate password recovery for: $email');

      // Validate email
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        return left(Failure('Please enter a valid email address.', StackTrace.current));
      }

      await _account.createRecovery(
        email: email,
        url: 'http://192.168.100.5/reset_password.html', // This URL should point to your password reset page
      );

      Loggers.auth.info('Password recovery email sent successfully to: $email');
      return right(());
    } on AppwriteException catch (e, stackTrace) {
      String errorMessage = e.message ?? 'Password recovery failed';

      if (e.code == 404) {
        errorMessage = 'User with this email not found.';
      } else if (e.code == 429) {
        errorMessage = 'Too many recovery attempts. Please try again later.';
      } else if (e.code == 500) {
        errorMessage = 'Server error occurred. Please try again later.';
      }

      Loggers.auth.error('Appwrite password recovery error: ${e.message}', error: e);
      return left(Failure(errorMessage, stackTrace));
    } catch (e, stackTrace) {
      String errorMessage = 'An unexpected error occurred during password recovery.';
      Loggers.auth.error('Unexpected password recovery error', error: e);
      return left(Failure(errorMessage, stackTrace));
    }
  }
}
