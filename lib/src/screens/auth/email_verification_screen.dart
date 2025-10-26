// lib/src/screens/auth/email_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import '../../config/auth_colors.dart';
import '../../services/enhanced_auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = EnhancedAuthService();
  bool _isChecking = false;
  bool _isResending = false;
  Timer? _timer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoCheck() {
    // Check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkVerification();
    });
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    final isVerified = await _authService.isEmailVerified();

    if (!mounted) return;

    if (isVerified) {
      _timer?.cancel();

      // Update verification status
      await _authService.updateEmailVerificationStatus(widget.userId);

      // Navigate to profile setup
      Navigator.of(context).pushReplacementNamed(
        '/profile-setup',
        arguments: {'userId': widget.userId},
      );
    }

    setState(() => _isChecking = false);
  }

  Future<void> _resendEmail() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    final result = await _authService.resendVerificationEmail();

    setState(() => _isResending = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessSnackBar('Verification email sent!');

      // Start countdown
      setState(() => _resendCountdown = 60);
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCountdown > 0) {
          setState(() => _resendCountdown--);
        } else {
          timer.cancel();
        }
      });
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AuthColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AuthColors.accentCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuthColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AuthConstants.largePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Email Icon
                  FadeInDown(
                    duration: AuthConstants.mediumAnimation,
                    child: Pulse(
                      duration: const Duration(seconds: 2),
                      infinite: true,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AuthColors.accentBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_unread,
                          size: 60,
                          color: AuthColors.accentBlue,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthConstants.xlargePadding),

                  // Title
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: const Text(
                      'Verify Your Email',
                      style: AuthTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AuthConstants.mediumPadding),

                  // Description
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'We\'ve sent a verification email to:',
                      style: AuthTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AuthConstants.smallPadding),

                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      widget.email,
                      style: AuthTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AuthColors.accentBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AuthConstants.xlargePadding),

                  // Instructions Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(AuthConstants.largePadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AuthConstants.mediumRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInstructionItem(
                            '1',
                            'Check your email inbox',
                            Icons.inbox,
                          ),
                          const SizedBox(height: AuthConstants.mediumPadding),
                          _buildInstructionItem(
                            '2',
                            'Click the verification link',
                            Icons.link,
                          ),
                          const SizedBox(height: AuthConstants.mediumPadding),
                          _buildInstructionItem(
                            '3',
                            'Come back here to continue',
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthConstants.xlargePadding),

                  // Auto-checking indicator
                  if (_isChecking)
                    FadeInUp(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SpinKitThreeBounce(
                            color: AuthColors.accentBlue,
                            size: 20,
                          ),
                          const SizedBox(width: AuthConstants.mediumPadding),
                          Text(
                            'Checking verification...',
                            style: AuthTextStyles.bodyMedium.copyWith(
                              color: AuthColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AuthConstants.largePadding),

                  // Resend Email Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: TextButton.icon(
                      onPressed: _resendCountdown > 0 || _isResending
                          ? null
                          : _resendEmail,
                      icon: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AuthColors.accentBlue,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _resendCountdown > 0
                            ? 'Resend in $_resendCountdown seconds'
                            : 'Didn\'t receive email? Resend',
                        style: TextStyle(
                          color: _resendCountdown > 0 || _isResending
                              ? AuthColors.lightGrey
                              : AuthColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthConstants.mediumPadding),

                  // Check Manually Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : _checkVerification,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AuthConstants.mediumRadius),
                          ),
                          elevation: AuthConstants.mediumElevation,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AuthColors.primaryButtonGradient,
                            borderRadius: BorderRadius.circular(
                                AuthConstants.mediumRadius),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isChecking
                                ? const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : const Text(
                                    'I\'ve Verified',
                                    style: AuthTextStyles.buttonText,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthConstants.mediumPadding),

                  // Back to Login
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AuthColors.darkNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AuthColors.primaryButtonGradient,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: AuthConstants.mediumPadding),
        Expanded(
          child: Text(
            text,
            style: AuthTextStyles.bodyLarge,
          ),
        ),
        Icon(
          icon,
          color: AuthColors.accentGreen,
          size: 24,
        ),
      ],
    );
  }
}
