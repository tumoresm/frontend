import 'package:fieldforce/features/companies/view/add_company.dart';
import 'package:fieldforce/features/order/view/create_order_page.dart';
import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/wallet/view/widgets/withdrawal_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewDialog extends ConsumerWidget {
  const AddNewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, CreateOrderPage.route());
              },
              child: const Text('New Order'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, AddCompanyPage.route());
              },
              child: const Text('Add Company'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showWithdrawalDialog(context, ref);
              },
              child: const Text('Withdraw Funds'),
            ),
          ],
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
            backgroundColor: Colors.red,
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
}
