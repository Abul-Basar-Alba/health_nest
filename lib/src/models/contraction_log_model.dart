import 'package:cloud_firestore/cloud_firestore.dart';

class ContractionLogModel {
  final String id;
  final String pregnancyId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds; // Duration of single contraction
  final int? intervalMinutes; // Time since last contraction
  final String intensity; // low, medium, high
  final DateTime createdAt;

  ContractionLogModel({
    required this.id,
    required this.pregnancyId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.intervalMinutes,
    required this.intensity,
    required this.createdAt,
  });

  // Get duration in seconds
  String getDurationText() {
    return '$durationSeconds sec';
  }

  // Get duration in Bangla
  String getDurationTextBN() {
    return '$durationSeconds সেকেন্ড';
  }

  // Get interval in minutes
  String getIntervalText() {
    if (intervalMinutes == null) return 'N/A';
    return '$intervalMinutes min';
  }

  // Get interval in Bangla
  String getIntervalTextBN() {
    if (intervalMinutes == null) return 'নেই';
    return '$intervalMinutes মিনিট';
  }

  // Check if contraction pattern suggests active labor
  // (Regular contractions 5 min apart, lasting 45-60 sec)
  static bool isActiveLaborPattern(
      List<ContractionLogModel> recentContractions) {
    if (recentContractions.length < 3) return false;

    // Check last 3 contractions
    final last3 = recentContractions.take(3).toList();

    // All should be 45-60 seconds
    final validDuration =
        last3.every((c) => c.durationSeconds >= 45 && c.durationSeconds <= 60);

    // Intervals should be around 5 minutes (4-6 min range)
    final validInterval = last3.every((c) =>
        c.intervalMinutes != null &&
        c.intervalMinutes! >= 4 &&
        c.intervalMinutes! <= 6);

    return validDuration && validInterval;
  }

  // Get intensity text in English
  String getIntensityTextEN() {
    switch (intensity) {
      case 'low':
        return 'Mild';
      case 'medium':
        return 'Moderate';
      case 'high':
        return 'Strong';
      default:
        return intensity;
    }
  }

  // Get intensity text in Bangla
  String getIntensityTextBN() {
    switch (intensity) {
      case 'low':
        return 'হালকা';
      case 'medium':
        return 'মাঝারি';
      case 'high':
        return 'তীব্র';
      default:
        return intensity;
    }
  }

  factory ContractionLogModel.fromMap(Map<String, dynamic> map, String id) {
    return ContractionLogModel(
      id: id,
      pregnancyId: map['pregnancyId'] ?? '',
      userId: map['userId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      durationSeconds: map['durationSeconds'] ?? 0,
      intervalMinutes: map['intervalMinutes'],
      intensity: map['intensity'] ?? 'medium',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pregnancyId': pregnancyId,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationSeconds': durationSeconds,
      'intervalMinutes': intervalMinutes,
      'intensity': intensity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ContractionLogModel copyWith({
    String? id,
    String? pregnancyId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? intervalMinutes,
    String? intensity,
    DateTime? createdAt,
  }) {
    return ContractionLogModel(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
