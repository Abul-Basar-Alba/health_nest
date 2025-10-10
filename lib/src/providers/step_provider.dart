// lib/src/providers/step_provider.dart
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/pedometer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepProvider with ChangeNotifier {
  int _steps = 0;
  double _caloriesBurned = 0.0;
  double _distanceKm = 0.0;
  String _statusMessage = "Initializing step counter...";
  bool _isAvailable = false;
  int _baseSteps = 0; // For daily reset functionality

  final PedometerService _pedometerService = PedometerService();

  int get steps => _steps;
  double get caloriesBurned => _caloriesBurned;
  double get distanceKm => _distanceKm;
  String get statusMessage => _statusMessage;
  bool get isAvailable => _isAvailable;

  StepProvider() {
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    try {
      // Check if we're on mobile platform
      if (kIsWeb) {
        _statusMessage = "Step counting not available on web";
        notifyListeners();
        return;
      }

      // Request permissions
      _statusMessage = "Requesting permissions...";
      notifyListeners();

      await _requestPermissions();

      // Load saved data
      await _loadSavedSteps();

      // Initialize pedometer service
      _statusMessage = "Connecting to step counter...";
      notifyListeners();

      _pedometerService.stepCountStream.listen(
        (int newSteps) {
          _onStepCount(newSteps);
        },
        onError: (error) {
          _statusMessage = "Step counter error: $error";
          notifyListeners();
        },
      );

      // Check if service is working
      await Future.delayed(const Duration(seconds: 2));
      if (_steps == 0 && !_isAvailable) {
        _statusMessage = "Step counter not available on this device";
        // Set some demo steps for testing
        _setDemoSteps();
      }
    } catch (e) {
      _statusMessage = "Failed to initialize step counter: $e";
      _setDemoSteps(); // Fallback to demo
      notifyListeners();
    }
  }

  Future<void> _requestPermissions() async {
    // Request activity recognition permission
    final activityStatus = await Permission.activityRecognition.request();

    if (activityStatus.isGranted) {
      _statusMessage = "Permissions granted";
    } else if (activityStatus.isPermanentlyDenied) {
      _statusMessage = "Permission denied. Please enable in settings.";
    } else {
      _statusMessage = "Permission required for step counting";
    }
    notifyListeners();
  }

  Future<void> _loadSavedSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final savedDate = prefs.getString('step_date') ?? '';

      if (savedDate == today) {
        _baseSteps = prefs.getInt('base_steps') ?? 0;
        _steps = prefs.getInt('daily_steps') ?? 0;
      } else {
        // New day, reset steps
        _baseSteps = 0;
        _steps = 0;
        await prefs.setString('step_date', today);
        await prefs.setInt('base_steps', 0);
        await prefs.setInt('daily_steps', 0);
      }
    } catch (e) {
      print('Error loading saved steps: $e');
    }
  }

  void _onStepCount(int totalSteps) {
    try {
      _isAvailable = true;

      if (_baseSteps == 0) {
        _baseSteps = totalSteps;
      }

      _steps = totalSteps - _baseSteps;
      if (_steps < 0) _steps = 0; // Prevent negative steps

      updateSteps(_steps);
      _saveSteps();

      _statusMessage = "Step counter active";
      notifyListeners();
    } catch (e) {
      print('Error processing step count: $e');
    }
  }

  Future<void> _saveSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_steps', _steps);
      await prefs.setInt('base_steps', _baseSteps);
    } catch (e) {
      print('Error saving steps: $e');
    }
  }

  void _setDemoSteps() {
    // Set some demo steps for testing/web
    _steps = 1234;
    _statusMessage = "Demo mode - Step counter not available";
    updateSteps(_steps);
  }

  void updateSteps(int steps) {
    _steps = steps;
    _caloriesBurned = steps * 0.04; // Assume ~0.04 kcal per step
    _distanceKm = steps * 0.000762; // Assume average stride length
    notifyListeners();
  }

  // Manual step addition for testing
  void addTestSteps(int additionalSteps) {
    _steps += additionalSteps;
    updateSteps(_steps);
    _saveSteps();
  }

  // Reset daily steps
  Future<void> resetDailySteps() async {
    _steps = 0;
    _baseSteps = 0;
    await _saveSteps();
    notifyListeners();
  }
}
