import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/apis/auth_api.dart';
import 'package:fieldforce/apis/user_api.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/auth/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

class AuthRepository {
  final IAuthAPI _authAPI;
  final IUserAPI _userAPI;

  AuthRepository({
    required IAuthAPI authAPI,
    required IUserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI;

  FutureEither<model.User> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String idDocumentUrl = '',
    String role = 'Rep',
    String address = '',
    String profileImageUrl = '',
    List<String> myCompaniesPortfolio = const <String>[],
  }) async {
    try {
      final res = await _authAPI.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      return res.fold(
        (l) => left(l),
        (r) async {
          // Create user document
          final userModel = UserModel(
            id: r.$id,
            email: email,
            fullName: fullName,
            phoneNumber: phoneNumber,
            role: role,
            address: address,
            idDocumentUrl: idDocumentUrl,
            profileImageUrl: profileImageUrl,
            verificationStatus: 'unverified',
            myCompaniesPortfolio: myCompaniesPortfolio,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final saveRes = await _userAPI.saveUserData(userModel);
          return saveRes.fold(
            (l) => left(l),
            (r) => right(userModel as model.User),
          );
        },
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEither<model.Session> signIn({
    required String email,
    required String password,
  }) async {
    return await _authAPI.signIn(email: email, password: password);
  }

  Future<model.User?> currentUser() => _authAPI.getCurrentUser();

  FutureEitherVoid logout() async {
    try {
      // Implementation for logout
      return right(null);
    } catch (e, stackTrace) {
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
}