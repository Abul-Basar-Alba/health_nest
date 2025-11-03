// lib/src/models/sleep_schedule_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SleepScheduleModel {
  final String id;
  final String userId;
  final DateTime bedtime; // e.g., 23:00
  final DateTime wakeTime; // e.g., 07:00
  final bool notificationsEnabled;
  final bool bedtimeReminderEnabled;
  final bool wakeUpAlarmEnabled;
  final int reminderMinutesBefore; // Reminder X minutes before bedtime
  final List<String> activeDays; // ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  final DateTime createdAt;
  final DateTime updatedAt;

  SleepScheduleModel({
    required this.id,
    required this.userId,
    required this.bedtime,
    required this.wakeTime,
    this.notificationsEnabled = true,
    this.bedtimeReminderEnabled = true,
    this.wakeUpAlarmEnabled = true,
    this.reminderMinutesBefore = 15,
    required this.activeDays,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate sleep duration in hours
  double get sleepDuration {
    int totalMinutes;
    if (wakeTime.isAfter(bedtime)) {
      // Same day (unusual but possible)
      totalMinutes = wakeTime.difference(bedtime).inMinutes;
    } else {
      // Next day (normal case: 23:00 to 07:00)
      final nextDayWake = DateTime(
        bedtime.year,
        bedtime.month,
        bedtime.day + 1,
        wakeTime.hour,
        wakeTime.minute,
      );
      totalMinutes = nextDayWake.difference(bedtime).inMinutes;
    }
    return totalMinutes / 60.0;
  }

  // Get formatted bedtime string
  String get formattedBedtime {
    final hour = bedtime.hour.toString().padLeft(2, '0');
    final minute = bedtime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get formatted wake time string
  String get formattedWakeTime {
    final hour = wakeTime.hour.toString().padLeft(2, '0');
    final minute = wakeTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bedtime': Timestamp.fromDate(bedtime),
      'wakeTime': Timestamp.fromDate(wakeTime),
      'notificationsEnabled': notificationsEnabled,
      'bedtimeReminderEnabled': bedtimeReminderEnabled,
      'wakeUpAlarmEnabled': wakeUpAlarmEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'activeDays': activeDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory SleepScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SleepScheduleModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bedtime: (data['bedtime'] as Timestamp).toDate(),
      wakeTime: (data['wakeTime'] as Timestamp).toDate(),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      bedtimeReminderEnabled: data['bedtimeReminderEnabled'] ?? true,
      wakeUpAlarmEnabled: data['wakeUpAlarmEnabled'] ?? true,
      reminderMinutesBefore: data['reminderMinutesBefore'] ?? 15,
      activeDays: List<String>.from(data['activeDays'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with modifications
  SleepScheduleModel copyWith({
    String? id,
    String? userId,
    DateTime? bedtime,
    DateTime? wakeTime,
    bool? notificationsEnabled,
    bool? bedtimeReminderEnabled,
    bool? wakeUpAlarmEnabled,
    int? reminderMinutesBefore,
    List<String>? activeDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bedtimeReminderEnabled: bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
      wakeUpAlarmEnabled: wakeUpAlarmEnabled ?? this.wakeUpAlarmEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      activeDays: activeDays ?? this.activeDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
