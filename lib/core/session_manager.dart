import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldforce/features/auth/model/verification_model.dart';
import 'package:fieldforce/core/logger.dart';

class SessionManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();
  
  SessionManager._();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save user session after successful sign-in
  Future<void> saveSession(SignInData signInData) async {
    try {
      await _initPrefs();
      
      Loggers.auth.info('Saving session for user: ${signInData.email}');
      
      // Save tokens
      await _prefs!.setString(_accessTokenKey, signInData.accessToken);
      await _prefs!.setString(_refreshTokenKey, signInData.refreshToken);
      
      // Prepare user data
      final userData = {
        'userId': signInData.userId,
        'email': signInData.email,
        'fullName': signInData.fullName,
        'verificationStatus': signInData.verificationStatus,
        'profile': signInData.profile != null ? {
          'phoneNumber': signInData.profile!.phoneNumber,
          'role': signInData.profile!.role,
          'address': signInData.profile!.address,
          'idNumber': signInData.profile!.idNumber,
          'profileImage': signInData.profile!.profileImage,
          'selectedAvatar': signInData.profile!.selectedAvatar,
        } : null,
      };
      
      // Save user data
      await _prefs!.setString(_userDataKey, jsonEncode(userData));
      await _prefs!.setBool(_isLoggedInKey, true);
      
      // Verify the data was saved
      final savedData = _prefs!.getString(_userDataKey);
      final savedLoginStatus = _prefs!.getBool(_isLoggedInKey);
      
      Loggers.auth.info('Session saved successfully for user: ${signInData.email}');
      Loggers.auth.debug('Saved data length: ${savedData?.length ?? 0}, login status: $savedLoginStatus');
      
    } catch (e) {
      Loggers.auth.error('Error saving session for user: ${signInData.email}', error: e);
      rethrow;
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    await _initPrefs();
    return _prefs!.getString(_accessTokenKey);
  }

  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    await _initPrefs();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      await _initPrefs();
      final userDataString = _prefs!.getString(_userDataKey);
      
      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        Loggers.auth.debug('Session data retrieved successfully for user: ${userData['email'] ?? 'unknown'}');
        return userData;
      } else {
        Loggers.auth.debug('No session data found in SharedPreferences');
        return null;
      }
    } catch (e) {
      Loggers.auth.error('Error retrieving session data', error: e);
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      await _initPrefs();
      final isLoggedIn = _prefs!.getBool(_isLoggedInKey) ?? false;
      final hasToken = _prefs!.getString(_accessTokenKey) != null;
      
      Loggers.auth.debug('Login status check: isLoggedIn=$isLoggedIn, hasToken=$hasToken');
      return isLoggedIn;
    } catch (e) {
      Loggers.auth.error('Error checking login status', error: e);
      return false;
    }
  }

  /// Update access token (for token refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    await _initPrefs();
    await _prefs!.setString(_accessTokenKey, newAccessToken);
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    await _initPrefs();
    await _prefs!.remove(_accessTokenKey);
    await _prefs!.remove(_refreshTokenKey);
    await _prefs!.remove(_userDataKey);
    await _prefs!.setBool(_isLoggedInKey, false);
    
    Loggers.auth.info('Session cleared successfully');
  }

  /// Update user profile data in session after successful profile update
  Future<void> updateUserProfile({
    required String address,
    required String idNumber,
    required String role,
    String? profileImage,
  }) async {
    await _initPrefs();
    final userDataString = _prefs!.getString(_userDataKey);
    
    if (userDataString != null) {
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      
      // Update the profile section
      final profile = userData['profile'] as Map<String, dynamic>? ?? {};
      profile['address'] = address;
      profile['idNumber'] = idNumber;
      profile['role'] = role;
      if (profileImage != null) {
        profile['profileImage'] = profileImage;
      }
      
      userData['profile'] = profile;
      
      // Save updated data back to preferences
      await _prefs!.setString(_userDataKey, jsonEncode(userData));
      
      Loggers.auth.info('Session profile data updated successfully');
    }
  }

  /// Get authorization header for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Debug method to log current session state
  Future<void> debugSessionState() async {
    try {
      await _initPrefs();
      
      final hasAccessToken = _prefs!.getString(_accessTokenKey) != null;
      final hasRefreshToken = _prefs!.getString(_refreshTokenKey) != null;
      final hasUserData = _prefs!.getString(_userDataKey) != null;
      final isLoggedInFlag = _prefs!.getBool(_isLoggedInKey) ?? false;
      
      final userDataString = _prefs!.getString(_userDataKey);
      String userEmail = 'none';
      if (userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          userEmail = userData['email'] ?? 'no email';
        } catch (e) {
          userEmail = 'invalid data';
        }
      }
      
      Loggers.auth.info('=== SESSION DEBUG ===');
      Loggers.auth.info('Has Access Token: $hasAccessToken');
      Loggers.auth.info('Has Refresh Token: $hasRefreshToken');
      Loggers.auth.info('Has User Data: $hasUserData');
      Loggers.auth.info('Is Logged In Flag: $isLoggedInFlag');
      Loggers.auth.info('User Email: $userEmail');
      Loggers.auth.info('=== END SESSION DEBUG ===');
      
    } catch (e) {
      Loggers.auth.error('Error debugging session state', error: e);
    }
  }
}