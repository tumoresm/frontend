import 'dart:convert';

/// Model for email verification response
class EmailVerificationResponse {
  final bool success;
  final String message;
  final EmailVerificationData? data;

  const EmailVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EmailVerificationResponse.fromMap(Map<String, dynamic> map) {
    return EmailVerificationResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null 
          ? EmailVerificationData.fromMap(map['data']) 
          : null,
    );
  }

  factory EmailVerificationResponse.fromJson(String source) =>
      EmailVerificationResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}

/// Model for sign-in response
class SignInResponse {
  final bool success;
  final String message;
  final SignInData? data;

  const SignInResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SignInResponse.fromMap(Map<String, dynamic> map) {
    return SignInResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null 
          ? SignInData.fromMap(map['data']) 
          : null,
    );
  }

  factory SignInResponse.fromJson(String source) =>
      SignInResponse.fromMap(json.decode(source));
}

/// Data model for successful sign-in response
class SignInData {
  final String userId;
  final String email;
  final String fullName;
  final String accessToken;
  final String refreshToken;
  final String verificationStatus;
  final UserProfile? profile;

  const SignInData({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
    required this.verificationStatus,
    this.profile,
  });

  factory SignInData.fromMap(Map<String, dynamic> map) {
    return SignInData(
      userId: map['userId'] ?? map['user_id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? map['full_name'] ?? '',
      accessToken: map['accessToken'] ?? map['access_token'] ?? '',
      refreshToken: map['refreshToken'] ?? map['refresh_token'] ?? '',
      verificationStatus: map['verificationStatus'] ?? map['verification_status'] ?? 'Unverified',
      profile: map['profile'] != null 
          ? UserProfile.fromMap(map['profile']) 
          : null,
    );
  }
}

/// User profile data from sign-in
class UserProfile {
  final String? phoneNumber;
  final String? role;
  final String? address;
  final String? idNumber;
  final String? profileImage;
  final String? selectedAvatar;

  const UserProfile({
    this.phoneNumber,
    this.role,
    this.address,
    this.idNumber,
    this.profileImage,
    this.selectedAvatar,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      phoneNumber: map['phoneNumber'] ?? map['phone_number'],
      role: map['role'],
      address: map['address'],
      idNumber: map['idNumber'] ?? map['id_number'],
      profileImage: map['profileImage'] ?? map['profile_image'],
      selectedAvatar: map['selectedAvatar'] ?? map['selected_avatar'],
    );
  }
}

/// Data model for successful verification response
class EmailVerificationData {
  final String userId;
  final String email;
  final String verificationStatus;
  final bool requiresLogin;

  const EmailVerificationData({
    required this.userId,
    required this.email,
    required this.verificationStatus,
    required this.requiresLogin,
  });

  factory EmailVerificationData.fromMap(Map<String, dynamic> map) {
    return EmailVerificationData(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      verificationStatus: map['verificationStatus'] ?? '',
      requiresLogin: map['requiresLogin'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'verificationStatus': verificationStatus,
      'requiresLogin': requiresLogin,
    };
  }
}

/// Model for resend verification response
class ResendVerificationResponse {
  final bool success;
  final String message;
  final ResendVerificationData? data;

  const ResendVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ResendVerificationResponse.fromMap(Map<String, dynamic> map) {
    return ResendVerificationResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null 
          ? ResendVerificationData.fromMap(map['data']) 
          : null,
    );
  }

  factory ResendVerificationResponse.fromJson(String source) =>
      ResendVerificationResponse.fromMap(json.decode(source));
}

/// Data model for resend verification response
class ResendVerificationData {
  final String email;
  final String message;
  final int expiresInMinutes;

  const ResendVerificationData({
    required this.email,
    required this.message,
    required this.expiresInMinutes,
  });

  factory ResendVerificationData.fromMap(Map<String, dynamic> map) {
    return ResendVerificationData(
      email: map['email'] ?? '',
      message: map['message'] ?? '',
      expiresInMinutes: map['expiresInMinutes'] ?? 15,
    );
  }
}

/// Model for verification request
class VerificationRequest {
  final String email;
  final String code;

  const VerificationRequest({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'code': code,
    };
  }

  String toJson() => json.encode(toMap());
}

/// Model for resend verification request
class ResendVerificationRequest {
  final String email;

  const ResendVerificationRequest({
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }

  String toJson() => json.encode(toMap());
}