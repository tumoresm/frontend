import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class WithdrawalRequestDialog extends ConsumerStatefulWidget {
  final WalletModel wallet;
  final List<BankAccountModel> bankAccounts;

  const WithdrawalRequestDialog({
    super.key,
    required this.wallet,
    required this.bankAccounts,
  });

  @override
  ConsumerState<WithdrawalRequestDialog> createState() => _WithdrawalRequestDialogState();
}

class _WithdrawalRequestDialogState extends ConsumerState<WithdrawalRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  BankAccountModel? _selectedBankAccount;
  
  @override
  void initState() {
    super.initState();
    // Set default bank account if available
    if (widget.bankAccounts.isNotEmpty) {
      _selectedBankAccount = widget.bankAccounts.firstWhere(
        (account) => account.isDefault,
        orElse: () => widget.bankAccounts.first,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(walletControllerProvider);
    
    return Dialog(
      backgroundColor: Colours.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Symbols.account_balance,
                    color: Colours.gradient2,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Withdraw Funds',
                    style: TextStyle(
                      color: Colours.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Symbols.close,
                      color: Colours.greyColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Available Balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colours.gradient1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colours.gradient1.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colours.greyColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R${widget.wallet.availableBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colours.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Amount Input
              const Text(
                'Withdrawal Amount',
                style: TextStyle(
                  color: Colours.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(color: Colours.whiteColor),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colours.greyColor),
                  prefixText: 'R ',
                  prefixStyle: const TextStyle(color: Colours.whiteColor),
                  filled: true,
                  fillColor: Colours.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colours.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colours.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colours.gradient2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > widget.wallet.availableBalance) {
                    return 'Amount exceeds available balance';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Bank Account Selection
              const Text(
                'Bank Account',
                style: TextStyle(
                  color: Colours.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              if (widget.bankAccounts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colours.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colours.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'No bank accounts found. Please add a bank account first.',
                    style: TextStyle(
                      color: Colours.errorColor,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                DropdownButtonFormField<BankAccountModel>(
                  value: _selectedBankAccount,
                  style: const TextStyle(color: Colours.whiteColor),
                  dropdownColor: Colours.cardColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colours.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.borderColor),
                    ),
                  ),
                  items: widget.bankAccounts.map((account) {
                    return DropdownMenuItem<BankAccountModel>(
                      value: account,
                      child: Text(
                        account.displayName,
                        style: const TextStyle(color: Colours.whiteColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankAccount = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bank account';
                    }
                    return null;
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Processing Fee Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Symbols.info,
                      color: Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Processing fees may apply. You will be notified of any fees before the withdrawal is processed.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colours.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colours.whiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FlatButton(
                      buttonText: isLoading ? 'Processing...' : 'Request Withdrawal',
                      onTap: isLoading ? () {} : _submitWithdrawalRequest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitWithdrawalRequest() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankAccount == null) return;
    if (widget.bankAccounts.isEmpty) return;

    final amount = double.parse(_amountController.text);
    
    final withdrawalRequest = WithdrawalRequestModel(
      id: '', // Will be assigned by database
      userId: widget.wallet.userId,
      amount: amount,
      bankAccountId: _selectedBankAccount!.id,
      status: WithdrawalStatus.pending,
      requestedAt: DateTime.now(),
    );

    ref.read(walletControllerProvider.notifier).createWithdrawalRequest(
      request: withdrawalRequest,
      context: context,
    );

    Navigator.pop(context);
  }
}