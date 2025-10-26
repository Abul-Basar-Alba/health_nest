// lib/src/models/activity_history_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityHistoryModel {
  final String id;
  final String userId;
  final DateTime date;
  final String activityLevel;
  final String? exerciseType;
  final int? durationMinutes;
  final int? caloriesBurned;
  final int? steps;
  final double? distanceKm;
  final String? notes;

  ActivityHistoryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.activityLevel,
    this.exerciseType,
    this.durationMinutes,
    this.caloriesBurned,
    this.steps,
    this.distanceKm,
    this.notes,
  });

  factory ActivityHistoryModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return ActivityHistoryModel(
      id: documentId,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      activityLevel: map['activityLevel'] ?? '',
      exerciseType: map['exerciseType'],
      durationMinutes: map['durationMinutes'],
      caloriesBurned: map['caloriesBurned'],
      steps: map['steps'],
      distanceKm: map['distanceKm']?.toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'activityLevel': activityLevel,
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'distanceKm': distanceKm,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get dateFormatted {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get timeFormatted {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get activityEmoji {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return '🪑';
      case 'light':
        return '🚶';
      case 'moderate':
        return '🏃';
      case 'active':
        return '🏋️';
      case 'very active':
        return '💪';
      default:
        return '🎯';
    }
  }
}
