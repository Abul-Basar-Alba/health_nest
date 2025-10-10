// lib/src/services/pedometer_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class PedometerService {
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  // Use a StreamController to expose a simple stream of steps
  final _stepCountController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  bool _isInitialized = false;
  int _lastStepCount = 0;

  PedometerService() {
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        _statusController.add('Step counting not supported on web');
        return;
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        _statusController.add('Step counting only supported on mobile devices');
        return;
      }

      // Initialize step count stream
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      // Initialize pedestrian status stream
      _statusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      _isInitialized = true;
      _statusController.add('Pedometer initialized successfully');
    } catch (e) {
      _statusController.add('Failed to initialize pedometer: $e');
      _onStepCountError(e);
    }
  }

  void _onStepCount(StepCount event) {
    try {
      final steps = event.steps;

      // Basic validation
      if (steps >= 0 && steps != _lastStepCount) {
        _lastStepCount = steps;
        _stepCountController.add(steps);
        _statusController.add('Step count updated: $steps');
      }
    } catch (e) {
      _onStepCountError('Error processing step count: $e');
    }
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _statusController.add('Pedestrian status: ${event.status}');
  }

  void _onStepCountError(dynamic error) {
    print('Pedometer step count error: $error');
    _statusController.add('Pedometer error: $error');

    // Try to reinitialize after error
    Future.delayed(const Duration(seconds: 5), () {
      if (!_stepCountController.isClosed) {
        _reinitialize();
      }
    });
  }

  void _onPedestrianStatusError(dynamic error) {
    print('Pedometer status error: $error');
    _statusController.add('Pedestrian status error: $error');
  }

  Future<void> _reinitialize() async {
    try {
      dispose();
      _isInitialized = false;
      await Future.delayed(const Duration(seconds: 1));
      _initPedometer();
    } catch (e) {
      print('Failed to reinitialize pedometer: $e');
    }
  }

  // Public getters
  Stream<int> get stepCountStream => _stepCountController.stream;
  Stream<String> get statusStream => _statusController.stream;

  // Check if pedometer is available
  static Future<bool> isStepCountingAvailable() async {
    try {
      if (kIsWeb) return false;
      if (!Platform.isAndroid && !Platform.isIOS) return false;

      // Try to get a step count to verify sensor availability
      final completer = Completer<bool>();
      StreamSubscription? subscription;

      subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          subscription?.cancel();
          completer.complete(true);
        },
        onError: (error) {
          subscription?.cancel();
          completer.complete(false);
        },
      );

      // Timeout after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _stepCountController.close();
    _statusController.close();
    _isInitialized = false;
  }
}
