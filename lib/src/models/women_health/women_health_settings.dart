// lib/src/models/women_health/women_health_settings.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WomenHealthSettings {
  final String userId;
  final bool isPillTrackingEnabled;
  final int averageCycleLength; // days
  final int averagePeriodLength; // days
  final DateTime? lastPeriodStart;
  final String? pillName;
  final List<String> pillReminders; // Times as strings "09:00"
  final bool discreteMode; // Hide sensitive info in notifications
  final bool fertilityTrackingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  WomenHealthSettings({
    required this.userId,
    this.isPillTrackingEnabled = false,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.lastPeriodStart,
    this.pillName,
    this.pillReminders = const [],
    this.discreteMode = false,
    this.fertilityTrackingEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Predict next period start date
  DateTime? get predictedNextPeriod {
    if (lastPeriodStart == null) return null;
    return lastPeriodStart!.add(Duration(days: averageCycleLength));
  }

  // Days until next period
  int? get daysUntilNextPeriod {
    final next = predictedNextPeriod;
    if (next == null) return null;
    return next.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isPillTrackingEnabled': isPillTrackingEnabled,
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'lastPeriodStart':
          lastPeriodStart != null ? Timestamp.fromDate(lastPeriodStart!) : null,
      'pillName': pillName,
      'pillReminders': pillReminders,
      'discreteMode': discreteMode,
      'fertilityTrackingEnabled': fertilityTrackingEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WomenHealthSettings.fromMap(Map<String, dynamic> map) {
    return WomenHealthSettings(
      userId: map['userId'] ?? '',
      isPillTrackingEnabled: map['isPillTrackingEnabled'] ?? false,
      averageCycleLength: map['averageCycleLength'] ?? 28,
      averagePeriodLength: map['averagePeriodLength'] ?? 5,
      lastPeriodStart: map['lastPeriodStart'] != null
          ? (map['lastPeriodStart'] as Timestamp).toDate()
          : null,
      pillName: map['pillName'],
      pillReminders: List<String>.from(map['pillReminders'] ?? []),
      discreteMode: map['discreteMode'] ?? false,
      fertilityTrackingEnabled: map['fertilityTrackingEnabled'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  WomenHealthSettings copyWith({
    String? userId,
    bool? isPillTrackingEnabled,
    int? averageCycleLength,
    int? averagePeriodLength,
    DateTime? lastPeriodStart,
    String? pillName,
    List<String>? pillReminders,
    bool? discreteMode,
    bool? fertilityTrackingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WomenHealthSettings(
      userId: userId ?? this.userId,
      isPillTrackingEnabled:
          isPillTrackingEnabled ?? this.isPillTrackingEnabled,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      pillName: pillName ?? this.pillName,
      pillReminders: pillReminders ?? this.pillReminders,
      discreteMode: discreteMode ?? this.discreteMode,
      fertilityTrackingEnabled:
          fertilityTrackingEnabled ?? this.fertilityTrackingEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
