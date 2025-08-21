import 'dart:convert';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/core/session_manager.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

final userAPIProvider = Provider<IUserAPI>((ref) {
  return UserAPI();
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  FutureEither<UserModel> getUserById(String userId);
  FutureEither<UserModel> updateUserProfile(UserModel userModel);
  FutureEither<UserModel> getCurrentUser();
  FutureEither<List<UserModel>> searchUsers(String query);
  FutureEitherVoid deleteUser(String userId);
  FutureEither<bool> checkEmailAvailability(String email);
}

class UserAPI implements IUserAPI {
  UserAPI();

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      // In the FastAPI system, user data is saved during registration
      // This method is kept for backward compatibility but now updates the session
      Loggers.database.info('Saving user data to session for user: ${userModel.email}');
      
      // Update session data if user is logged in
      final sessionManager = SessionManager.instance;
      final isLoggedIn = await sessionManager.isLoggedIn();
      
      if (isLoggedIn) {
        // Update session with new user data
        await sessionManager.updateUserProfile(
          address: userModel.address,
          idNumber: userModel.idNumber ?? '',
          role: userModel.role,
          profileImage: userModel.profileImage,
        );
        Loggers.database.info('User data saved to session successfully');
      }
      
      return right(null);
    } catch (e, st) {
      Loggers.database.error('Error saving user data: $e');
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<UserModel> getUserById(String userId) async {
    try {
      final endpoint = ApiConstants.getUserProfileEndpoint(userId);
      Loggers.database.info('Fetching user profile from: $endpoint');
      
      final sessionManager = SessionManager.instance;
      final headers = await sessionManager.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);

      Loggers.database.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle both direct user data and wrapped response
        final userData = responseData['data'] ?? responseData;
        
        final userModel = UserModel.fromMap(userData);
        Loggers.database.info('User profile fetched successfully for: ${userModel.email}');
        return right(userModel);
      } else if (response.statusCode == 404) {
        Loggers.database.warning('User not found: $userId');
        return left(Failure('User not found', StackTrace.current));
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to fetch user profile.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.database.error('Failed to fetch user profile: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error fetching user profile: $e');
      String userFriendlyMessage = 'Failed to fetch user profile. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEither<UserModel> updateUserProfile(UserModel userModel) async {
    try {
      final endpoint = ApiConstants.updateProfileEndpoint;
      Loggers.database.info('Updating user profile at: $endpoint');
      
      final sessionManager = SessionManager.instance;
      final headers = await sessionManager.getAuthHeaders();
      
      final requestBody = {
        'fullName': userModel.fullName,
        'phoneNumber': userModel.phoneNumber,
        'role': userModel.role,
        'address': userModel.address,
        'idNumber': userModel.idNumber,
        'selectedAvatar': userModel.selectedAvatar,
        // Note: profileImage should be handled separately via file upload
      };
      
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.requestTimeout);

      Loggers.database.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Update local session data
        await sessionManager.updateUserProfile(
          address: userModel.address,
          idNumber: userModel.idNumber ?? '',
          role: userModel.role,
          profileImage: userModel.profileImage,
        );
        
        Loggers.database.info('User profile updated successfully');
        return right(userModel);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to update user profile.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.database.error('Failed to update user profile: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error updating user profile: $e');
      String userFriendlyMessage = 'Failed to update user profile. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEither<UserModel> getCurrentUser() async {
    try {
      final sessionManager = SessionManager.instance;
      final userData = await sessionManager.getUserData();
      
      if (userData == null) {
        Loggers.database.warning('No user data found in session');
        return left(Failure('No user session found', StackTrace.current));
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
        verificationStatus: userData['verificationStatus'] ?? 'unverified',
        myCompaniesPortfolio: [],
        createdAt: null,
        updatedAt: null,
      );
      
      Loggers.database.info('Current user retrieved from session: ${userModel.email}');
      return right(userModel);
    } catch (e, stackTrace) {
      Loggers.database.error('Error getting current user: $e');
      return left(Failure('Failed to get current user: $e', stackTrace));
    }
  }

  @override
  FutureEither<List<UserModel>> searchUsers(String query) async {
    try {
      final endpoint = '${ApiConstants.baseUrl}/users/search';
      Loggers.database.info('Searching users with query: $query');
      
      final sessionManager = SessionManager.instance;
      final headers = await sessionManager.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$endpoint?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);

      Loggers.database.debug('Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final usersData = responseData['data'] ?? responseData;
        
        if (usersData is List) {
          final users = usersData
              .map((userData) => UserModel.fromMap(userData as Map<String, dynamic>))
              .toList();
          
          Loggers.database.info('Found ${users.length} users matching query: $query');
          return right(users);
        } else {
          Loggers.database.error('Invalid response format for user search');
          return left(Failure('Invalid response format', StackTrace.current));
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to search users.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.database.error('User search failed: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error searching users: $e');
      String userFriendlyMessage = 'Failed to search users. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEitherVoid deleteUser(String userId) async {
    try {
      final endpoint = '${ApiConstants.baseUrl}/users/$userId';
      Loggers.database.info('Deleting user: $userId');
      
      final sessionManager = SessionManager.instance;
      final headers = await sessionManager.getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);

      Loggers.database.debug('Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Loggers.database.info('User deleted successfully: $userId');
        
        // Clear session if deleting current user
        final currentUserData = await sessionManager.getUserData();
        if (currentUserData != null && currentUserData['userId'] == userId) {
          await sessionManager.clearSession();
          Loggers.database.info('Current user session cleared after account deletion');
        }
        
        return right(null);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to delete user.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.database.error('User deletion failed: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error deleting user: $e');
      String userFriendlyMessage = 'Failed to delete user. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }

  @override
  FutureEither<bool> checkEmailAvailability(String email) async {
    try {
      final endpoint = '${ApiConstants.baseUrl}/users/check-email';
      Loggers.database.info('Checking email availability: $email');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({'email': email}),
      ).timeout(ApiConstants.requestTimeout);

      Loggers.database.debug('Email check response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final isAvailable = responseData['available'] ?? false;
        
        Loggers.database.info('Email $email availability: $isAvailable');
        return right(isAvailable);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to check email availability.';
        if (errorData['detail'] is String) {
          errorMessage = errorData['detail'];
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
        Loggers.database.error('Email availability check failed: $errorMessage');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error checking email availability: $e');
      String userFriendlyMessage = 'Failed to check email availability. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }
}