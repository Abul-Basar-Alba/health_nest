// lib/src/screens/auth/modern_login_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/auth_colors.dart';
import '../../services/enhanced_auth_service.dart';
import 'modern_signup_screen.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = EnhancedAuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AuthConstants.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Check if profile is complete
      final profileComplete = result['profileComplete'] ?? false;

      if (profileComplete) {
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        // Navigate to profile setup
        Navigator.of(context).pushReplacementNamed(
          '/profile-setup',
          arguments: {'userId': result['userId']},
        );
      }
    } else if (result['needsVerification'] == true) {
      // Show verification screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            userId: result['userId'],
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      final profileComplete = result['profileComplete'] ?? false;

      if (profileComplete) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        Navigator.of(context).pushReplacementNamed(
          '/profile-setup',
          arguments: {'userId': result['userId']},
        );
      }
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AuthConstants.largePadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo & Welcome
                    _buildHeader(),

                    const SizedBox(height: AuthConstants.xlargePadding),

                    // Login Form
                    _buildLoginForm(),

                    const SizedBox(height: AuthConstants.largePadding),

                    // Divider
                    _buildDivider(),

                    const SizedBox(height: AuthConstants.largePadding),

                    // Google Sign-In
                    _buildGoogleSignIn(),

                    const SizedBox(height: AuthConstants.largePadding),

                    // Sign Up Link
                    _buildSignUpLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo
        FadeInDown(
          duration: AuthConstants.mediumAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AuthColors.primaryButtonGradient,
              boxShadow: [
                BoxShadow(
                  color: AuthColors.accentBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: AuthConstants.largePadding),

        // Welcome Text
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'Welcome Back! 👋',
            style: AuthTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AuthConstants.smallPadding),

        FadeInDown(
          delay: const Duration(milliseconds: 300),
          child: const Text(
            'Stay fit with HealthNest',
            style: AuthTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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
            ),

            const SizedBox(height: AuthConstants.mediumPadding),

            // Password Field
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AuthConstants.smallPadding),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AuthColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AuthConstants.mediumPadding),

            // Login Button
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
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
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !_isPasswordVisible,
        style: AuthTextStyles.bodyLarge,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: AuthTextStyles.bodyMedium,
          prefixIcon: Icon(icon, color: AuthColors.accentBlue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AuthColors.lightGrey,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
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
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailLogin,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
          ),
          elevation: AuthConstants.mediumElevation,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AuthColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 24,
                  )
                : const Text(
                    'Login',
                    style: AuthTextStyles.buttonText,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AuthColors.fieldBorder,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AuthConstants.mediumPadding,
            ),
            child: Text(
              'OR',
              style: AuthTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AuthColors.fieldBorder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignIn() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
          ),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AuthColors.darkNavy,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AuthColors.fieldBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
            ),
            elevation: AuthConstants.lowElevation,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return FadeInUp(
      delay: const Duration(milliseconds: 700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: AuthTextStyles.bodyMedium,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ModernSignupScreen(),
                ),
              );
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: AuthColors.accentBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
