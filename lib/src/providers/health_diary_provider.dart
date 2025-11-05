import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

import '../models/blood_pressure_log.dart';
import '../models/glucose_log.dart';
import '../models/mood_log.dart';
import '../models/weight_log.dart';
import '../services/health_diary_service.dart';

/// Provider for Health Diary state management
/// Manages all health metrics with real-time updates
class HealthDiaryProvider extends ChangeNotifier {
  final HealthDiaryService _service = HealthDiaryService();

  // State for each metric type
  List<BloodPressureLog> _bpLogs = [];
  List<GlucoseLog> _glucoseLogs = [];
  List<WeightLog> _weightLogs = [];
  List<MoodLog> _moodLogs = [];

  // Statistics
  Map<String, dynamic> _bpStats = {};
  Map<String, dynamic> _glucoseStats = {};
  Map<String, dynamic> _weightStats = {};
  Map<String, dynamic> _moodStats = {};

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Date range filter
  int _dateRangeDays = 30;

  // Stream subscriptions
  StreamSubscription<List<BloodPressureLog>>? _bpSubscription;
  StreamSubscription<List<GlucoseLog>>? _glucoseSubscription;
  StreamSubscription<List<WeightLog>>? _weightSubscription;
  StreamSubscription<List<MoodLog>>? _moodSubscription;

  // Getters
  List<BloodPressureLog> get bpLogs => _bpLogs;
  List<GlucoseLog> get glucoseLogs => _glucoseLogs;
  List<WeightLog> get weightLogs => _weightLogs;
  List<MoodLog> get moodLogs => _moodLogs;

  Map<String, dynamic> get bpStats => _bpStats;
  Map<String, dynamic> get glucoseStats => _glucoseStats;
  Map<String, dynamic> get weightStats => _weightStats;
  Map<String, dynamic> get moodStats => _moodStats;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get dateRangeDays => _dateRangeDays;

  /// Initialize health diary streams
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Subscribe to blood pressure logs
      _bpSubscription =
          _service.getBPStream(userId, days: _dateRangeDays).listen(
        (logs) {
          _bpLogs = logs;
          notifyListeners();
          _loadBPStatistics(userId);
        },
        onError: (error) {
          _errorMessage = 'Error loading BP logs: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );

      // Subscribe to glucose logs
      _glucoseSubscription =
          _service.getGlucoseStream(userId, days: _dateRangeDays).listen(
        (logs) {
          _glucoseLogs = logs;
          notifyListeners();
          _loadGlucoseStatistics(userId);
        },
        onError: (error) {
          _errorMessage = 'Error loading glucose logs: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );

      // Subscribe to weight logs
      _weightSubscription =
          _service.getWeightStream(userId, days: _dateRangeDays).listen(
        (logs) {
          _weightLogs = logs;
          notifyListeners();
          _loadWeightStatistics(userId);
        },
        onError: (error) {
          _errorMessage = 'Error loading weight logs: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );

      // Subscribe to mood logs
      _moodSubscription =
          _service.getMoodStream(userId, days: _dateRangeDays).listen(
        (logs) {
          _moodLogs = logs;
          notifyListeners();
          _loadMoodStatistics(userId);
        },
        onError: (error) {
          _errorMessage = 'Error loading mood logs: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize health diary: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  /// Load BP statistics
  Future<void> _loadBPStatistics(String userId) async {
    try {
      _bpStats = await _service.getBPStatistics(userId, days: _dateRangeDays);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading BP statistics: $e');
    }
  }

  /// Load glucose statistics
  Future<void> _loadGlucoseStatistics(String userId) async {
    try {
      _glucoseStats =
          await _service.getGlucoseStatistics(userId, days: _dateRangeDays);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading glucose statistics: $e');
    }
  }

  /// Load weight statistics
  Future<void> _loadWeightStatistics(String userId) async {
    try {
      _weightStats =
          await _service.getWeightStatistics(userId, days: _dateRangeDays);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading weight statistics: $e');
    }
  }

  /// Load mood statistics
  Future<void> _loadMoodStatistics(String userId) async {
    try {
      _moodStats =
          await _service.getMoodStatistics(userId, days: _dateRangeDays);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood statistics: $e');
    }
  }

  /// Change date range filter
  Future<void> changeDateRange(String userId, int days) async {
    _dateRangeDays = days;
    await initialize(userId);
  }

  // ============ BLOOD PRESSURE OPERATIONS ============

  /// Add blood pressure log
  Future<void> addBPLog(BloodPressureLog log) async {
    try {
      await _service.addBloodPressure(log);
    } catch (e) {
      _errorMessage = 'Failed to add BP log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Update blood pressure log
  Future<void> updateBPLog(BloodPressureLog log) async {
    try {
      await _service.updateBloodPressure(log);
    } catch (e) {
      _errorMessage = 'Failed to update BP log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Delete blood pressure log
  Future<void> deleteBPLog(String logId) async {
    try {
      await _service.deleteBloodPressure(logId);
    } catch (e) {
      _errorMessage = 'Failed to delete BP log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Get BP chart data for fl_chart
  List<FlSpot> getBPSystolicChartData() {
    if (_bpLogs.isEmpty) return [];

    // Sort by timestamp ascending for chart
    final sortedLogs = List<BloodPressureLog>.from(_bpLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.systolic.toDouble());
    }).toList();
  }

  List<FlSpot> getBPDiastolicChartData() {
    if (_bpLogs.isEmpty) return [];

    final sortedLogs = List<BloodPressureLog>.from(_bpLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.diastolic.toDouble());
    }).toList();
  }

  // ============ GLUCOSE OPERATIONS ============

  /// Add glucose log
  Future<void> addGlucoseLog(GlucoseLog log) async {
    try {
      await _service.addGlucose(log);
    } catch (e) {
      _errorMessage = 'Failed to add glucose log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Update glucose log
  Future<void> updateGlucoseLog(GlucoseLog log) async {
    try {
      await _service.updateGlucose(log);
    } catch (e) {
      _errorMessage = 'Failed to update glucose log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Delete glucose log
  Future<void> deleteGlucoseLog(String logId) async {
    try {
      await _service.deleteGlucose(logId);
    } catch (e) {
      _errorMessage = 'Failed to delete glucose log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Get glucose chart data for fl_chart
  List<FlSpot> getGlucoseChartData() {
    if (_glucoseLogs.isEmpty) return [];

    final sortedLogs = List<GlucoseLog>.from(_glucoseLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.glucose);
    }).toList();
  }

  // ============ WEIGHT OPERATIONS ============

  /// Add weight log
  Future<void> addWeightLog(WeightLog log) async {
    try {
      await _service.addWeight(log);
    } catch (e) {
      _errorMessage = 'Failed to add weight log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Update weight log
  Future<void> updateWeightLog(WeightLog log) async {
    try {
      await _service.updateWeight(log);
    } catch (e) {
      _errorMessage = 'Failed to update weight log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Delete weight log
  Future<void> deleteWeightLog(String logId) async {
    try {
      await _service.deleteWeight(logId);
    } catch (e) {
      _errorMessage = 'Failed to delete weight log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Get weight chart data for fl_chart
  List<FlSpot> getWeightChartData() {
    if (_weightLogs.isEmpty) return [];

    final sortedLogs = List<WeightLog>.from(_weightLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  List<FlSpot> getBMIChartData() {
    if (_weightLogs.isEmpty) return [];

    final sortedLogs = List<WeightLog>.from(_weightLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final logsWithBMI =
        sortedLogs.where((l) => l.calculatedBMI != null).toList();

    return logsWithBMI.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.calculatedBMI!);
    }).toList();
  }

  // ============ MOOD OPERATIONS ============

  /// Add mood log
  Future<void> addMoodLog(MoodLog log) async {
    try {
      await _service.addMood(log);
    } catch (e) {
      _errorMessage = 'Failed to add mood log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Update mood log
  Future<void> updateMoodLog(MoodLog log) async {
    try {
      await _service.updateMood(log);
    } catch (e) {
      _errorMessage = 'Failed to update mood log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Delete mood log
  Future<void> deleteMoodLog(String logId) async {
    try {
      await _service.deleteMood(logId);
    } catch (e) {
      _errorMessage = 'Failed to delete mood log: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// Get energy level chart data for fl_chart
  List<FlSpot> getEnergyLevelChartData() {
    if (_moodLogs.isEmpty) return [];

    final sortedLogs = List<MoodLog>.from(_moodLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.energyLevel.toDouble());
    }).toList();
  }

  // ============ EXPORT OPERATIONS ============

  /// Export data to CSV
  Future<String> exportToCSV(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      return await _service.exportToCSV(userId, startDate, endDate);
    } catch (e) {
      _errorMessage = 'Failed to export data: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _bpSubscription?.cancel();
    _glucoseSubscription?.cancel();
    _weightSubscription?.cancel();
    _moodSubscription?.cancel();
    super.dispose();
  }
}
