import 'package:fieldforce/apis/fastapi_api.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/apis/auth_api.dart';
import 'package:fieldforce/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    authAPI: ref.watch(authAPIProvider),
    fastapiAPI: ref.watch(fastapiAPIProvider),
  );
});

class AuthRepository {
  final IAuthAPI _authAPI;
  final IFastAPIApi _fastapiAPI;

  AuthRepository({
    required IAuthAPI authAPI,
    required IFastAPIApi fastapiAPI,
  })  : _authAPI = authAPI,
        _fastapiAPI = fastapiAPI;

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
    );
  }

  FutureEither<model.Session> signIn({
    required String email,
    required String password,
  }) async {
    return await _authAPI.signIn(
      email: email,
      password: password,
    );
  }

  Future<model.User?> currentUser() => _authAPI.getCurrentUser();

  FutureEitherVoid logout() async {
    return _authAPI.logout();
  }

  FutureEitherVoid forgotPassword({required String email}) async {
    try {
      // Implementation for forgot password
      return right(null);
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
