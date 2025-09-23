// lib/src/services/exercise_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ExerciseService {
  Future<List<dynamic>> getExercises() async {
    // Local JSON ফাইল থেকে ডেটা লোড করার জন্য ফাইল পাথ
    final String response =
        await rootBundle.loadString('assets/exercises.json');

    // JSON ডেটা ডিকোড করা
    final List<dynamic> data = await json.decode(response);
    return data;
  }
}
