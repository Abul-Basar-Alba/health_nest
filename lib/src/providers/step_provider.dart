import 'package:flutter/foundation.dart';

class StepProvider with ChangeNotifier {
  int _steps = 0;
  int get steps => _steps;

  void setSteps(int value) {
    _steps = value;
    notifyListeners();
  }
}
