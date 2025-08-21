import 'dart:convert';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/auth/model/verification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

final fastapiAPIProvider = Provider((ref) {
  return FastAPIApi();
});

abstract class IFastAPIApi {
  FutureEither<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? selectedAvatar,
  });

  FutureEither<SignInResponse> signIn({
    required String email,
    required String password,
  });

  FutureEither<void> logout();

  FutureEither<EmailVerificationResponse> verifyEmail({
    required String email,
    required String code,
  });

  FutureEither<ResendVerificationResponse> resendVerification({
    required String email,
  });
}

class FastAPIApi implements IFastAPIApi {
  @override
  FutureEither<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? selectedAvatar,
  }) async {
    try {
      final endpoint = ApiConstants.registerEndpoint;
      Loggers.auth.info('Registering user at: $endpoint');
      Loggers.auth.debug('Email: $email');

      final requestBody = {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phoneNumber,
        if (selectedAvatar != null) 'selectedAvatar': selectedAvatar,
      };

      Loggers.auth.debug('Request body prepared for registration');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: ApiConstants.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConstants.requestTimeout);

      Loggers.auth.debug('Response status: ${response.statusCode}');
      Loggers.auth.debug('Response received from registration endpoint');

      if (response.statusCode == 201) {
        Loggers.auth.info(
            'User registration successful - verification email should be sent');
        return right(null);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to register user.';
        if (errorData['detail'] is List) {
          errorMessage = errorData['detail'][0]['msg'];
        } else if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.auth.error('Registration failed: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.auth.error('Registration error: $e');
      String userFriendlyMessage = 'Registration failed. ';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        userFriendlyMessage +=
            'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEither<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final endpoint = ApiConstants.loginEndpoint;
      Loggers.auth.info('Signing in user at: $endpoint');
      Loggers.auth.debug('Email: $email');

      final requestBody = {
        'email': email,
        'password': password,
      };

      Loggers.auth.debug('Request body prepared for sign-in');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: ApiConstants.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConstants.requestTimeout);

      Loggers.auth.debug('Response status: ${response.statusCode}');
      Loggers.auth.debug('Response received from sign-in endpoint');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Loggers.auth.info('User sign-in successful');
        return right(SignInResponse.fromMap(responseData));
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Sign-in failed.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] is String) {
          errorMessage = errorData['error'];
        }
        Loggers.auth.error('Sign-in failed: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.auth.error('Sign-in error: $e');
      String userFriendlyMessage = 'Sign-in failed. ';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        userFriendlyMessage +=
            'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please check your credentials and try again.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      final sessionManager = SessionManager.instance;
      final accessToken = await sessionManager.getAccessToken();
      
      if (accessToken == null) {
        Loggers.auth.warning('No access token found for logout');
        // Still return success since there's no session to invalidate
        return right(null);
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
      ).timeout(ApiConstants.requestTimeout);

      Loggers.auth.debug('Logout response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Loggers.auth.info('Server logout successful');
        return right(null);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Logout failed on server.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.auth.warning('Server logout failed: $errorMessage');
        // Don't return error - we'll still clear local session
        return right(null);
      }
    } catch (e, stackTrace) {
      Loggers.auth.warning('Server logout error: $e');
      // Don't return error - we'll still clear local session
      return right(null);
    }
  }

  @override
  FutureEither<EmailVerificationResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final endpoint = '${ApiConstants.baseUrl}/auth/verify-email';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return right(EmailVerificationResponse.fromMap(responseData));
      } else {
        String errorMessage = 'Email verification failed.';
        if (responseData['detail'] is String) {
          errorMessage = responseData['detail'];
        } else if (responseData['message'] is String) {
          errorMessage = responseData['message'];
        }
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<ResendVerificationResponse> resendVerification({
    required String email,
  }) async {
    try {
      final endpoint = '${ApiConstants.baseUrl}/auth/resend-verification';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return right(ResendVerificationResponse.fromMap(responseData));
      } else {
        String errorMessage = 'Failed to resend verification code.';
        if (responseData['detail'] is String) {
          errorMessage = responseData['detail'];
        } else if (responseData['message'] is String) {
          errorMessage = responseData['message'];
        }
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
