// DEPRECATED: This file is no longer needed after FastAPI migration
// Authentication is now handled by FastAPI backend, not Appwrite
// This file is kept for reference but should not be used

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

/// DEPRECATED: Provider for Appwrite Auth API
/// Authentication is now handled by FastAPI
final authAPIProvider = Provider<IAuthAPI>((ref) {
  Loggers.auth.warning('authAPIProvider is deprecated after FastAPI migration');
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

/// DEPRECATED: Interface for Appwrite Auth API
/// Authentication is now handled by FastAPI
abstract class IAuthAPI {
  FutureEither<model.User> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  });

  FutureEither<model.Session> signIn({
    required String email,
    required String password,
  });

  Future<model.User?> getCurrentUser();

  FutureEitherVoid logout();
}

/// DEPRECATED: Appwrite Auth API implementation
/// Authentication is now handled by FastAPI
class AuthAPI implements IAuthAPI {
  final Account _account;

  AuthAPI({required Account account}) : _account = account;

  @override
  Future<model.User?> getCurrentUser() async {
    Loggers.auth.warning('AuthAPI.getCurrentUser is deprecated after FastAPI migration');
    return null;
  }

  @override
  FutureEither<model.User> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    Loggers.auth.warning('AuthAPI.signUp is deprecated after FastAPI migration');
    return left(Failure('Method deprecated after FastAPI migration', StackTrace.current));
  }

  @override
  FutureEither<model.Session> signIn({
    required String email,
    required String password,
  }) async {
    Loggers.auth.warning('AuthAPI.signIn is deprecated after FastAPI migration');
    return left(Failure('Method deprecated after FastAPI migration', StackTrace.current));
  }

  @override
  FutureEitherVoid logout() async {
    Loggers.auth.warning('AuthAPI.logout is deprecated after FastAPI migration');
    return left(Failure('Method deprecated after FastAPI migration', StackTrace.current));
  }
}