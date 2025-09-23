// lib/src/models/custom_workout_model.dart

import 'exercise_model.dart';

class CustomWorkoutModel {
  final String? id;
  final String name;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;

  CustomWorkoutModel({
    this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  factory CustomWorkoutModel.fromJson(Map<String, dynamic> json) {
    return CustomWorkoutModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:
          (json['createdAt'] as Map<String, dynamic>).containsKey('_seconds')
              ? DateTime.fromMillisecondsSinceEpoch(
                  (json['createdAt']['_seconds'] as int) * 1000)
              : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
