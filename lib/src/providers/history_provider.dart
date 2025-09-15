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

  void addHistoryEntry(HistoryModel newEntry) {
    _history.insert(0, newEntry);
    _calculateTodaySummary();
    notifyListeners();
  }

  void _calculateTodaySummary() {
    final today = DateTime.now();
    _todayCalories = 0;
    _todaySteps = 0;

    for (var entry in _history) {
      // Use the timestamp string to create a DateTime object
      final entryDate = DateTime.tryParse(entry.timestamp as String);
      if (entryDate != null &&
          entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day) {
        _todayCalories += entry.calories ?? 0;
        _todaySteps += entry.steps ?? 0;
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
