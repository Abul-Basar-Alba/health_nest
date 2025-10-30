// lib/src/screens/splash_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.repeat(reverse: true);

    // Navigate to Dashboard or Login after 3 seconds
    Timer(const Duration(seconds: 3), () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isPremium = userProvider.user?.isPremium ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [Colors.deepPurple.shade400, Colors.pink.shade300]
                : [Colors.blue.shade200, Colors.green.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Icon(
                    Icons.spa_rounded,
                    size: 80,
                    color: isPremium
                        ? Colors.purple.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to HealthNest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isPremium ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPremium
                    ? 'Enjoy Premium Features 🌟'
                    : 'Your Health Companion 🏃‍♂️',
                style: TextStyle(
                  fontSize: 16,
                  color: isPremium ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPremium ? Colors.white : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
