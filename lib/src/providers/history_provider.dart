import 'package:flutter/material.dart';
import '../models/history_model.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryModel> _history = [];
  List<HistoryModel> get history => _history;

  // Example fetchHistory method
  void fetchHistory(String userId) {
    // TODO: Replace with Firestore fetch logic
    _history = [
      HistoryModel(
        id: '1',
        bmi: 22.5,
        calories: 1800,
        weight: 70,
        height: 1.75,
        age: 25,
        activityLevel: 'moderate',
        steps: 8000,
        timestamp: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  // Undo last history entry
  void undoLast() {
    if (_history.isNotEmpty) {
      _history.removeLast();
      notifyListeners();
    }
  }
}
