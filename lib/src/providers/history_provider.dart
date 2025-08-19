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
      if (entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day) {
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
