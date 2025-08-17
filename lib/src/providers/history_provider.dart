import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/history_model.dart';

class HistoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<HistoryModel> _history = [];

  List<HistoryModel> get history => _history;

  Future<void> fetchHistory(String userId) async {
    _firestoreService.getHistory(userId).listen((history) {
      _history = history;
      notifyListeners();
    });
  }
}
