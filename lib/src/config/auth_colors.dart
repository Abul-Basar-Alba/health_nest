// lib/src/config/auth_colors.dart

import 'package:flutter/material.dart';

class AuthColors {
  // Background Gradients (Mint/Teal theme like Samsung Health)
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3FDFD), // Mint
      Color(0xFFA6E3E9), // Teal
      Color(0xFF71C9CE), // Light blue
    ],
  );

  // Alternative dark gradient for variation
  static const darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2980), // Dark blue
      Color(0xFF26D0CE), // Cyan
    ],
  );

  // Primary Button Gradient (Blue theme)
  static const primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF38b6ff), // Light blue
      Color(0xFF0072ff), // Deep blue
    ],
  );

  // Google Button (White with subtle gradient)
  static const googleButtonGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // White
      Color(0xFFF5F5F5), // Light grey
    ],
  );

  // Success/Error Gradients
  static const successGradient = LinearGradient(
    colors: [
      Color(0xFF56ab2f), // Light green
      Color(0xFF4CAF50), // Green
    ],
  );

  static const errorGradient = LinearGradient(
    colors: [
      Color(0xFFff6b6b), // Light red
      Color(0xFFee5a6f), // Deep red
    ],
  );

  // Solid Colors
  static const darkNavy = Color(0xFF1B262C);
  static const lightGrey = Color(0xFF7C8A95);
  static const mediumGrey = Color(0xFF6B7280);
  static const backgroundLight = Color(0xFFF7F7F7);
  static const accentGreen = Color(0xFF4CAF50);
  static const accentCoral = Color(0xFFFF6B6B);
  static const accentBlue = Color(0xFF0072ff);

  // Field Colors
  static const fieldBackground = Color(0xFFF7F7F7);
  static const fieldBorder = Color(0xFFE0E0E0);
  static const fieldFocusBorder = Color(0xFF0072ff);
  static const fieldErrorBorder = Color(0xFFFF6B6B);

  // Text Colors
  static const primaryText = Color(0xFF1B262C);
  static const secondaryText = Color(0xFF7C8A95);
  static const hintText = Color(0xFFB0B0B0);

  // BMI Category Colors
  static const bmiUnderweight = Color(0xFF3498db); // Blue
  static const bmiNormal = Color(0xFF4CAF50); // Green
  static const bmiOverweight = Color(0xFFFF9800); // Orange
  static const bmiObese = Color(0xFFe74c3c); // Red
}

class AuthTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AuthColors.primaryText,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AuthColors.primaryText,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AuthColors.primaryText,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    color: AuthColors.primaryText,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AuthColors.secondaryText,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AuthColors.hintText,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}

class AuthConstants {
  // Animation Durations
  static const fastAnimation = Duration(milliseconds: 300);
  static const mediumAnimation = Duration(milliseconds: 500);
  static const slowAnimation = Duration(milliseconds: 800);

  // Spacing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double xlargePadding = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 20.0;
  static const double xlRadius = 30.0;

  // Elevation
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Activity Levels
  static const List<String> activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  // Activity Level Multipliers for calorie calculation
  static const Map<String, double> activityLevelMultipliers = {
    'Sedentary': 1.2,
    'Light': 1.375,
    'Moderate': 1.55,
    'Active': 1.725,
    'Very Active': 1.9,
  };

  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
}
