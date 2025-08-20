import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fieldforce/theme/theme.dart';

class EmailTroubleshootingDialog extends StatelessWidget {
  final String? email;

  const EmailTroubleshootingDialog({
    super.key,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Symbols.help, color: Colours.gradient2),
          SizedBox(width: 8),
          Text('Email Not Received?'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'If you haven\'t received the verification email, please try the following:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTroubleshootingItem(
              icon: Symbols.schedule,
              title: 'Wait a few minutes',
              description:
                  'Email delivery can take 1-5 minutes. Please be patient.',
            ),
            _buildTroubleshootingItem(
              icon: Symbols.report,
              title: 'Check spam/junk folder',
              description:
                  'Verification emails sometimes end up in spam folders.',
            ),
            _buildTroubleshootingItem(
              icon: Symbols.email,
              title: 'Verify email address',
              description: email != null
                  ? 'Confirm this is correct: $email'
                  : 'Make sure you entered the correct email address.',
            ),
            _buildTroubleshootingItem(
              icon: Symbols.refresh,
              title: 'Request new code',
              description:
                  'Use the "Resend Code" button to get a fresh verification code.',
            ),
            _buildTroubleshootingItem(
              icon: Symbols.wifi_off,
              title: 'Check connection',
              description: 'Ensure you have a stable internet connection.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Symbols.info, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If none of these steps work, there might be a server issue. Please try again later or contact support.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colours.gradient2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
