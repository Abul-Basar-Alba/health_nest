// lib/src/screens/auth/modern_signup_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../config/auth_colors.dart';
import '../../services/enhanced_auth_service.dart';
import 'email_verification_screen.dart';

class ModernSignupScreen extends StatefulWidget {
  const ModernSignupScreen({super.key});

  @override
  State<ModernSignupScreen> createState() => _ModernSignupScreenState();
}

class _ModernSignupScreenState extends State<ModernSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = EnhancedAuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

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

    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
      });
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.25;

    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;

    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.25;

    // Number or special character check
    if (password.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
      strength += 0.25;
    }

    // Determine strength text and color
    if (strength <= 0.25) {
      strengthText = 'Weak';
      strengthColor = AuthColors.accentCoral;
    } else if (strength <= 0.5) {
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else if (strength <= 0.75) {
      strengthText = 'Good';
      strengthColor = Colors.yellow.shade700;
    } else {
      strengthText = 'Strong';
      strengthColor = AuthColors.accentGreen;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar('Please accept the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Navigate to email verification screen
      Navigator.of(context).pushReplacement(
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

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Check if profile exists
      if (result['isNewUser'] == true) {
        // Navigate to profile setup
        Navigator.of(context).pushReplacementNamed(
          '/profile-setup',
          arguments: {'userId': result['userId']},
        );
      } else {
        // Navigate to main navigation (with bottom bar)
        Navigator.of(context).pushReplacementNamed('/main');
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AuthConstants.largePadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AuthConstants.xlargePadding),
                    _buildSignupForm(),
                    const SizedBox(height: AuthConstants.largePadding),
                    _buildDivider(),
                    const SizedBox(height: AuthConstants.largePadding),
                    _buildGoogleSignup(),
                    const SizedBox(height: AuthConstants.largePadding),
                    _buildLoginLink(),
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
    return FadeInDown(
      duration: AuthConstants.mediumAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
              Icons.person_add,
              size: 50,
              color: AuthColors.accentBlue,
            ),
          ),
          const SizedBox(height: AuthConstants.largePadding),
          const Text(
            'Create Account',
            style: AuthTextStyles.heading1,
          ),
          const SizedBox(height: AuthConstants.smallPadding),
          Text(
            'Join us for a healthier you',
            style: AuthTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return FadeInUp(
      duration: AuthConstants.mediumAnimation,
      child: Container(
        padding: const EdgeInsets.all(AuthConstants.largePadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AuthConstants.largeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              Text(
                'Full Name',
                style: AuthTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AuthConstants.smallPadding),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(
                      color: AuthColors.accentBlue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AuthColors.backgroundLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AuthConstants.largePadding),

              // Email Field
              Text(
                'Email',
                style: AuthTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AuthConstants.smallPadding),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(
                      color: AuthColors.accentBlue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AuthColors.backgroundLight,
                ),
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

              const SizedBox(height: AuthConstants.largePadding),

              // Password Field
              Text(
                'Password',
                style: AuthTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AuthConstants.smallPadding),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(
                      color: AuthColors.accentBlue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AuthColors.backgroundLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),

              // Password Strength Indicator
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: AuthConstants.mediumPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: AuthColors.lightGrey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _passwordStrengthColor,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: AuthConstants.mediumPadding),
                        Text(
                          _passwordStrengthText,
                          style: TextStyle(
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AuthConstants.largePadding),

              // Confirm Password Field
              Text(
                'Confirm Password',
                style: AuthTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AuthConstants.smallPadding),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(color: AuthColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AuthConstants.mediumRadius),
                    borderSide: const BorderSide(
                      color: AuthColors.accentBlue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AuthColors.backgroundLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AuthConstants.largePadding),

              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() => _acceptTerms = value ?? false);
                    },
                    activeColor: AuthColors.accentBlue,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _acceptTerms = !_acceptTerms);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: AuthTextStyles.bodyMedium.copyWith(
                            color: AuthColors.darkNavy,
                          ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: AuthColors.accentBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AuthConstants.largePadding),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
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
                              'Create Account',
                              style: AuthTextStyles.buttonText,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AuthColors.lightGrey)),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AuthConstants.mediumPadding),
            child: Text(
              'OR',
              style: AuthTextStyles.bodyMedium.copyWith(
                color: AuthColors.mediumGrey,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AuthColors.lightGrey)),
        ],
      ),
    );
  }

  Widget _buildGoogleSignup() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleGoogleSignup,
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
          ),
          label: const Text(
            'Sign up with Google',
            style: TextStyle(
              color: AuthColors.darkNavy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AuthColors.lightGrey, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuthConstants.mediumRadius),
            ),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AuthTextStyles.bodyMedium,
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              'Login',
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
