// lib/src/providers/medicine_reminder_provider.dart

import 'package:flutter/foundation.dart';

import '../models/medicine_model.dart';
import '../services/medicine_reminder_service.dart';

class MedicineReminderProvider with ChangeNotifier {
  final MedicineReminderService _service = MedicineReminderService();

  List<MedicineModel> _medicines = [];
  List<Map<String, dynamic>> _todaysSchedule = [];
  double _adherenceRate = 0.0;
  bool _isLoading = false;

  List<MedicineModel> get medicines => _medicines;
  List<Map<String, dynamic>> get todaysSchedule => _todaysSchedule;
  double get adherenceRate => _adherenceRate;
  bool get isLoading => _isLoading;

  void listenToMedicines(String userId) {
    _service.getMedicinesStream(userId).listen((medicines) {
      _medicines = medicines;
      notifyListeners();
      _loadTodaysSchedule(userId);
    });
  }

  Future<void> _loadTodaysSchedule(String userId) async {
    _todaysSchedule = await _service.getTodaysSchedule(userId);
    notifyListeners();
  }

  Future<void> loadAdherence(String userId) async {
    _adherenceRate = await _service.calculateAdherence(userId);
    notifyListeners();
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();
    await _service.addMedicine(medicine);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    await _service.updateMedicine(medicine);
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _service.deleteMedicine(medicineId);
  }

  Future<void> markAsTaken(
      String medicineId, String userId, DateTime scheduledTime) async {
    await _service.markAsTaken(medicineId, userId, scheduledTime);
    _loadTodaysSchedule(userId);
  }
}
