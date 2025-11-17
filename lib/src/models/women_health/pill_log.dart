// lib/src/models/women_health/pill_log.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PillLog {
  final String id;
  final String userId;
  final String pillName;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool isTaken;
  final bool isMissed;
  final String? notes;
  final DateTime createdAt;

  PillLog({
    required this.id,
    required this.userId,
    required this.pillName,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
    this.isMissed = false,
    this.notes,
    required this.createdAt,
  });

  // Check if pill is overdue
  bool get isOverdue {
    if (isTaken) return false;
    return DateTime.now().isAfter(scheduledTime.add(const Duration(hours: 2)));
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pillName': pillName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'isTaken': isTaken,
      'isMissed': isMissed,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PillLog.fromMap(String id, Map<String, dynamic> map) {
    return PillLog(
      id: id,
      userId: map['userId'] ?? '',
      pillName: map['pillName'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      takenTime: map['takenTime'] != null
          ? (map['takenTime'] as Timestamp).toDate()
          : null,
      isTaken: map['isTaken'] ?? false,
      isMissed: map['isMissed'] ?? false,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  PillLog copyWith({
    String? id,
    String? userId,
    String? pillName,
    DateTime? scheduledTime,
    DateTime? takenTime,
    bool? isTaken,
    bool? isMissed,
    String? notes,
    DateTime? createdAt,
  }) {
    return PillLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pillName: pillName ?? this.pillName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      isTaken: isTaken ?? this.isTaken,
      isMissed: isMissed ?? this.isMissed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
