// health_nest/lib/src/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  // Toggle theme and save preference
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  // Set specific theme mode
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    }
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[50],

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: Colors.grey[700]),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF1E1E1E),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[300]),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[400]),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 16,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: Colors.grey[400]),
    );
  }
}
