import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/blood_pressure_log.dart';
import '../models/glucose_log.dart';
import '../models/mood_log.dart';
import '../models/weight_log.dart';

/// Service for managing health diary data
/// Provides CRUD operations, statistics, and export functionality
class HealthDiaryService {
  static final HealthDiaryService _instance = HealthDiaryService._internal();
  factory HealthDiaryService() => _instance;
  HealthDiaryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _bpCollection = 'blood_pressure_logs';
  static const String _glucoseCollection = 'glucose_logs';
  static const String _weightCollection = 'weight_logs';
  static const String _moodCollection = 'mood_logs';

  // ============ BLOOD PRESSURE OPERATIONS ============

  /// Add new blood pressure log
  Future<String> addBloodPressure(BloodPressureLog log) async {
    try {
      final docRef =
          await _firestore.collection(_bpCollection).add(log.toMap());
      debugPrint('Blood pressure log added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding blood pressure log: $e');
      rethrow;
    }
  }

  /// Update blood pressure log
  Future<void> updateBloodPressure(BloodPressureLog log) async {
    try {
      await _firestore
          .collection(_bpCollection)
          .doc(log.id)
          .update(log.toMap());
      debugPrint('Blood pressure log updated: ${log.id}');
    } catch (e) {
      debugPrint('Error updating blood pressure log: $e');
      rethrow;
    }
  }

  /// Delete blood pressure log
  Future<void> deleteBloodPressure(String logId) async {
    try {
      await _firestore.collection(_bpCollection).doc(logId).delete();
      debugPrint('Blood pressure log deleted: $logId');
    } catch (e) {
      debugPrint('Error deleting blood pressure log: $e');
      rethrow;
    }
  }

  /// Get blood pressure logs stream for a user
  Stream<List<BloodPressureLog>> getBPStream(String userId, {int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection(_bpCollection)
        .where('userId', isEqualTo: userId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => BloodPressureLog.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by timestamp descending (newest first) on client side
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  /// Get blood pressure statistics
  Future<Map<String, dynamic>> getBPStatistics(String userId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(_bpCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'count': 0,
          'avgSystolic': 0.0,
          'avgDiastolic': 0.0,
          'avgPulse': 0.0,
          'maxSystolic': 0,
          'minSystolic': 0,
          'maxDiastolic': 0,
          'minDiastolic': 0,
        };
      }

      final logs = snapshot.docs
          .map((doc) => BloodPressureLog.fromMap(doc.id, doc.data()))
          .toList();

      final systolicValues = logs.map((l) => l.systolic).toList();
      final diastolicValues = logs.map((l) => l.diastolic).toList();
      final pulseValues = logs.map((l) => l.pulse).toList();

      return {
        'count': logs.length,
        'avgSystolic': systolicValues.reduce((a, b) => a + b) / logs.length,
        'avgDiastolic': diastolicValues.reduce((a, b) => a + b) / logs.length,
        'avgPulse': pulseValues.reduce((a, b) => a + b) / logs.length,
        'maxSystolic': systolicValues.reduce((a, b) => a > b ? a : b),
        'minSystolic': systolicValues.reduce((a, b) => a < b ? a : b),
        'maxDiastolic': diastolicValues.reduce((a, b) => a > b ? a : b),
        'minDiastolic': diastolicValues.reduce((a, b) => a < b ? a : b),
      };
    } catch (e) {
      debugPrint('Error getting BP statistics: $e');
      rethrow;
    }
  }

  // ============ GLUCOSE OPERATIONS ============

  /// Add new glucose log
  Future<String> addGlucose(GlucoseLog log) async {
    try {
      final docRef =
          await _firestore.collection(_glucoseCollection).add(log.toMap());
      debugPrint('Glucose log added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding glucose log: $e');
      rethrow;
    }
  }

  /// Update glucose log
  Future<void> updateGlucose(GlucoseLog log) async {
    try {
      await _firestore
          .collection(_glucoseCollection)
          .doc(log.id)
          .update(log.toMap());
      debugPrint('Glucose log updated: ${log.id}');
    } catch (e) {
      debugPrint('Error updating glucose log: $e');
      rethrow;
    }
  }

  /// Delete glucose log
  Future<void> deleteGlucose(String logId) async {
    try {
      await _firestore.collection(_glucoseCollection).doc(logId).delete();
      debugPrint('Glucose log deleted: $logId');
    } catch (e) {
      debugPrint('Error deleting glucose log: $e');
      rethrow;
    }
  }

  /// Get glucose logs stream for a user
  Stream<List<GlucoseLog>> getGlucoseStream(String userId, {int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection(_glucoseCollection)
        .where('userId', isEqualTo: userId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => GlucoseLog.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by timestamp descending on client side
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  /// Get glucose statistics
  Future<Map<String, dynamic>> getGlucoseStatistics(String userId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(_glucoseCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'count': 0,
          'avgGlucose': 0.0,
          'maxGlucose': 0.0,
          'minGlucose': 0.0,
          'fastingCount': 0,
          'randomCount': 0,
          'postMealCount': 0,
        };
      }

      final logs = snapshot.docs
          .map((doc) => GlucoseLog.fromMap(doc.id, doc.data()))
          .toList();

      final glucoseValues = logs.map((l) => l.glucose).toList();
      final fastingLogs =
          logs.where((l) => l.measurementType == 'fasting').toList();
      final randomLogs =
          logs.where((l) => l.measurementType == 'random').toList();
      final postMealLogs =
          logs.where((l) => l.measurementType == 'post-meal').toList();

      return {
        'count': logs.length,
        'avgGlucose': glucoseValues.reduce((a, b) => a + b) / logs.length,
        'maxGlucose': glucoseValues.reduce((a, b) => a > b ? a : b),
        'minGlucose': glucoseValues.reduce((a, b) => a < b ? a : b),
        'fastingCount': fastingLogs.length,
        'randomCount': randomLogs.length,
        'postMealCount': postMealLogs.length,
        'avgFasting': fastingLogs.isNotEmpty
            ? fastingLogs.map((l) => l.glucose).reduce((a, b) => a + b) /
                fastingLogs.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting glucose statistics: $e');
      rethrow;
    }
  }

  // ============ WEIGHT OPERATIONS ============

  /// Add new weight log
  Future<String> addWeight(WeightLog log) async {
    try {
      final docRef =
          await _firestore.collection(_weightCollection).add(log.toMap());
      debugPrint('Weight log added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding weight log: $e');
      rethrow;
    }
  }

  /// Update weight log
  Future<void> updateWeight(WeightLog log) async {
    try {
      await _firestore
          .collection(_weightCollection)
          .doc(log.id)
          .update(log.toMap());
      debugPrint('Weight log updated: ${log.id}');
    } catch (e) {
      debugPrint('Error updating weight log: $e');
      rethrow;
    }
  }

  /// Delete weight log
  Future<void> deleteWeight(String logId) async {
    try {
      await _firestore.collection(_weightCollection).doc(logId).delete();
      debugPrint('Weight log deleted: $logId');
    } catch (e) {
      debugPrint('Error deleting weight log: $e');
      rethrow;
    }
  }

  /// Get weight logs stream for a user
  Stream<List<WeightLog>> getWeightStream(String userId, {int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection(_weightCollection)
        .where('userId', isEqualTo: userId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => WeightLog.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by timestamp descending on client side
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  /// Get weight statistics
  Future<Map<String, dynamic>> getWeightStatistics(String userId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(_weightCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'count': 0,
          'avgWeight': 0.0,
          'maxWeight': 0.0,
          'minWeight': 0.0,
          'avgBMI': null,
          'weightChange': 0.0,
        };
      }

      final logs = snapshot.docs
          .map((doc) => WeightLog.fromMap(doc.id, doc.data()))
          .toList();

      // Sort by timestamp for trend calculation
      logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final weightValues = logs.map((l) => l.weight).toList();
      final bmiValues = logs
          .where((l) => l.calculatedBMI != null)
          .map((l) => l.calculatedBMI!)
          .toList();

      // Calculate weight change (latest - earliest)
      final weightChange =
          logs.isNotEmpty ? logs.last.weight - logs.first.weight : 0.0;

      return {
        'count': logs.length,
        'avgWeight': weightValues.reduce((a, b) => a + b) / logs.length,
        'maxWeight': weightValues.reduce((a, b) => a > b ? a : b),
        'minWeight': weightValues.reduce((a, b) => a < b ? a : b),
        'avgBMI': bmiValues.isNotEmpty
            ? bmiValues.reduce((a, b) => a + b) / bmiValues.length
            : null,
        'weightChange': weightChange,
        'currentWeight': logs.last.weight,
        'currentBMI': logs.last.calculatedBMI,
      };
    } catch (e) {
      debugPrint('Error getting weight statistics: $e');
      rethrow;
    }
  }

  // ============ MOOD OPERATIONS ============

  /// Add new mood log
  Future<String> addMood(MoodLog log) async {
    try {
      final docRef =
          await _firestore.collection(_moodCollection).add(log.toMap());
      debugPrint('Mood log added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding mood log: $e');
      rethrow;
    }
  }

  /// Update mood log
  Future<void> updateMood(MoodLog log) async {
    try {
      await _firestore
          .collection(_moodCollection)
          .doc(log.id)
          .update(log.toMap());
      debugPrint('Mood log updated: ${log.id}');
    } catch (e) {
      debugPrint('Error updating mood log: $e');
      rethrow;
    }
  }

  /// Delete mood log
  Future<void> deleteMood(String logId) async {
    try {
      await _firestore.collection(_moodCollection).doc(logId).delete();
      debugPrint('Mood log deleted: $logId');
    } catch (e) {
      debugPrint('Error deleting mood log: $e');
      rethrow;
    }
  }

  /// Get mood logs stream for a user
  Stream<List<MoodLog>> getMoodStream(String userId, {int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection(_moodCollection)
        .where('userId', isEqualTo: userId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => MoodLog.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by timestamp descending on client side
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  /// Get mood statistics
  Future<Map<String, dynamic>> getMoodStatistics(String userId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(_moodCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'count': 0,
          'avgEnergyLevel': 0.0,
          'mostCommonMood': 'N/A',
          'positiveMoodCount': 0,
          'negativeMoodCount': 0,
          'neutralMoodCount': 0,
        };
      }

      final logs = snapshot.docs
          .map((doc) => MoodLog.fromMap(doc.id, doc.data()))
          .toList();

      final energyLevels = logs.map((l) => l.energyLevel).toList();
      final positiveMoods = logs.where((l) => l.isPositiveMood).length;
      final negativeMoods = logs.where((l) => l.isNegativeMood).length;

      // Find most common mood
      final moodCounts = <String, int>{};
      for (final log in logs) {
        moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
      }
      final mostCommonMood = moodCounts.entries.isEmpty
          ? 'N/A'
          : moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'count': logs.length,
        'avgEnergyLevel': energyLevels.reduce((a, b) => a + b) / logs.length,
        'mostCommonMood': mostCommonMood,
        'positiveMoodCount': positiveMoods,
        'negativeMoodCount': negativeMoods,
        'neutralMoodCount': logs.length - positiveMoods - negativeMoods,
        'moodDistribution': moodCounts,
      };
    } catch (e) {
      debugPrint('Error getting mood statistics: $e');
      rethrow;
    }
  }

  // ============ EXPORT FUNCTIONALITY ============

  /// Export data to CSV format
  Future<String> exportToCSV(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final buffer = StringBuffer();

      // Export Blood Pressure
      buffer.writeln('BLOOD PRESSURE LOGS');
      buffer.writeln('Date,Time,Systolic,Diastolic,Pulse,Notes');

      final bpSnapshot = await _firestore
          .collection(_bpCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (final doc in bpSnapshot.docs) {
        final log = BloodPressureLog.fromMap(doc.id, doc.data());
        buffer.writeln(
            '${log.timestamp.toString().split(' ')[0]},${log.timestamp.toString().split(' ')[1].substring(0, 8)},${log.systolic},${log.diastolic},${log.pulse},"${log.notes ?? ''}"');
      }

      buffer.writeln('\nGLUCOSE LOGS');
      buffer.writeln('Date,Time,Glucose (mg/dL),Type,Meal Context,Notes');

      final glucoseSnapshot = await _firestore
          .collection(_glucoseCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (final doc in glucoseSnapshot.docs) {
        final log = GlucoseLog.fromMap(doc.id, doc.data());
        buffer.writeln(
            '${log.timestamp.toString().split(' ')[0]},${log.timestamp.toString().split(' ')[1].substring(0, 8)},${log.glucose},${log.measurementType},"${log.mealContext ?? ''}","${log.notes ?? ''}"');
      }

      buffer.writeln('\nWEIGHT LOGS');
      buffer.writeln('Date,Time,Weight (kg),Height (cm),BMI,Notes');

      final weightSnapshot = await _firestore
          .collection(_weightCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (final doc in weightSnapshot.docs) {
        final log = WeightLog.fromMap(doc.id, doc.data());
        buffer.writeln(
            '${log.timestamp.toString().split(' ')[0]},${log.timestamp.toString().split(' ')[1].substring(0, 8)},${log.weight},${log.height ?? ''},${log.calculatedBMI?.toStringAsFixed(1) ?? ''},"${log.notes ?? ''}"');
      }

      buffer.writeln('\nMOOD LOGS');
      buffer.writeln('Date,Time,Mood,Energy Level,Notes');

      final moodSnapshot = await _firestore
          .collection(_moodCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (final doc in moodSnapshot.docs) {
        final log = MoodLog.fromMap(doc.id, doc.data());
        buffer.writeln(
            '${log.timestamp.toString().split(' ')[0]},${log.timestamp.toString().split(' ')[1].substring(0, 8)},${log.mood},${log.energyLevel},"${log.notes ?? ''}"');
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      rethrow;
    }
  }
}
