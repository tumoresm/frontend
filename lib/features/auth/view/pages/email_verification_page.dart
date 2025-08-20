import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/view/widgets/email_troubleshooting_dialog.dart';
import 'package:fieldforce/theme/theme.dart';
import 'package:fieldforce/utils/custom_field.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String? email;
  
  const EmailVerificationPage({
    super.key,
    this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _verifyEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authControllerProvider.notifier).verifyEmail(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        context: context,
      );

      // Navigation is handled in the auth controller
      // If verification is successful, user will be redirected to sign in
    }
  }

  void _resendCode() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    final success = await ref.read(authControllerProvider.notifier).resendVerificationCode(
      email: _emailController.text.trim(),
      context: context,
    );

    setState(() {
      _isResending = false;
    });

    if (success) {
      // Clear the current code field so user enters the new code
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.help),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EmailTroubleshootingDialog(email: widget.email),
              );
            },
            tooltip: 'Email not received?',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              const Icon(
                Symbols.mark_email_unread,
                size: 80,
                color: Colours.gradient2,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'We\'ve sent an 8-digit verification code to ${widget.email ?? 'your email address'}. Please enter it below to verify your account.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field (editable in case user needs to correct it)
              CustomTextField(
                controller: _emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Symbols.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Verification Code Field
              CustomTextField(
                controller: _codeController,
                hintText: 'Enter 8-digit code',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Symbols.pin),
                maxLength: 8,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Verification code is required';
                  }
                  if (value.length != 8) {
                    return 'Code must be exactly 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Verify Button
              FlatButton(
                onTap: authState ? null : _verifyEmail,
                buttonText: authState ? 'Verifying...' : 'Verify Email',
              ),
              const SizedBox(height: 16),

              // Resend Code Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _resendCode,
                    child: Text(
                      _isResending ? 'Sending...' : 'Resend Code',
                      style: const TextStyle(
                        color: Colours.gradient2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colours.gradient2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colours.gradient2.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.info,
                          color: Colours.gradient2,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Important Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colours.gradient2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Verification codes expire after 15 minutes\n'
                      '• Each code can only be used once\n'
                      '• Check your spam/junk folder if you don\'t see the email\n'
                      '• Make sure the email address is correct\n'
                      '• You can request a new code if needed\n'
                      '• It may take a few minutes for the email to arrive',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Back to Sign In
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}