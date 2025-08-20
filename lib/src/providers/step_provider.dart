import 'package:flutter/foundation.dart';

class StepProvider with ChangeNotifier {
  int _steps = 0;
  double _caloriesBurned = 0.0;
  double _distanceKm = 0.0;

  int get steps => _steps;
  double get caloriesBurned => _caloriesBurned;
  double get distanceKm => _distanceKm;

  void updateSteps(int steps) {
    _steps = steps;
    // Assume a general conversion: ~0.04 kcal per step
    _caloriesBurned = steps * 0.04;
    // Assume average stride length of 0.762 meters (2.5 feet)
    _distanceKm = steps * 0.000762;
    notifyListeners();
  }
}
