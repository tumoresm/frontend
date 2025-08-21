import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/auth/view/pages/signin_page.dart';
import 'package:fieldforce/features/auth/view/widgets/email_troubleshooting_dialog.dart';
import 'package:fieldforce/theme/theme.dart';
import 'package:fieldforce/utils/custom_field.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String? email;

  const EmailVerificationPage({
    super.key,
    this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
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
      final success =
          await ref.read(authControllerProvider.notifier).verifyEmail(
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

    final success =
        await ref.read(authControllerProvider.notifier).resendVerificationCode(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Your Email',
          style: TextStyle(fontSize: isSmallScreen ? 18.sp : 20.sp),
        ),
        leading: IconButton(
          icon: Icon(
            Symbols.arrow_back,
            size: isSmallScreen ? 20.sp : 24.sp,
          ),
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
            icon: Icon(
              Symbols.help,
              size: isSmallScreen ? 20.sp : 24.sp,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    EmailTroubleshootingDialog(email: widget.email),
              );
            },
            tooltip: 'Email not received?',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 500.w : double.infinity,
              minHeight: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.w : (isSmallScreen ? 16.w : 24.w),
                vertical: isSmallScreen ? 16.h : 24.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Icon(
                      Symbols.mark_email_unread,
                      size: isSmallScreen ? 60.sp : (isTablet ? 100.sp : 80.sp),
                      color: Colours.gradient2,
                    ),
                    SizedBox(height: isSmallScreen ? 16.h : 24.h),

                    Text(
                      'Check Your Email',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24.sp : (isTablet ? 32.sp : 28.sp),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 8.h : 12.h),

                    Text(
                      'We\'ve sent an 8-digit verification code to ${widget.email ?? 'your email address'}. Please enter it below to verify your account.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14.sp : (isTablet ? 18.sp : 16.sp),
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 24.h : 32.h),

                    // Email Field (editable in case user needs to correct it)
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Symbols.email,
                        size: isSmallScreen ? 18.sp : 20.sp,
                      ),
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
                    SizedBox(height: isSmallScreen ? 16.h : 20.h),

                    // Verification Code Field
                    CustomTextField(
                      controller: _codeController,
                      hintText: 'Enter 8-digit code',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Symbols.pin,
                        size: isSmallScreen ? 18.sp : 20.sp,
                      ),
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
                    SizedBox(height: isSmallScreen ? 20.h : 24.h),

                    // Verify Button
                    FlatButton(
                      onTap: authState ? null : _verifyEmail,
                      buttonText: authState ? 'Verifying...' : 'Verify Email',
                    ),
                    SizedBox(height: isSmallScreen ? 12.h : 16.h),

                    // Resend Code Section
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 14.sp : 16.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: _isResending ? null : _resendCode,
                          child: Text(
                            _isResending ? 'Sending...' : 'Resend Code',
                            style: TextStyle(
                              color: Colours.gradient2,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14.sp : 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 20.h : 24.h),

                    // Information Card
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12.w : 16.w),
                      decoration: BoxDecoration(
                        color: Colours.gradient2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
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
                                size: isSmallScreen ? 18.sp : 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Important Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colours.gradient2,
                                  fontSize: isSmallScreen ? 14.sp : 16.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '• Verification codes expire after 15 minutes\n'
                            '• Each code can only be used once\n'
                            '• Check your spam/junk folder if you don\'t see the email\n'
                            '• Make sure the email address is correct\n'
                            '• You can request a new code if needed\n'
                            '• It may take a few minutes for the email to arrive',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12.sp : 14.sp,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20.h : 24.h),

                    // Back to Sign In
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Back to Sign In',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isSmallScreen ? 14.sp : 16.sp,
                        ),
                      ),
                    ),
                    // Add bottom padding for small screens
                    SizedBox(height: isSmallScreen ? 20.h : 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
