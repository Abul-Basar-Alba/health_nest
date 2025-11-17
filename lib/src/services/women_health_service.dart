// lib/src/services/women_health_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/women_health/cycle_entry.dart';
import '../models/women_health/pill_log.dart';
import '../models/women_health/symptom_log.dart';
import '../models/women_health/women_health_settings.dart';

class WomenHealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Settings Methods
  Future<WomenHealthSettings?> getUserSettings(String userId) async {
    try {
      final doc = await _firestore
          .collection('women_health_settings')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return WomenHealthSettings.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  Future<void> saveUserSettings(WomenHealthSettings settings) async {
    try {
      await _firestore
          .collection('women_health_settings')
          .doc(settings.userId)
          .set(settings.toMap());
    } catch (e) {
      print('Error saving user settings: $e');
      rethrow;
    }
  }

  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('women_health_settings').doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }

  // Cycle Entry Methods
  Future<void> saveCycleEntry(CycleEntry entry) async {
    try {
      await _firestore
          .collection('cycle_entries')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      print('Error saving cycle entry: $e');
      rethrow;
    }
  }

  Future<List<CycleEntry>> getCycleEntries(String userId,
      {int limit = 12}) async {
    try {
      final querySnapshot = await _firestore
          .collection('cycle_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => CycleEntry.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting cycle entries: $e');
      return [];
    }
  }

  Future<CycleEntry?> getLatestCycleEntry(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('cycle_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return CycleEntry.fromMap(
        querySnapshot.docs.first.id,
        querySnapshot.docs.first.data(),
      );
    } catch (e) {
      print('Error getting latest cycle entry: $e');
      return null;
    }
  }

  Future<void> updateCycleEntry(
      String entryId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('cycle_entries').doc(entryId).update(updates);
    } catch (e) {
      print('Error updating cycle entry: $e');
      rethrow;
    }
  }

  // Pill Log Methods
  Future<void> savePillLog(PillLog log) async {
    try {
      await _firestore.collection('pill_logs').doc(log.id).set(log.toMap());
    } catch (e) {
      print('Error saving pill log: $e');
      rethrow;
    }
  }

  Future<List<PillLog>> getPillLogs(String userId, {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final querySnapshot = await _firestore
          .collection('pill_logs')
          .where('userId', isEqualTo: userId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('scheduledTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PillLog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting pill logs: $e');
      return [];
    }
  }

  Future<List<PillLog>> getTodayPillLogs(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('pill_logs')
          .where('userId', isEqualTo: userId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) => PillLog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting today pill logs: $e');
      return [];
    }
  }

  Future<void> markPillTaken(String logId) async {
    try {
      await _firestore.collection('pill_logs').doc(logId).update({
        'isTaken': true,
        'takenTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking pill taken: $e');
      rethrow;
    }
  }

  Future<void> markPillMissed(String logId) async {
    try {
      await _firestore.collection('pill_logs').doc(logId).update({
        'isMissed': true,
      });
    } catch (e) {
      print('Error marking pill missed: $e');
      rethrow;
    }
  }

  // Symptom Log Methods
  Future<void> saveSymptomLog(SymptomLog log) async {
    try {
      await _firestore.collection('symptom_logs').doc(log.id).set(log.toMap());
    } catch (e) {
      print('Error saving symptom log: $e');
      rethrow;
    }
  }

  Future<List<SymptomLog>> getSymptomLogs(String userId,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final querySnapshot = await _firestore
          .collection('symptom_logs')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SymptomLog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting symptom logs: $e');
      return [];
    }
  }

  Future<SymptomLog?> getSymptomLogForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('symptom_logs')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return SymptomLog.fromMap(
        querySnapshot.docs.first.id,
        querySnapshot.docs.first.data(),
      );
    } catch (e) {
      print('Error getting symptom log for date: $e');
      return null;
    }
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getCycleStatistics(String userId) async {
    try {
      final cycles = await getCycleEntries(userId, limit: 12);

      if (cycles.isEmpty) {
        return {
          'averageCycleLength': 0,
          'averagePeriodLength': 0,
          'regularity': 0.0,
          'lastThreeCycles': [],
        };
      }

      // Calculate average cycle length
      int totalCycleLength = 0;
      int cycleCount = 0;
      List<int> cycleLengths = [];

      for (int i = 0; i < cycles.length - 1; i++) {
        final current = cycles[i];
        final previous = cycles[i + 1];
        final daysBetween =
            current.startDate.difference(previous.startDate).inDays;
        totalCycleLength += daysBetween;
        cycleLengths.add(daysBetween);
        cycleCount++;
      }

      final avgCycleLength =
          cycleCount > 0 ? (totalCycleLength / cycleCount).round() : 0;

      // Calculate average period length
      int totalPeriodLength = 0;
      int periodCount = 0;

      for (final cycle in cycles) {
        if (cycle.cycleLength != null) {
          totalPeriodLength += cycle.cycleLength!;
          periodCount++;
        }
      }

      final avgPeriodLength =
          periodCount > 0 ? (totalPeriodLength / periodCount).round() : 0;

      // Calculate regularity (how consistent the cycles are)
      double regularity = 100.0;
      if (cycleLengths.length >= 3) {
        final variance = _calculateVariance(cycleLengths);
        regularity = (100 - (variance * 2)).clamp(0.0, 100.0);
      }

      return {
        'averageCycleLength': avgCycleLength,
        'averagePeriodLength': avgPeriodLength,
        'regularity': regularity,
        'lastThreeCycles': cycleLengths.take(3).toList(),
      };
    } catch (e) {
      print('Error getting cycle statistics: $e');
      return {
        'averageCycleLength': 0,
        'averagePeriodLength': 0,
        'regularity': 0.0,
        'lastThreeCycles': [],
      };
    }
  }

  Future<Map<String, int>> getSymptomFrequency(String userId,
      {int days = 90}) async {
    try {
      final symptoms = await getSymptomLogs(userId, days: days);
      final Map<String, int> frequency = {};

      for (final log in symptoms) {
        for (final symptom in log.symptoms) {
          frequency[symptom] = (frequency[symptom] ?? 0) + 1;
        }
      }

      // Sort by frequency
      final sortedEntries = frequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sortedEntries.take(5));
    } catch (e) {
      print('Error getting symptom frequency: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getPillAdherence(String userId,
      {int days = 30}) async {
    try {
      final pills = await getPillLogs(userId, days: days);

      if (pills.isEmpty) {
        return {
          'totalPills': 0,
          'takenPills': 0,
          'missedPills': 0,
          'adherencePercentage': 0.0,
          'currentStreak': 0,
        };
      }

      final takenPills = pills.where((p) => p.isTaken).length;
      final missedPills = pills.where((p) => p.isMissed).length;
      final adherencePercentage = (takenPills / pills.length * 100).round();

      // Calculate current streak
      int currentStreak = 0;
      final sortedPills = pills.toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      for (final pill in sortedPills) {
        if (pill.isTaken) {
          currentStreak++;
        } else {
          break;
        }
      }

      return {
        'totalPills': pills.length,
        'takenPills': takenPills,
        'missedPills': missedPills,
        'adherencePercentage': adherencePercentage,
        'currentStreak': currentStreak,
      };
    } catch (e) {
      print('Error getting pill adherence: $e');
      return {
        'totalPills': 0,
        'takenPills': 0,
        'missedPills': 0,
        'adherencePercentage': 0,
        'currentStreak': 0,
      };
    }
  }

  // Helper Methods
  double _calculateVariance(List<int> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;

    return variance;
  }

  // Prediction Methods
  DateTime? predictNextPeriod(
      String userId, int averageCycleLength, DateTime lastPeriodStart) {
    return lastPeriodStart.add(Duration(days: averageCycleLength));
  }

  DateTime? predictOvulation(DateTime periodStart, int cycleLength) {
    // Ovulation typically occurs 14 days before next period
    return periodStart.add(Duration(days: cycleLength - 14));
  }

  List<DateTime> predictFertileWindow(DateTime ovulationDay) {
    // Fertile window is typically 5 days before ovulation + ovulation day
    final List<DateTime> fertileDays = [];
    for (int i = 5; i >= 0; i--) {
      fertileDays.add(ovulationDay.subtract(Duration(days: i)));
    }
    return fertileDays;
  }
}
