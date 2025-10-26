// lib/src/models/bmi_history_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class BMIHistoryModel {
  final String id;
  final String userId;
  final DateTime date;
  final double bmi;
  final String category;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activityLevel;
  final double? bmr;
  final int? dailyCalories;
  final double? idealWeight;
  final double? bodyFat;

  BMIHistoryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.bmi,
    required this.category,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    this.bmr,
    this.dailyCalories,
    this.idealWeight,
    this.bodyFat,
  });

  factory BMIHistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BMIHistoryModel(
      id: documentId,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      bmi: (map['bmi'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      bmr: map['bmr']?.toDouble(),
      dailyCalories: map['dailyCalories'],
      idealWeight: map['idealWeight']?.toDouble(),
      bodyFat: map['bodyFat']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'bmi': bmi,
      'category': category,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'bmr': bmr,
      'dailyCalories': dailyCalories,
      'idealWeight': idealWeight,
      'bodyFat': bodyFat,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get dateFormatted {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get timeFormatted {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
