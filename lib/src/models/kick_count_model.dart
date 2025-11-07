import 'package:cloud_firestore/cloud_firestore.dart';

class KickCountModel {
  final String id;
  final String pregnancyId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int kickCount;
  final int durationMinutes; // Time to reach 10 kicks
  final DateTime createdAt;

  KickCountModel({
    required this.id,
    required this.pregnancyId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.kickCount,
    required this.durationMinutes,
    required this.createdAt,
  });

  // Check if session is complete (reached 10 kicks)
  bool isComplete() => kickCount >= 10;

  // Get duration in human-readable format
  String getDurationText() {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  // Get duration in Bangla
  String getDurationTextBN() {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0) {
      return '$hours ঘন্টা $minutes মিনিট';
    }
    return '$minutes মিনিট';
  }

  // Check if duration is within normal range (usually < 2 hours for 10 kicks)
  bool isNormalDuration() => durationMinutes <= 120;

  factory KickCountModel.fromMap(Map<String, dynamic> map, String id) {
    return KickCountModel(
      id: id,
      pregnancyId: map['pregnancyId'] ?? '',
      userId: map['userId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      kickCount: map['kickCount'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pregnancyId': pregnancyId,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'kickCount': kickCount,
      'durationMinutes': durationMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  KickCountModel copyWith({
    String? id,
    String? pregnancyId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? kickCount,
    int? durationMinutes,
    DateTime? createdAt,
  }) {
    return KickCountModel(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      kickCount: kickCount ?? this.kickCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
