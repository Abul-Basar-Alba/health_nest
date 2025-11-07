// lib/src/screens/auth/splash_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../config/auth_colors.dart';
import '../../providers/pregnancy_provider.dart';
import '../../services/enhanced_auth_service.dart';

class SplashAuthScreen extends StatefulWidget {
  const SplashAuthScreen({super.key});

  @override
  State<SplashAuthScreen> createState() => _SplashAuthScreenState();
}

class _SplashAuthScreenState extends State<SplashAuthScreen> {
  final _authService = EnhancedAuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Wait for 2 seconds (splash effect)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Load pregnancy data if user is logged in
      final user = _authService.currentUser;
      if (user != null && mounted) {
        final pregnancyProvider =
            Provider.of<PregnancyProvider>(context, listen: false);
        try {
          await pregnancyProvider.loadActivePregnancy(user.uid);
        } catch (e) {
          // Silent fail - pregnancy data is optional
          debugPrint('Failed to load pregnancy data: $e');
        }
      }

      if (!mounted) return;

      // Navigate to main navigation (with bottom bar)
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      // Navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuthColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.accentBlue.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: AuthColors.accentCoral,
                ),
              ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'HealthNest',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AuthColors.darkNavy,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Your Health Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 60),

              // Loading Indicator
              const SpinKitThreeBounce(
                color: AuthColors.accentBlue,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
