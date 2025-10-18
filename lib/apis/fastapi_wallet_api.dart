import 'dart:convert';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

/// Provider for FastAPI wallet API
final fastapiWalletAPIProvider = Provider<IFastAPIWalletAPI>((ref) {
  final httpClient = ref.watch(authenticatedHttpClientProvider);
  return FastAPIWalletAPI(httpClient);
});

/// Interface for wallet API operations
abstract class IFastAPIWalletAPI {
  /// Get user's wallet information
  FutureEither<WalletModel> getWallet();
  
  /// Get wallet transactions with optional filtering
  FutureEither<List<TransactionModel>> getTransactions({
    int? limit,
    int? offset,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get user's bank accounts
  FutureEither<List<BankAccountModel>> getBankAccounts();
  
  /// Add a new bank account
  FutureEither<BankAccountModel> addBankAccount(BankAccountModel bankAccount);
  
  /// Update a bank account
  FutureEither<BankAccountModel> updateBankAccount(String accountId, BankAccountModel bankAccount);
  
  /// Delete a bank account
  FutureEither<void> deleteBankAccount(String accountId);
  
  /// Set default bank account
  FutureEither<void> setDefaultBankAccount(String accountId);
  
  /// Get withdrawal requests
  FutureEither<List<WithdrawalRequestModel>> getWithdrawalRequests({
    int? limit,
    int? offset,
    WithdrawalStatus? status,
  });
  
  /// Create a withdrawal request
  FutureEither<WithdrawalRequestModel> createWithdrawalRequest({
    required double amount,
    required String bankAccountId,
  });
  
  /// Cancel a withdrawal request
  FutureEither<void> cancelWithdrawalRequest(String requestId);
  
  /// Get withdrawal request by ID
  FutureEither<WithdrawalRequestModel> getWithdrawalRequest(String requestId);
}

/// FastAPI implementation of wallet API
class FastAPIWalletAPI extends FastAPIRepository implements IFastAPIWalletAPI {
  FastAPIWalletAPI(super.httpClient);

  @override
  FutureEither<WalletModel> getWallet() async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.get('/wallet/me');
      
      final wallet = handleResponse<WalletModel>(
        response,
        (data) => WalletModel.fromMap(data),
        operation: 'Get wallet',
      );
      
      Loggers.database.info('Wallet retrieved successfully');
      return right(wallet);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get wallet: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<TransactionModel>> getTransactions({
    int? limit,
    int? offset,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (type != null) queryParams['type'] = type.value;
      if (status != null) queryParams['status'] = status.value;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/wallet/transactions${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await httpClient.get(endpoint);
      
      final transactions = handleListResponse<TransactionModel>(
        response,
        (data) => TransactionModel.fromMap(data),
        operation: 'Get transactions',
      );
      
      Loggers.database.info('Retrieved ${transactions.length} transactions');
      return right(transactions);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get transactions: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<BankAccountModel>> getBankAccounts() async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.get('/wallet/bank-accounts');
      
      final bankAccounts = handleListResponse<BankAccountModel>(
        response,
        (data) => BankAccountModel.fromMap(data),
        operation: 'Get bank accounts',
      );
      
      Loggers.database.info('Retrieved ${bankAccounts.length} bank accounts');
      return right(bankAccounts);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get bank accounts: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<BankAccountModel> addBankAccount(BankAccountModel bankAccount) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = bankAccount.toMap();
      // Remove fields that should be set by the server
      requestBody.remove('id');
      requestBody.remove('userId');
      requestBody.remove('createdAt');
      requestBody.remove('updatedAt');
      requestBody.remove('verifiedAt');
      
      final response = await httpClient.post(
        '/wallet/bank-accounts',
        body: requestBody,
      );
      
      final newBankAccount = handleResponse<BankAccountModel>(
        response,
        (data) => BankAccountModel.fromMap(data),
        operation: 'Add bank account',
      );
      
      Loggers.database.info('Bank account added successfully: ${newBankAccount.id}');
      return right(newBankAccount);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to add bank account: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<BankAccountModel> updateBankAccount(String accountId, BankAccountModel bankAccount) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = bankAccount.toMap();
      // Remove fields that shouldn't be updated
      requestBody.remove('id');
      requestBody.remove('userId');
      requestBody.remove('createdAt');
      requestBody.remove('verifiedAt');
      
      final response = await httpClient.put(
        '/wallet/bank-accounts/$accountId',
        body: requestBody,
      );
      
      final updatedBankAccount = handleResponse<BankAccountModel>(
        response,
        (data) => BankAccountModel.fromMap(data),
        operation: 'Update bank account',
      );
      
      Loggers.database.info('Bank account updated successfully: $accountId');
      return right(updatedBankAccount);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to update bank account: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<void> deleteBankAccount(String accountId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.delete('/wallet/bank-accounts/$accountId');
      
      handleVoidResponse(response, operation: 'Delete bank account');
      
      Loggers.database.info('Bank account deleted successfully: $accountId');
      return right(null);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to delete bank account: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<void> setDefaultBankAccount(String accountId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.patch(
        '/wallet/bank-accounts/$accountId/set-default',
      );
      
      handleVoidResponse(response, operation: 'Set default bank account');
      
      Loggers.database.info('Default bank account set successfully: $accountId');
      return right(null);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to set default bank account: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<WithdrawalRequestModel>> getWithdrawalRequests({
    int? limit,
    int? offset,
    WithdrawalStatus? status,
  }) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (status != null) queryParams['status'] = status.value;
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/wallet/withdrawal-requests${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await httpClient.get(endpoint);
      
      final withdrawalRequests = handleListResponse<WithdrawalRequestModel>(
        response,
        (data) => WithdrawalRequestModel.fromMap(data),
        operation: 'Get withdrawal requests',
      );
      
      Loggers.database.info('Retrieved ${withdrawalRequests.length} withdrawal requests');
      return right(withdrawalRequests);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get withdrawal requests: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<WithdrawalRequestModel> createWithdrawalRequest({
    required double amount,
    required String bankAccountId,
  }) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = {
        'amount': amount,
        'bankAccountId': bankAccountId,
      };
      
      final response = await httpClient.post(
        '/wallet/withdrawal-requests',
        body: requestBody,
      );
      
      final withdrawalRequest = handleResponse<WithdrawalRequestModel>(
        response,
        (data) => WithdrawalRequestModel.fromMap(data),
        operation: 'Create withdrawal request',
      );
      
      Loggers.database.info('Withdrawal request created successfully: ${withdrawalRequest.id}');
      return right(withdrawalRequest);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to create withdrawal request: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<void> cancelWithdrawalRequest(String requestId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.patch(
        '/wallet/withdrawal-requests/$requestId/cancel',
      );
      
      handleVoidResponse(response, operation: 'Cancel withdrawal request');
      
      Loggers.database.info('Withdrawal request cancelled successfully: $requestId');
      return right(null);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to cancel withdrawal request: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<WithdrawalRequestModel> getWithdrawalRequest(String requestId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.get('/wallet/withdrawal-requests/$requestId');
      
      final withdrawalRequest = handleResponse<WithdrawalRequestModel>(
        response,
        (data) => WithdrawalRequestModel.fromMap(data),
        operation: 'Get withdrawal request',
      );
      
      Loggers.database.info('Withdrawal request retrieved successfully: $requestId');
      return right(withdrawalRequest);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get withdrawal request: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }
}