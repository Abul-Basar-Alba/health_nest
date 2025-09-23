// lib/src/providers/step_provider.dart
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/pedometer_service.dart';

class StepProvider with ChangeNotifier {
  int _steps = 0;
  double _caloriesBurned = 0.0;
  double _distanceKm = 0.0;
  final PedometerService _pedometerService = PedometerService();

  int get steps => _steps;
  double get caloriesBurned => _caloriesBurned;
  double get distanceKm => _distanceKm;

  StepProvider() {
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      await Permission.activityRecognition.request();
    }

    _pedometerService.stepCountStream.listen((int newSteps) {
      updateSteps(newSteps);
    });
  }

  void updateSteps(int steps) {
    _steps = steps;
    _caloriesBurned = steps * 0.04; // Assume ~0.04 kcal per step
    _distanceKm = steps * 0.000762; // Assume average stride length
    notifyListeners();
  }
}
