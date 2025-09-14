// lib/src/services/pedometer_service.dart

import 'dart:async';
import 'package:pedometer/pedometer.dart';

class PedometerService {
  late Stream<StepCount> _stepCountStream;
  late StreamSubscription<StepCount> _subscription;

  // Use a StreamController to expose a simple stream of steps
  final _stepCountController = StreamController<int>.broadcast();

  PedometerService() {
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _subscription = _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );
  }

  void _onStepCount(StepCount event) {
    // We only send the latest steps to our controller
    _stepCountController.add(event.steps);
  }

  void _onStepCountError(error) {
    print('Pedometer error: $error');
    _stepCountController.addError('Pedometer service error');
  }

  // Public getter to expose the stream
  Stream<int> get stepCountStream => _stepCountController.stream;

  // Don't forget to dispose of the stream controller and subscription
  void dispose() {
    _subscription.cancel();
    _stepCountController.close();
  }
}
