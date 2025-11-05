// lib/src/providers/water_reminder_provider.dart

import 'package:flutter/foundation.dart';

import '../models/water_reminder_model.dart';
import '../services/water_reminder_service.dart';

class WaterReminderProvider with ChangeNotifier {
  final WaterReminderService _service = WaterReminderService();

  WaterReminderModel? _reminder;
  bool _isLoading = false;
  String? _error;

  WaterReminderModel? get reminder => _reminder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for easy access
  int get todayIntake => _reminder?.todayIntake ?? 0;
  int get targetGlasses => _reminder?.targetGlasses ?? 8;
  int get glassSize => _reminder?.glassSize ?? 250;
  double get percentageCompleted => _reminder?.percentageCompleted ?? 0.0;
  int get totalMlToday => _reminder?.totalMlToday ?? 0;
  int get targetMl => _reminder?.targetMl ?? 2000;
  List<String> get reminderTimes => _reminder?.reminderTimes ?? [];
  bool get isEnabled => _reminder?.isEnabled ?? true;

  // Initialize for user
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.initialize();

      // Try to load existing schedule
      final existing = await _service.getSchedule(userId);

      if (existing != null) {
        _reminder = existing;

        // Check if needs reset
        if (_reminder!.needsReset()) {
          await resetDaily(userId);
        }
      } else {
        // Create default schedule
        _reminder = WaterReminderModel(userId: userId);
        await _service.saveSchedule(_reminder!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Drink water (add glasses)
  Future<void> drinkWater(int glasses) async {
    if (_reminder == null) return;

    try {
      await _service.logWaterIntake(_reminder!.userId, glasses);

      // Update local state
      _reminder = _reminder!.copyWith(
        todayIntake: _reminder!.todayIntake + glasses,
        lastDrinkTime: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _error = 'Failed to log water intake: $e';
      notifyListeners();
    }
  }

  // Update target glasses
  Future<void> updateTarget(int newTarget) async {
    if (_reminder == null) return;

    try {
      _reminder = _reminder!.copyWith(targetGlasses: newTarget);
      await _service.saveSchedule(_reminder!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update target: $e';
      notifyListeners();
    }
  }

  // Update glass size
  Future<void> updateGlassSize(int newSize) async {
    if (_reminder == null) return;

    try {
      _reminder = _reminder!.copyWith(glassSize: newSize);
      await _service.saveSchedule(_reminder!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update glass size: $e';
      notifyListeners();
    }
  }

  // Update reminder times
  Future<void> updateReminderTimes(List<String> times) async {
    if (_reminder == null) return;

    try {
      _reminder = _reminder!.copyWith(reminderTimes: times);
      await _service.saveSchedule(_reminder!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update reminder times: $e';
      notifyListeners();
    }
  }

  // Toggle reminders on/off
  Future<void> toggleReminders(bool enabled) async {
    if (_reminder == null) return;

    try {
      _reminder = _reminder!.copyWith(isEnabled: enabled);
      await _service.saveSchedule(_reminder!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle reminders: $e';
      notifyListeners();
    }
  }

  // Add reminder time
  Future<void> addReminderTime(String time) async {
    if (_reminder == null) return;

    try {
      final times = List<String>.from(_reminder!.reminderTimes);
      if (!times.contains(time)) {
        times.add(time);
        times.sort(); // Keep sorted
        await updateReminderTimes(times);
      }
    } catch (e) {
      _error = 'Failed to add reminder time: $e';
      notifyListeners();
    }
  }

  // Remove reminder time
  Future<void> removeReminderTime(String time) async {
    if (_reminder == null) return;

    try {
      final times = List<String>.from(_reminder!.reminderTimes);
      times.remove(time);
      await updateReminderTimes(times);
    } catch (e) {
      _error = 'Failed to remove reminder time: $e';
      notifyListeners();
    }
  }

  // Reset daily (called at midnight or manually)
  Future<void> resetDaily(String userId) async {
    if (_reminder == null) return;

    try {
      _reminder = _reminder!.copyWith(
        todayIntake: 0,
        lastResetDate: DateTime.now(),
      );
      await _service.saveSchedule(_reminder!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset daily: $e';
      notifyListeners();
    }
  }

  // Get history
  Future<List<WaterIntakeHistory>> getHistory({int days = 7}) async {
    if (_reminder == null) return [];

    try {
      return await _service.getHistory(_reminder!.userId, days: days);
    } catch (e) {
      _error = 'Failed to load history: $e';
      notifyListeners();
      return [];
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      return await _service.requestPermissions();
    } catch (e) {
      _error = 'Failed to request permissions: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
