import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyModel {
  final String id;
  final String userId;
  final DateTime lastPeriodDate; // Last menstrual period (LMP)
  final DateTime dueDate; // Expected delivery date
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? babyName; // Optional baby name
  final String? notes; // Personal notes
  final bool isActive; // Active pregnancy or archived

  PregnancyModel({
    required this.id,
    required this.userId,
    required this.lastPeriodDate,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.babyName,
    this.notes,
    this.isActive = true,
  });

  // Calculate current week (1-42)
  int getCurrentWeek() {
    final daysSinceLMP = DateTime.now().difference(lastPeriodDate).inDays;
    return (daysSinceLMP / 7).floor() + 1;
  }

  // Calculate days remaining until due date
  int getDaysRemaining() {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Calculate pregnancy progress percentage
  double getProgressPercentage() {
    final totalDays = dueDate.difference(lastPeriodDate).inDays;
    final daysPassed = DateTime.now().difference(lastPeriodDate).inDays;
    return (daysPassed / totalDays * 100).clamp(0, 100);
  }

  // Get trimester (1, 2, or 3)
  int getTrimester() {
    final week = getCurrentWeek();
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  // Get trimester name in English
  String getTrimesterNameEN() {
    final trimester = getTrimester();
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return '';
    }
  }

  // Get trimester name in Bangla
  String getTrimesterNameBN() {
    final trimester = getTrimester();
    switch (trimester) {
      case 1:
        return 'প্রথম ত্রৈমাসিক';
      case 2:
        return 'দ্বিতীয় ত্রৈমাসিক';
      case 3:
        return 'তৃতীয় ত্রৈমাসিক';
      default:
        return '';
    }
  }

  factory PregnancyModel.fromMap(Map<String, dynamic> map, String id) {
    return PregnancyModel(
      id: id,
      userId: map['userId'] ?? '',
      lastPeriodDate: (map['lastPeriodDate'] as Timestamp).toDate(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      babyName: map['babyName'],
      notes: map['notes'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'babyName': babyName,
      'notes': notes,
      'isActive': isActive,
    };
  }

  PregnancyModel copyWith({
    String? id,
    String? userId,
    DateTime? lastPeriodDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? babyName,
    String? notes,
    bool? isActive,
  }) {
    return PregnancyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      babyName: babyName ?? this.babyName,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
