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
    _selectedBankAccount = widget.bankAccounts.firstWhere(
      (account) => account.isDefault,
      orElse: () => widget.bankAccounts.isNotEmpty ? widget.bankAccounts.first : null,
    );
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\\d+\\.?\\d{0,2}')),
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
                DropdownButtonFormField<BankAccountModel>(\n                  value: _selectedBankAccount,\n                  style: const TextStyle(color: Colours.whiteColor),\n                  dropdownColor: Colours.cardColor,\n                  decoration: InputDecoration(\n                    filled: true,\n                    fillColor: Colours.backgroundColor,\n                    border: OutlineInputBorder(\n                      borderRadius: BorderRadius.circular(8),\n                      borderSide: const BorderSide(color: Colours.borderColor),\n                    ),\n                    enabledBorder: OutlineInputBorder(\n                      borderRadius: BorderRadius.circular(8),\n                      borderSide: const BorderSide(color: Colours.borderColor),\n                    ),\n                  ),\n                  items: widget.bankAccounts.map((account) {\n                    return DropdownMenuItem<BankAccountModel>(\n                      value: account,\n                      child: Text(\n                        account.displayName,\n                        style: const TextStyle(color: Colours.whiteColor),\n                      ),\n                    );\n                  }).toList(),\n                  onChanged: (value) {\n                    setState(() {\n                      _selectedBankAccount = value;\n                    });\n                  },\n                  validator: (value) {\n                    if (value == null) {\n                      return 'Please select a bank account';\n                    }\n                    return null;\n                  },\n                ),\n              \n              const SizedBox(height: 24),\n              \n              // Processing Fee Info\n              Container(\n                width: double.infinity,\n                padding: const EdgeInsets.all(12),\n                decoration: BoxDecoration(\n                  color: Colors.orange.withOpacity(0.1),\n                  borderRadius: BorderRadius.circular(8),\n                  border: Border.all(\n                    color: Colors.orange.withOpacity(0.3),\n                  ),\n                ),\n                child: const Row(\n                  children: [\n                    Icon(\n                      Symbols.info,\n                      color: Colors.orange,\n                      size: 16,\n                    ),\n                    SizedBox(width: 8),\n                    Expanded(\n                      child: Text(\n                        'Processing fees may apply. You will be notified of any fees before the withdrawal is processed.',\n                        style: TextStyle(\n                          color: Colors.orange,\n                          fontSize: 12,\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n              ),\n              \n              const SizedBox(height: 24),\n              \n              // Action Buttons\n              Row(\n                children: [\n                  Expanded(\n                    child: OutlinedButton(\n                      onPressed: isLoading ? null : () => Navigator.pop(context),\n                      style: OutlinedButton.styleFrom(\n                        side: const BorderSide(color: Colours.borderColor),\n                        shape: RoundedRectangleBorder(\n                          borderRadius: BorderRadius.circular(8),\n                        ),\n                      ),\n                      child: const Text(\n                        'Cancel',\n                        style: TextStyle(color: Colours.whiteColor),\n                      ),\n                    ),\n                  ),\n                  const SizedBox(width: 12),\n                  Expanded(\n                    child: FlatButton(\n                      buttonText: isLoading ? 'Processing...' : 'Request Withdrawal',\n                      onTap: isLoading ? () {} : _submitWithdrawalRequest,\n                    ),\n                  ),\n                ],\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  void _submitWithdrawalRequest() {\n    if (!_formKey.currentState!.validate()) return;\n    if (_selectedBankAccount == null) return;\n    if (widget.bankAccounts.isEmpty) return;\n\n    final amount = double.parse(_amountController.text);\n    \n    final withdrawalRequest = WithdrawalRequestModel(\n      id: '', // Will be assigned by database\n      userId: widget.wallet.userId,\n      amount: amount,\n      bankAccountId: _selectedBankAccount!.id,\n      status: WithdrawalStatus.pending,\n      requestedAt: DateTime.now(),\n    );\n\n    ref.read(walletControllerProvider.notifier).createWithdrawalRequest(\n      request: withdrawalRequest,\n      context: context,\n    );\n\n    Navigator.pop(context);\n  }\n}"
  }
]