import 'package:fieldforce/apis/fastapi_api.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/auth/model/verification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    fastapiAPI: ref.watch(fastapiAPIProvider),
  );
});

class AuthRepository {
  final IFastAPIApi _fastapiAPI;

  AuthRepository({
    required IFastAPIApi fastapiAPI,
  }) : _fastapiAPI = fastapiAPI;

  FutureEither<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String? selectedAvatar,
  }) async {
    return _fastapiAPI.registerUser(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      selectedAvatar: selectedAvatar,
    );
  }

  FutureEither<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _fastapiAPI.signIn(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>?> currentUser() async {
    return await SessionManager.instance.getUserData();
  }

  FutureEitherVoid logout() async {
    try {
      // Call server-side logout first
      final result = await _fastapiAPI.logout();
      
      return result.fold(
        (failure) {
          // Even if server logout fails, clear local session
          SessionManager.instance.clearSession();
          return left(failure);
        },
        (success) async {
          // Clear local session after successful server logout
          await SessionManager.instance.clearSession();
          return right(null);
        },
      );
    } catch (e, stackTrace) {
      // Ensure local session is cleared even if there's an error
      try {
        await SessionManager.instance.clearSession();
      } catch (_) {
        // Ignore errors in local cleanup
      }
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid forgotPassword({required String email}) async {
    try {
      // Implementation for forgot password
      return right(null);
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEither<EmailVerificationResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    return _fastapiAPI.verifyEmail(
      email: email,
      code: code,
    );
  }

  FutureEither<ResendVerificationResponse> resendVerification({
    required String email,
  }) async {
    return _fastapiAPI.resendVerification(
      email: email,
    );
  }
}
