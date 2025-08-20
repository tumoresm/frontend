import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/wallet/view/widgets/wallet_balance_card.dart';
import 'package:fieldforce/features/wallet/view/widgets/wallet_quick_actions.dart';
import 'package:fieldforce/features/wallet/view/widgets/transaction_list_widget.dart';
import 'package:fieldforce/features/wallet/view/widgets/withdrawal_request_dialog.dart';
import 'package:fieldforce/features/wallet/view/pages/add_bank_account_page.dart';
import 'package:fieldforce/features/wallet/view/pages/transaction_history_page.dart';
import 'package:fieldforce/features/wallet/view/pages/withdrawal_requests_page.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class WalletMainPage extends ConsumerWidget {
  const WalletMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(getUserWalletProvider);
    final transactionsAsync = ref.watch(getUserTransactionsProvider);
    final bankAccountsAsync = ref.watch(getUserBankAccountsProvider);
    final isLoading = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: Colours.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colours.backgroundColor,
        elevation: 0,
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: Colours.whiteColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh all data
              ref.refresh(getUserWalletProvider);
              ref.refresh(getUserTransactionsProvider);
              ref.refresh(getUserBankAccountsProvider);
              ref.refresh(getUserWithdrawalRequestsProvider);
            },
            icon: const Icon(
              Symbols.refresh,
              color: Colours.whiteColor,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(getUserWalletProvider);
          ref.refresh(getUserTransactionsProvider);
          ref.refresh(getUserBankAccountsProvider);
          ref.refresh(getUserWithdrawalRequestsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Wallet Balance Card
              walletAsync.when(
                data: (wallet) => WalletBalanceCard(
                  wallet: wallet,
                  isLoading: isLoading,
                ),
                loading: () => const WalletBalanceCard(isLoading: true),
                error: (error, stack) => Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colours.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colours.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Symbols.error,
                        color: Colours.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading wallet: $error',
                        style: const TextStyle(
                          color: Colours.errorColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              WalletQuickActions(
                onWithdraw: () => _showWithdrawalDialog(context, ref),
                onAddBankAccount: () => _navigateToAddBankAccount(context),
                onViewTransactions: () => _navigateToTransactionHistory(context),
                onViewWithdrawals: () => _navigateToWithdrawalRequests(context),
              ),

              const SizedBox(height: 16),

              // Recent Transactions
              transactionsAsync.when(
                data: (transactions) => TransactionListWidget(
                  transactions: transactions,
                  isLoading: isLoading,
                  onViewAll: () => _navigateToTransactionHistory(context),
                ),
                loading: () => const TransactionListWidget(
                  transactions: [],
                  isLoading: true,
                ),
                error: (error, stack) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colours.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Symbols.error,
                        color: Colours.errorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading transactions: $error',
                        style: const TextStyle(
                          color: Colours.errorColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.read(getUserWalletProvider);
    final bankAccountsAsync = ref.read(getUserBankAccountsProvider);

    walletAsync.whenData((wallet) {
      if (wallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet not found. Please try again.'),
            backgroundColor: Colours.errorColor,
          ),
        );
        return;
      }

      bankAccountsAsync.whenData((bankAccounts) {
        showDialog(
          context: context,
          builder: (context) => WithdrawalRequestDialog(
            wallet: wallet,
            bankAccounts: bankAccounts,
          ),
        );
      });
    });
  }

  void _navigateToAddBankAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddBankAccountPage(),
      ),
    );
  }

  void _navigateToTransactionHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransactionHistoryPage(),
      ),
    );
  }

  void _navigateToWithdrawalRequests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WithdrawalRequestsPage(),
      ),
    );
  }
}