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
  int _dailyGoal = 10000; // Default goal

  final PedometerService _pedometerService = PedometerService();

  int get steps => _steps;
  double get caloriesBurned => _caloriesBurned;
  double get distanceKm => _distanceKm;
  String get statusMessage => _statusMessage;
  bool get isAvailable => _isAvailable;
  int get dailyGoal => _dailyGoal;

  StepProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeWithReset(); // Load goal and check daily reset
    await _initPedometer(); // Then initialize pedometer
  }

  Future<void> _initPedometer() async {
    try {
      // Initialize for all platforms
      if (kIsWeb) {
        _statusMessage = "Step counter ready";
        _steps = 0; // Start with 0 steps
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
      }
    } catch (e) {
      _statusMessage = "Failed to initialize step counter: $e";
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

  // Public method to request permissions
  Future<void> requestPermissions() async {
    await _requestPermissions();
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

  void updateSteps(int steps) {
    _steps = steps;
    _caloriesBurned = steps * 0.04; // Assume ~0.04 kcal per step
    _distanceKm = steps * 0.000762; // Assume average stride length
    notifyListeners();
  }

  // Reset daily steps
  Future<void> resetDailySteps() async {
    _steps = 0;
    _baseSteps = 0;
    await _saveSteps();
    _statusMessage = "Steps reset successfully";
    notifyListeners();
  }

  // Set custom daily goal
  Future<void> setDailyGoal(int newGoal) async {
    _dailyGoal = newGoal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', newGoal);
    notifyListeners();
  }

  // Load saved goal
  Future<void> _loadSavedGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyGoal = prefs.getInt('daily_goal') ?? 10000;
    } catch (e) {
      _dailyGoal = 10000; // Default fallback
    }
  }

  // Check if it's a new day and reset if needed
  Future<void> _checkDailyReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final savedDate = prefs.getString('step_date') ?? '';

      if (savedDate != today) {
        // It's a new day - reset steps automatically
        _steps = 0;
        _baseSteps = 0;
        await prefs.setString('step_date', today);
        await prefs.setInt('base_steps', 0);
        await prefs.setInt('daily_steps', 0);
        _statusMessage = "New day started - Steps reset";
        notifyListeners();
      }
    } catch (e) {
      print('Error checking daily reset: $e');
    }
  }

  // Initialize with daily reset check and goal loading
  Future<void> initializeWithReset() async {
    await _loadSavedGoal();
    await _checkDailyReset();
    await _loadSavedSteps();
  }
}
