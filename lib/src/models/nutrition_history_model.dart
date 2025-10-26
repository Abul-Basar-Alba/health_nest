// lib/src/models/nutrition_history_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionHistoryModel {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snacks
  final String foodName;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fats;
  final double? quantity;
  final String? unit; // grams, pieces, cups, etc.
  final String? imageUrl;
  final String? notes;

  NutritionHistoryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.quantity,
    this.unit,
    this.imageUrl,
    this.notes,
  });

  factory NutritionHistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NutritionHistoryModel(
      id: documentId,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      mealType: map['mealType'] ?? '',
      foodName: map['foodName'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein']?.toDouble(),
      carbs: map['carbs']?.toDouble(),
      fats: map['fats']?.toDouble(),
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
      imageUrl: map['imageUrl'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
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

  String get mealTypeEmoji {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '🌞';
      case 'dinner':
        return '🌙';
      case 'snacks':
        return '🍿';
      default:
        return '🍽️';
    }
  }
}
