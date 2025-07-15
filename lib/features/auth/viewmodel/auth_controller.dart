import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/apis/auth_api.dart';
import 'package:fieldforce/apis/user_api.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/home/view/pages/home_page.dart';
import 'package:fieldforce/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/core/core.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getCurrentUser();
});

class AuthController extends StateNotifier<bool> {
  final IAuthAPI _authAPI;
  final IUserAPI _userAPI;

  AuthController({
    required IAuthAPI authAPI,
    required IUserAPI userAPI,
  })  : _authAPI = authAPI, // Depend on abstractions
        _userAPI = userAPI,
        super(false);

  //state = isLoading

  //_account.get() !=null ? HomePage : SignIn
  Future<model.User?> getCurrentUser() => _authAPI.getCurrentUser();

  void signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        // Success! `r` is the Appwrite User object
        UserModel userModel = UserModel(
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
          profileImageUrl: null, // Use null for nullable fields
          idDocumentUrl: null, // Use null for nullable fields
          id: r.$id, // Use the ID from the authenticated user
          verificationStatus: 'not_verified',
          address: '',
        );
        final res2 = await _userAPI.saveUserData(userModel);
        res2.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Account created! Please login.');
          Navigator.push(context, SignInPage.route());
        });
      },
    );
  }

  void signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signIn(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        Navigator.push(context, HomePage.route());
      },
    );
  }
}
