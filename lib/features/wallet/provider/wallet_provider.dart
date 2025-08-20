import 'package:fieldforce/apis/wallet_api.dart';
import 'package:fieldforce/apis/transaction_api.dart';
import 'package:fieldforce/apis/bank_account_api.dart';
import 'package:fieldforce/apis/withdrawal_request_api.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Wallet Data Providers
final getUserWalletProvider = FutureProvider((ref) async {
  try {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return null;

    final userId = user['userId'] as String?;
    if (userId == null) return null;

    final walletController = ref.watch(walletControllerProvider.notifier);
    return await walletController.getUserWallet(userId);
  } catch (e) {
    Loggers.database
        .warning('Wallet API not available (Appwrite auth issue): $e');
    Loggers.database
        .info('Returning null wallet until migration to FastAPI is complete');
    return null;
  }
}, name: 'getUserWalletProvider');

final getUserTransactionsProvider = FutureProvider((ref) async {
  try {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return <TransactionModel>[];

    final userId = user['userId'] as String?;
    if (userId == null) return <TransactionModel>[];

    final walletController = ref.watch(walletControllerProvider.notifier);
    return await walletController.getUserTransactions(userId);
  } catch (e) {
    Loggers.database
        .warning('Transactions API not available (Appwrite auth issue): $e');
    Loggers.database.info(
        'Returning empty transactions list until migration to FastAPI is complete');
    return <TransactionModel>[];
  }
}, name: 'getUserTransactionsProvider');

final getUserBankAccountsProvider = FutureProvider((ref) async {
  try {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return <BankAccountModel>[];

    final userId = user['userId'] as String?;
    if (userId == null) return <BankAccountModel>[];

    final walletController = ref.watch(walletControllerProvider.notifier);
    return await walletController.getUserBankAccounts(userId);
  } catch (e) {
    Loggers.database
        .warning('Bank accounts API not available (Appwrite auth issue): $e');
    Loggers.database.info(
        'Returning empty bank accounts list until migration to FastAPI is complete');
    return <BankAccountModel>[];
  }
}, name: 'getUserBankAccountsProvider');

final getUserWithdrawalRequestsProvider = FutureProvider((ref) async {
  try {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return <WithdrawalRequestModel>[];

    final userId = user['userId'] as String?;
    if (userId == null) return <WithdrawalRequestModel>[];

    final walletController = ref.watch(walletControllerProvider.notifier);
    return await walletController.getUserWithdrawalRequests(userId);
  } catch (e) {
    Loggers.database.warning(
        'Withdrawal requests API not available (Appwrite auth issue): $e');
    Loggers.database.info(
        'Returning empty withdrawal requests list until migration to FastAPI is complete');
    return <WithdrawalRequestModel>[];
  }
}, name: 'getUserWithdrawalRequestsProvider');

// Filtered Transaction Providers
final getTransactionsByTypeProvider =
    FutureProvider.family<List<TransactionModel>, TransactionType>(
        (ref, type) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return <TransactionModel>[];

  final userId = user['userId'] as String?;
  if (userId == null) return <TransactionModel>[];

  final walletController = ref.watch(walletControllerProvider.notifier);
  return walletController.getTransactionsByType(userId, type);
});

final getTransactionsByDateRangeProvider =
    FutureProvider.family<List<TransactionModel>, Map<String, DateTime>>(
        (ref, dateRange) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return <TransactionModel>[];

  final userId = user['userId'] as String?;
  if (userId == null) return <TransactionModel>[];

  final walletController = ref.watch(walletControllerProvider.notifier);
  return walletController.getTransactionsByDateRange(
    userId,
    dateRange['startDate']!,
    dateRange['endDate']!,
  );
});

// Wallet Controller Provider
final walletControllerProvider =
    StateNotifierProvider<WalletController, bool>((ref) {
  return WalletController(
    walletAPI: ref.watch(walletAPIProvider),
    transactionAPI: ref.watch(transactionAPIProvider),
    bankAccountAPI: ref.watch(bankAccountAPIProvider),
    withdrawalRequestAPI: ref.watch(withdrawalRequestAPIProvider),
    ref: ref,
  );
});

class WalletController extends StateNotifier<bool> {
  final IWalletAPI _walletAPI;
  final ITransactionAPI _transactionAPI;
  final IBankAccountAPI _bankAccountAPI;
  final IWithdrawalRequestAPI _withdrawalRequestAPI;
  final Ref _ref;

  WalletController({
    required IWalletAPI walletAPI,
    required ITransactionAPI transactionAPI,
    required IBankAccountAPI bankAccountAPI,
    required IWithdrawalRequestAPI withdrawalRequestAPI,
    required Ref ref,
  })  : _walletAPI = walletAPI,
        _transactionAPI = transactionAPI,
        _bankAccountAPI = bankAccountAPI,
        _withdrawalRequestAPI = withdrawalRequestAPI,
        _ref = ref,
        super(false);

  // Wallet Operations
  Future<WalletModel?> getUserWallet(String userId) async {
    return await _walletAPI.getWalletByUserId(userId);
  }

  Future<void> createWallet({
    required String userId,
    required BuildContext context,
  }) async {
    state = true;

    final wallet = WalletModel(
      id: '', // Will be assigned by database
      userId: userId,
      currentBalance: 0.0,
      totalEarnings: 0.0,
      pendingEarnings: 0.0,
      reservedAmount: 0.0,
      lastUpdated: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final res = await _walletAPI.createWallet(wallet);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Wallet created successfully!');
        // Refresh wallet data
        _ref.refresh(getUserWalletProvider);
      },
    );
  }

  Future<void> updateBalance({
    required String walletId,
    required double amount,
    required String type,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _walletAPI.updateBalance(
      walletId: walletId,
      amount: amount,
      type: type,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // Refresh wallet data
        _ref.refresh(getUserWalletProvider);
      },
    );
  }

  // Transaction Operations
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    return await _transactionAPI.getTransactionsByUserId(userId);
  }

  Future<List<TransactionModel>> getTransactionsByType(
      String userId, TransactionType type) async {
    return await _transactionAPI.getTransactionsByType(
        userId: userId, type: type);
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _transactionAPI.getTransactionsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> createTransaction({
    required TransactionModel transaction,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _transactionAPI.createTransaction(transaction);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // Refresh transaction data
        _ref.refresh(getUserTransactionsProvider);
        _ref.refresh(getUserWalletProvider);
      },
    );
  }

  // Bank Account Operations
  Future<List<BankAccountModel>> getUserBankAccounts(String userId) async {
    return await _bankAccountAPI.getBankAccountsByUserId(userId);
  }

  Future<void> addBankAccount({
    required BankAccountModel bankAccount,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _bankAccountAPI.createBankAccount(bankAccount);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Bank account added successfully!');
        _ref.refresh(getUserBankAccountsProvider);
      },
    );
  }

  Future<void> updateBankAccount({
    required BankAccountModel bankAccount,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _bankAccountAPI.updateBankAccount(bankAccount);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Bank account updated successfully!');
        _ref.refresh(getUserBankAccountsProvider);
      },
    );
  }

  Future<void> deleteBankAccount({
    required String bankAccountId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _bankAccountAPI.deleteBankAccount(bankAccountId);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Bank account deleted successfully!');
        _ref.refresh(getUserBankAccountsProvider);
      },
    );
  }

  Future<void> setDefaultBankAccount({
    required String userId,
    required String bankAccountId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _bankAccountAPI.setDefaultBankAccount(
      userId: userId,
      bankAccountId: bankAccountId,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Default bank account updated!');
        _ref.refresh(getUserBankAccountsProvider);
      },
    );
  }

  // Withdrawal Request Operations
  Future<List<WithdrawalRequestModel>> getUserWithdrawalRequests(
      String userId) async {
    return await _withdrawalRequestAPI.getWithdrawalRequestsByUserId(userId);
  }

  Future<void> createWithdrawalRequest({
    required WithdrawalRequestModel request,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _withdrawalRequestAPI.createWithdrawalRequest(request);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Withdrawal request submitted successfully!');
        _ref.refresh(getUserWithdrawalRequestsProvider);
        _ref.refresh(getUserWalletProvider);
      },
    );
  }

  Future<void> cancelWithdrawalRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _withdrawalRequestAPI.cancelWithdrawalRequest(requestId);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Withdrawal request cancelled successfully!');
        _ref.refresh(getUserWithdrawalRequestsProvider);
        _ref.refresh(getUserWalletProvider);
      },
    );
  }
}
