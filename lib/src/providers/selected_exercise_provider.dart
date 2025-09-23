// lib/src/providers/selected_exercise_provider.dart

import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class SelectedExerciseProvider with ChangeNotifier {
  final List<ExerciseModel> _selectedExercises = [];

  List<ExerciseModel> get selectedExercises =>
      List.unmodifiable(_selectedExercises);

  bool isSelected(ExerciseModel exercise) {
    if (exercise.id != null) {
      return _selectedExercises.any((selected) => selected.id == exercise.id);
    } else {
      // Fallback to name comparison if id is not available
      return _selectedExercises
          .any((selected) => selected.name == exercise.name);
    }
  }

  void toggleExerciseSelection(ExerciseModel exercise) {
    int index;
    if (exercise.id != null) {
      index = _selectedExercises
          .indexWhere((selected) => selected.id == exercise.id);
    } else {
      index = _selectedExercises
          .indexWhere((selected) => selected.name == exercise.name);
    }

    if (index != -1) {
      // Exercise already selected, remove it
      _selectedExercises.removeAt(index);
    } else {
      // Exercise not selected, add it
      _selectedExercises.add(exercise);
    }

    notifyListeners();
  }

  void removeExercise(ExerciseModel exercise) {
    if (exercise.id != null) {
      _selectedExercises.removeWhere((selected) => selected.id == exercise.id);
    } else {
      _selectedExercises
          .removeWhere((selected) => selected.name == exercise.name);
    }
    notifyListeners();
  }

  void removeExerciseAt(int index) {
    if (index >= 0 && index < _selectedExercises.length) {
      _selectedExercises.removeAt(index);
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedExercises.clear();
    notifyListeners();
  }

  int get selectedCount => _selectedExercises.length;
  bool get hasSelection => _selectedExercises.isNotEmpty;
}
