// lib/src/screens/women_health/women_health_colors.dart

import 'package:flutter/material.dart';

class WomenHealthColors {
  // Soft, relaxing, feminine color palette
  static const Color primaryPink = Color(0xFFFF6FAF); // Soft pink
  static const Color lightPink = Color(0xFFFFC1D9); // Very light pink
  static const Color palePink = Color(0xFFFFF0F5); // Almost white pink

  static const Color primaryPurple = Color(0xFF9D7BDB); // Soft purple
  static const Color lightPurple = Color(0xFFE6DDFF); // Very light purple

  static const Color accentPeach = Color(0xFFFFB4A2); // Warm peach
  static const Color lightPeach = Color(0xFFFFE5DE); // Light peach

  static const Color mintGreen = Color(0xFF9AD1D4); // Calming mint
  static const Color lightMint = Color(0xFFD4F1F4); // Very light mint

  static const Color periodRed = Color(0xFFFF6B9D);
  static const Color ovulationBlue = Color(0xFF7DCFFF);
  static const Color pillYellow = Color(0xFFFFD972);
  static const Color symptomOrange = Color(0xFFFFB347);

  // Gradient backgrounds
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF0F5), Color(0xFFFFE4EC)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3E7FF), Color(0xFFE6D9FF)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F8F5), Color(0xFFD0F0F0)],
  );

  static const LinearGradient peachGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFEDE9), Color(0xFFFFE0D8)],
  );

  // Text colors
  static const Color darkText = Color(0xFF2D3748);
  static const Color mediumText = Color(0xFF4A5568);
  static const Color lightText = Color(0xFF718096);
  static const Color veryLightText = Color(0xFFA0AEC0);

  // Background
  static const Color background = Color(0xFFFFFAFD);
  static const Color cardBackground = Colors.white;

  // Shadows
  static const Color shadowColor = Color(0x0D000000);
}
