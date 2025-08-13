import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class WalletQuickActions extends StatelessWidget {
  final VoidCallback? onWithdraw;
  final VoidCallback? onAddBankAccount;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onViewWithdrawals;

  const WalletQuickActions({
    super.key,
    this.onWithdraw,
    this.onAddBankAccount,
    this.onViewTransactions,
    this.onViewWithdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colours.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colours.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Symbols.account_balance,
                label: 'Withdraw',
                color: Colours.gradient2,
                onTap: onWithdraw,
              ),
              _buildActionButton(
                icon: Symbols.add_card,
                label: 'Add Bank',
                color: Colours.gradient1,
                onTap: onAddBankAccount,
              ),
              _buildActionButton(
                icon: Symbols.receipt_long,
                label: 'History',
                color: Colours.greenColor,
                onTap: onViewTransactions,
              ),
              _buildActionButton(
                icon: Symbols.pending_actions,
                label: 'Requests',
                color: Colors.orange,
                onTap: onViewWithdrawals,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colours.whiteColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}