// lib/src/providers/history_provider.dart

import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/firestore_service.dart';

class HistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<HistoryModel> _history = [];
  double _todayCalories = 0.0;
  int _todaySteps = 0;

  List<HistoryModel> get history => _history;
  double get todayCalories => _todayCalories;
  int get todaySteps => _todaySteps;

  Future<void> fetchHistory(String userId) async {
    _firestoreService.getHistory(userId).listen((historyData) {
      _history = historyData;
      _calculateTodaySummary();
      notifyListeners();
    });
  }

  // Updated method: Now saves the entry to Firestore as well
  Future<void> addHistoryEntry(String userId, HistoryModel newEntry) async {
    // Save to Firestore first
    await _firestoreService.addHistoryEntry(userId, newEntry);

    // Then update the local list and notify listeners
    _history.insert(0, newEntry);
    _calculateTodaySummary();
    notifyListeners();
  }

  void _calculateTodaySummary() {
    final today = DateTime.now();
    _todayCalories = 0;
    _todaySteps = 0;

    for (var entry in _history) {
      final entryDate =
          entry.timestamp.toDate(); // Convert Firestore Timestamp to DateTime

      if (entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day) {
        // Use the new data map to get values
        _todayCalories += (entry.data['calories'] as num?)?.toDouble() ?? 0;
        _todaySteps += (entry.data['steps'] as num?)?.toInt() ?? 0;
      }
    }
  }

  void clearHistory() {
    _history = [];
    _todayCalories = 0;
    _todaySteps = 0;
    notifyListeners();
  }
}
