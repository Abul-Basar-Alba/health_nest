import 'dart:async';
import 'package:pedometer/pedometer.dart';

class PedometerService {
  late Stream<StepCount> _stepCountStream;
  int _currentSteps = 0;

  PedometerService() {
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );
  }

  void _onStepCount(StepCount event) {
    // You may need to handle step count resetting at midnight
    _currentSteps = event.steps;
  }

  void _onStepCountError(error) {
    print('Pedometer error: $error');
  }

  Stream<int> get stepCountStream =>
      _stepCountStream.map((event) => event.steps);
}
