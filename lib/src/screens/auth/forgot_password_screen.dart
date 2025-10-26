// lib/src/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/auth_colors.dart';
import '../../services/enhanced_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = EnhancedAuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.resetPassword(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      setState(() => _emailSent = true);
    } else {
      _showErrorSnackBar(result['message']);
    }
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
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(AuthConstants.mediumPadding),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AuthConstants.largePadding),
                    child: _emailSent ? _buildSuccessView() : _buildResetForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return FadeInUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AuthColors.accentBlue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 50,
              color: AuthColors.accentBlue,
            ),
          ),

          const SizedBox(height: AuthConstants.xlargePadding),

          // Title
          const Text(
            'Forgot Password?',
            style: AuthTextStyles.heading1,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AuthConstants.mediumPadding),

          const Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: AuthTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AuthConstants.xlargePadding),

          // Form
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AuthTextStyles.bodyLarge,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  hintStyle: AuthTextStyles.bodyMedium,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AuthColors.accentBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AuthConstants.mediumPadding,
                    vertical: AuthConstants.mediumPadding,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AuthConstants.xlargePadding),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AuthConstants.mediumRadius),
                ),
                elevation: AuthConstants.mediumElevation,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AuthColors.primaryButtonGradient,
                  borderRadius:
                      BorderRadius.circular(AuthConstants.mediumRadius),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24,
                        )
                      : const Text(
                          'Send Reset Link',
                          style: AuthTextStyles.buttonText,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return FadeInUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AuthColors.accentGreen.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 60,
              color: AuthColors.accentGreen,
            ),
          ),

          const SizedBox(height: AuthConstants.xlargePadding),

          const Text(
            'Check Your Email!',
            style: AuthTextStyles.heading1,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AuthConstants.mediumPadding),

          Text(
            'We\'ve sent password reset instructions to\n${_emailController.text.trim()}',
            style: AuthTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AuthConstants.xlargePadding),

          // Back to Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AuthConstants.mediumRadius),
                ),
                elevation: AuthConstants.mediumElevation,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AuthColors.primaryButtonGradient,
                  borderRadius:
                      BorderRadius.circular(AuthConstants.mediumRadius),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Back to Login',
                    style: AuthTextStyles.buttonText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
