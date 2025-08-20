
import 'dart:convert';
import 'package:fieldforce/constants/backend_constants.dart';
import 'package:http/http.dart' as http;
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final walletAPIProvider = Provider((ref) {
  return WalletAPI();
});

abstract class IWalletAPI {
  FutureEither<WalletModel> createWallet(WalletModel wallet);
  Future<WalletModel?> getWalletByUserId(String userId);
  FutureEither<WalletModel> updateBalance({
    required String walletId,
    required double amount,
    required String type,
  });
  FutureEither<WalletModel> getWallet();
  FutureEither<List<TransactionModel>> getTransactions();
  FutureEither<List<BankAccountModel>> getBankAccounts();
  FutureEither<BankAccountModel> createBankAccount(BankAccountModel bankAccount);
  FutureEither<List<WithdrawalRequestModel>> getWithdrawalRequests();
  FutureEither<WithdrawalRequestModel> createWithdrawalRequest(
      WithdrawalRequestModel withdrawalRequest);
  FutureEither<WalletModel> depositFunds(
      {required double amount, required String currency});
  FutureEither<WalletModel> withdrawFunds(
      {required double amount, required String currency});
  FutureEither<String> transferFunds(
      {required String recipientId,
      required double amount,
      required String currency});
}

class WalletAPI implements IWalletAPI {
  String get _baseUrl => BackendConstants.apiBaseUrl;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  FutureEither<WalletModel> createWallet(WalletModel wallet) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(wallet.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WalletModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to create wallet: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WalletModel.fromMap(data);
      } else if (response.statusCode == 404) {
        // Wallet not found for user
        return null;
      } else {
        throw Exception('Failed to get wallet: ${response.statusCode}');
      }
    } catch (e) {
      // Return null for graceful degradation during migration
      return null;
    }
  }

  @override
  FutureEither<WalletModel> updateBalance({
    required String walletId,
    required double amount,
    required String type,
  }) async {
    try {
      final token = await _getAccessToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/wallet/$walletId/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WalletModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to update balance: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<WalletModel> getWallet() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/wallet'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WalletModel.fromMap(data));
      } else {
        return left(Failure('Failed to get wallet: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<TransactionModel>> getTransactions() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final transactions =
            data.map((e) => TransactionModel.fromMap(e)).toList();
        return right(transactions);
      } else {
        return left(Failure(
            'Failed to get transactions: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<BankAccountModel>> getBankAccounts() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/bank_accounts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final bankAccounts =
            data.map((e) => BankAccountModel.fromMap(e)).toList();
        return right(bankAccounts);
      } else {
        return left(Failure(
            'Failed to get bank accounts: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<BankAccountModel> createBankAccount(
      BankAccountModel bankAccount) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/bank_accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bankAccount.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(BankAccountModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to create bank account: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<List<WithdrawalRequestModel>> getWithdrawalRequests() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/withdrawal_requests'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final withdrawalRequests =
            data.map((e) => WithdrawalRequestModel.fromMap(e)).toList();
        return right(withdrawalRequests);
      } else {
        return left(Failure(
            'Failed to get withdrawal requests: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<WithdrawalRequestModel> createWithdrawalRequest(
      WithdrawalRequestModel withdrawalRequest) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/withdrawal_requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(withdrawalRequest.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WithdrawalRequestModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to create withdrawal request: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<WalletModel> depositFunds(
      {required double amount, required String currency}) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/wallet/deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WalletModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to deposit funds: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<WalletModel> withdrawFunds(
      {required double amount, required String currency}) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/wallet/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(WalletModel.fromMap(data));
      } else {
        return left(Failure(
            'Failed to withdraw funds: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<String> transferFunds(
      {required String recipientId,
      required double amount,
      required String currency}) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/wallet/wallet/transfer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipient_id': recipientId,
          'amount': amount,
          'currency': currency
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(data['message']);
      } else {
        return left(Failure(
            'Failed to transfer funds: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
