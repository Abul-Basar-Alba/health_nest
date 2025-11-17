// lib/src/models/women_health/symptom_log.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> symptoms;
  final String mood; // happy, sad, anxious, calm, energetic, tired
  final int painLevel; // 0-10
  final int energyLevel; // 0-10
  final String? notes;
  final DateTime createdAt;

  SymptomLog({
    required this.id,
    required this.userId,
    required this.date,
    this.symptoms = const [],
    this.mood = 'neutral',
    this.painLevel = 0,
    this.energyLevel = 5,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'symptoms': symptoms,
      'mood': mood,
      'painLevel': painLevel,
      'energyLevel': energyLevel,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SymptomLog.fromMap(String id, Map<String, dynamic> map) {
    return SymptomLog(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: map['mood'] ?? 'neutral',
      painLevel: map['painLevel'] ?? 0,
      energyLevel: map['energyLevel'] ?? 5,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  SymptomLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<String>? symptoms,
    String? mood,
    int? painLevel,
    int? energyLevel,
    String? notes,
    DateTime? createdAt,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      painLevel: painLevel ?? this.painLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Common symptoms list
class CommonSymptoms {
  static const List<String> all = [
    'Cramps',
    'Headache',
    'Nausea',
    'Bloating',
    'Fatigue',
    'Mood Swings',
    'Tender Breasts',
    'Back Pain',
    'Acne',
    'Food Cravings',
    'Insomnia',
    'Anxiety',
    'Depression',
    'Irritability',
  ];
}

// Mood options
class MoodOptions {
  static const List<Map<String, String>> all = [
    {'value': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'value': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'value': 'energetic', 'emoji': '⚡', 'label': 'Energetic'},
    {'value': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'value': 'tired', 'emoji': '😴', 'label': 'Tired'},
    {'value': 'anxious', 'emoji': '😰', 'label': 'Anxious'},
    {'value': 'sad', 'emoji': '😢', 'label': 'Sad'},
    {'value': 'irritable', 'emoji': '😠', 'label': 'Irritable'},
  ];
}
