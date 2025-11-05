// lib/src/models/water_reminder_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WaterReminderModel {
  final String userId;
  final int targetGlasses; // Daily target (default: 8 glasses)
  final int glassSize; // in ml (default: 250ml)
  final List<String> reminderTimes; // ["07:00", "09:00", "11:00", ...]
  final bool isEnabled;
  final int todayIntake; // glasses drunk today
  final DateTime? lastDrinkTime;
  final DateTime lastResetDate; // for midnight reset

  WaterReminderModel({
    required this.userId,
    this.targetGlasses = 8,
    this.glassSize = 250,
    List<String>? reminderTimes,
    this.isEnabled = true,
    this.todayIntake = 0,
    this.lastDrinkTime,
    DateTime? lastResetDate,
  })  : reminderTimes = reminderTimes ??
            [
              "07:00", // Morning wake up
              "09:00", // After breakfast
              "11:00", // Mid-morning
              "13:00", // Before lunch
              "15:00", // After lunch
              "17:00", // Evening
              "19:00", // Before dinner
              "21:00", // Before bed
            ],
        lastResetDate = lastResetDate ?? DateTime.now();

  // Calculate total ml intake today
  int get totalMlToday => todayIntake * glassSize;

  // Calculate target ml
  int get targetMl => targetGlasses * glassSize;

  // Calculate percentage completed
  double get percentageCompleted {
    if (targetGlasses == 0) return 0;
    return (todayIntake / targetGlasses).clamp(0.0, 1.0);
  }

  // Check if needs reset (new day)
  bool needsReset() {
    final now = DateTime.now();
    return now.day != lastResetDate.day ||
        now.month != lastResetDate.month ||
        now.year != lastResetDate.year;
  }

  // Create copy with updated values
  WaterReminderModel copyWith({
    String? userId,
    int? targetGlasses,
    int? glassSize,
    List<String>? reminderTimes,
    bool? isEnabled,
    int? todayIntake,
    DateTime? lastDrinkTime,
    DateTime? lastResetDate,
  }) {
    return WaterReminderModel(
      userId: userId ?? this.userId,
      targetGlasses: targetGlasses ?? this.targetGlasses,
      glassSize: glassSize ?? this.glassSize,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isEnabled: isEnabled ?? this.isEnabled,
      todayIntake: todayIntake ?? this.todayIntake,
      lastDrinkTime: lastDrinkTime ?? this.lastDrinkTime,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetGlasses': targetGlasses,
      'glassSize': glassSize,
      'reminderTimes': reminderTimes,
      'isEnabled': isEnabled,
      'todayIntake': todayIntake,
      'lastDrinkTime': lastDrinkTime?.toIso8601String(),
      'lastResetDate': Timestamp.fromDate(lastResetDate),
    };
  }

  // Create from Firestore map
  factory WaterReminderModel.fromMap(Map<String, dynamic> map) {
    return WaterReminderModel(
      userId: map['userId'] ?? '',
      targetGlasses: map['targetGlasses'] ?? 8,
      glassSize: map['glassSize'] ?? 250,
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      isEnabled: map['isEnabled'] ?? true,
      todayIntake: map['todayIntake'] ?? 0,
      lastDrinkTime: map['lastDrinkTime'] != null
          ? DateTime.parse(map['lastDrinkTime'])
          : null,
      lastResetDate: (map['lastResetDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}

// Model for water intake history
class WaterIntakeHistory {
  final String id;
  final String userId;
  final DateTime date;
  final int glassesCount;
  final int totalMl;
  final int targetGlasses;
  final double percentage;

  WaterIntakeHistory({
    required this.id,
    required this.userId,
    required this.date,
    required this.glassesCount,
    required this.totalMl,
    required this.targetGlasses,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'glassesCount': glassesCount,
      'totalMl': totalMl,
      'targetGlasses': targetGlasses,
      'percentage': percentage,
    };
  }

  factory WaterIntakeHistory.fromMap(String id, Map<String, dynamic> map) {
    return WaterIntakeHistory(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      glassesCount: map['glassesCount'] ?? 0,
      totalMl: map['totalMl'] ?? 0,
      targetGlasses: map['targetGlasses'] ?? 8,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
    );
  }
}
