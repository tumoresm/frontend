import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Static color constants for const constructors
class _WalletColors {
  static final Color subtitleColor = Colours.whiteColor.withOpacity(0.8);
  static final Color iconColor = Colours.whiteColor.withOpacity(0.8);
  static final Color labelColor = Colours.whiteColor.withOpacity(0.7);
}

class WalletBalanceCard extends StatelessWidget {
  final WalletModel? wallet;
  final bool isLoading;

  const WalletBalanceCard({
    super.key,
    this.wallet,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Colours.gradient1,
            Colours.gradient2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colours.whiteColor,
        ),
      );
    }

    if (wallet == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.wallet,
              size: 48,
              color: Colours.whiteColor,
            ),
            SizedBox(height: 8),
            Text(
              'No wallet found',
              style: TextStyle(
                color: Colours.whiteColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Symbols.account_balance_wallet,
                color: Colours.whiteColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Wallet Balance',
                style: TextStyle(
                  color: Colours.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Text(
            'R\${wallet!.currentBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colours.whiteColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available Balance',
            style: TextStyle(
              color: _WalletColors.subtitleColor,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail(
                'Total Earnings',
                wallet!.totalEarnings,
                Symbols.trending_up,
              ),
              _buildBalanceDetail(
                'Pending',
                wallet!.pendingEarnings,
                Symbols.schedule,
              ),
              _buildBalanceDetail(
                'Reserved',
                wallet!.reservedAmount,
                Symbols.lock,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, double amount, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: _WalletColors.iconColor,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          'R\${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colours.whiteColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _WalletColors.labelColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}