// lib/src/providers/women_health_provider.dart

import 'package:flutter/material.dart';

import '../models/women_health/cycle_entry.dart';
import '../models/women_health/pill_log.dart';
import '../models/women_health/symptom_log.dart';
import '../models/women_health/women_health_settings.dart';
import '../services/women_health_service.dart';

class WomenHealthProvider with ChangeNotifier {
  final WomenHealthService _service = WomenHealthService();

  WomenHealthSettings? _settings;
  List<CycleEntry> _cycles = [];
  List<PillLog> _pillLogs = [];
  List<SymptomLog> _symptomLogs = [];
  Map<String, dynamic>? _statistics;
  Map<String, int>? _symptomFrequency;
  Map<String, dynamic>? _pillAdherence;
  bool _isLoading = false;

  // Getters
  WomenHealthSettings? get settings => _settings;
  List<CycleEntry> get cycles => _cycles;
  List<PillLog> get pillLogs => _pillLogs;
  List<SymptomLog> get symptomLogs => _symptomLogs;
  Map<String, dynamic>? get statistics => _statistics;
  Map<String, int>? get symptomFrequency => _symptomFrequency;
  Map<String, dynamic>? get pillAdherence => _pillAdherence;
  bool get isLoading => _isLoading;

  // Helper getter for pill adherence percentage
  double get pillAdherencePercentage {
    if (_pillAdherence == null) return 0.0;
    final percentage = _pillAdherence!['adherencePercentage'];
    if (percentage is int) return percentage.toDouble();
    if (percentage is double) return percentage;
    return 0.0;
  }

  bool get isPillTrackingEnabled => _settings?.isPillTrackingEnabled ?? false;

  DateTime? get nextPeriodDate => _settings?.predictedNextPeriod;

  int? get daysUntilNextPeriod => _settings?.daysUntilNextPeriod;

  // Initialize user data
  Future<void> initializeUserData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load settings
      _settings = await _service.getUserSettings(userId);

      // If no settings exist, create default
      if (_settings == null) {
        _settings = WomenHealthSettings(
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _service.saveUserSettings(_settings!);
      }

      // Load recent data
      await Future.wait([
        loadCycles(userId),
        loadPillLogs(userId),
        loadSymptomLogs(userId),
        loadStatistics(userId),
        loadSymptomFrequency(userId),
        loadPillAdherence(userId),
      ]);
    } catch (e) {
      print('Error initializing user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Settings Methods
  Future<void> updateSettings(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _service.updateUserSettings(userId, updates);
      _settings = await _service.getUserSettings(userId);
      notifyListeners();
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }

  Future<void> togglePillTracking(String userId, bool enabled) async {
    try {
      await updateSettings(userId, {'isPillTrackingEnabled': enabled});
    } catch (e) {
      print('Error toggling pill tracking: $e');
      rethrow;
    }
  }

  Future<void> updateLastPeriodStart(String userId, DateTime date) async {
    try {
      await updateSettings(userId, {'lastPeriodStart': date});
    } catch (e) {
      print('Error updating last period start: $e');
      rethrow;
    }
  }

  // Cycle Methods
  Future<void> loadCycles(String userId) async {
    try {
      _cycles = await _service.getCycleEntries(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading cycles: $e');
    }
  }

  Future<void> startNewCycle(String userId, DateTime startDate,
      {int flowLevel = 3}) async {
    try {
      final entry = CycleEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startDate: startDate,
        flowLevel: flowLevel,
        createdAt: DateTime.now(),
      );

      await _service.saveCycleEntry(entry);
      await updateLastPeriodStart(userId, startDate);
      await loadCycles(userId);
    } catch (e) {
      print('Error starting new cycle: $e');
      rethrow;
    }
  }

  Future<void> endCurrentCycle(String userId, DateTime endDate) async {
    try {
      final latestCycle = await _service.getLatestCycleEntry(userId);
      if (latestCycle != null && latestCycle.endDate == null) {
        await _service.updateCycleEntry(latestCycle.id, {
          'endDate': endDate,
        });
        await loadCycles(userId);
      }
    } catch (e) {
      print('Error ending cycle: $e');
      rethrow;
    }
  }

  // Pill Methods
  Future<void> loadPillLogs(String userId) async {
    try {
      _pillLogs = await _service.getPillLogs(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading pill logs: $e');
    }
  }

  Future<void> logPillTaken(String userId, DateTime date) async {
    try {
      final log = PillLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        pillName: 'Daily Pill',
        scheduledTime: date,
        takenTime: DateTime.now(),
        isTaken: true,
        createdAt: DateTime.now(),
      );

      await _service.savePillLog(log);
      await loadPillLogs(userId);
      await loadPillAdherence(userId);
    } catch (e) {
      print('Error logging pill taken: $e');
      rethrow;
    }
  }

  Future<void> markPillTaken(String logId, String userId) async {
    try {
      await _service.markPillTaken(logId);
      await loadPillLogs(userId);
      await loadPillAdherence(userId);
    } catch (e) {
      print('Error marking pill taken: $e');
      rethrow;
    }
  }

  Future<void> createPillLog(
      String userId, String pillName, DateTime scheduledTime) async {
    try {
      final log = PillLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        pillName: pillName,
        scheduledTime: scheduledTime,
        createdAt: DateTime.now(),
      );

      await _service.savePillLog(log);
      await loadPillLogs(userId);
    } catch (e) {
      print('Error creating pill log: $e');
      rethrow;
    }
  }

  // Symptom Methods
  Future<void> loadSymptomLogs(String userId) async {
    try {
      _symptomLogs = await _service.getSymptomLogs(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading symptom logs: $e');
    }
  }

  Future<void> saveSymptomLog(
    String userId,
    DateTime date, {
    List<String>? symptoms,
    String? mood,
    int? painLevel,
    int? energyLevel,
    String? notes,
  }) async {
    try {
      // Check if log already exists for this date
      final existingLog = await _service.getSymptomLogForDate(userId, date);

      final log = SymptomLog(
        id: existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: date,
        symptoms: symptoms ?? existingLog?.symptoms ?? [],
        mood: mood ?? existingLog?.mood ?? 'neutral',
        painLevel: painLevel ?? existingLog?.painLevel ?? 0,
        energyLevel: energyLevel ?? existingLog?.energyLevel ?? 5,
        notes: notes ?? existingLog?.notes,
        createdAt: existingLog?.createdAt ?? DateTime.now(),
      );

      await _service.saveSymptomLog(log);
      await loadSymptomLogs(userId);
      await loadSymptomFrequency(userId);
    } catch (e) {
      print('Error saving symptom log: $e');
      rethrow;
    }
  }

  // Statistics Methods
  Future<void> loadStatistics(String userId) async {
    try {
      _statistics = await _service.getCycleStatistics(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> loadSymptomFrequency(String userId) async {
    try {
      _symptomFrequency = await _service.getSymptomFrequency(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading symptom frequency: $e');
    }
  }

  Future<void> loadPillAdherence(String userId) async {
    try {
      _pillAdherence = await _service.getPillAdherence(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading pill adherence: $e');
    }
  }

  // Refresh all data
  Future<void> refreshAllData(String userId) async {
    await initializeUserData(userId);
  }

  // Clear data (for logout)
  void clearData() {
    _settings = null;
    _cycles = [];
    _pillLogs = [];
    _symptomLogs = [];
    _statistics = null;
    _symptomFrequency = null;
    _pillAdherence = null;
    notifyListeners();
  }
}
