import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4CAF50); // A fresh green
  static const Color secondary = Color(0xFF8BC34A); // A lighter green
  static const Color accent =
      Color(0xFFFF9800); // A bright orange for highlights

  // UI & Text Colors
  static const Color background = Color(0xFFF9F9F9); // Light grey background
  static const Color card = Color(0xFFFFFFFF); // White for cards
  static const Color textPrimary =
      Color(0xFF212121); // Dark text for readability
  static const Color textSecondary = Color(0xFF757575); // Lighter text
  static const Color error = Color(0xFFF44336); // Red for error messages

  // Specific Feature Colors
  static const Color steps = Color(0xFF2196F3); // Blue for step counters
  static const Color calories = Color(0xFFE57373); // Reddish for calorie counts
  static const Color community = Color(0xFF9C27B0);

  static Color? get text => null; // Purple for community sections
}
