// lib/src/providers/exercise_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise_model.dart';

class ExerciseProvider with ChangeNotifier {
  List<ExerciseModel> _allExercises = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<ExerciseModel> get allExercises => _allExercises;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  ExerciseProvider() {
    _loadExercises();
  }

  // Local JSON file থেকে exercises load করা
  Future<void> _loadExercises() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Load from local assets
      final String jsonString =
          await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Debugging: প্রথম 5টি আইটেম প্রিন্ট
      for (int i = 0; i < 5 && i < jsonData.length; i++) {
        print(
            'Exercise $i: ${jsonData[i]['name']} - ${jsonData[i]['caloriesPerMinute']} kcal/min');
      }

      _allExercises =
          jsonData.map((json) => ExerciseModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load exercises: $e';
      print('Error loading exercises: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // একটি bodyPart/primaryMuscle অনুযায়ী ফিল্টার
  List<ExerciseModel> getExercisesByBodyPart(String bodyPart) {
    return _allExercises
        .where((exercise) =>
            exercise.primaryMuscle != null &&
            exercise.primaryMuscle!.toLowerCase() == bodyPart.toLowerCase())
        .toList();
  }

  // Optional: category অনুযায়ী ফিল্টার
  List<ExerciseModel> getExercisesByCategory(String category) {
    return _allExercises
        .where((exercise) =>
            exercise.category != null &&
            exercise.category!.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
