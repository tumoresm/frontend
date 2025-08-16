import 'dart:convert';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/core/core.dart';
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
  });
}

class FastAPIApi implements IFastAPIApi {
  @override
  FutureEither<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final endpoint = ApiConstants.registerEndpoint;
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': fullName,
          'phone': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        return right(null);
      } else {
        final errorData = jsonDecode(response.body);
        return left(Failure(errorData['detail'] ?? 'Failed to register user.',
            StackTrace.current));
      }
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
