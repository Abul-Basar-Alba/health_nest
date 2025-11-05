import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for blood pressure readings
/// Tracks systolic, diastolic, and pulse measurements
class BloodPressureLog {
  final String id;
  final String userId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;

  BloodPressureLog({
    required this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.timestamp,
    this.notes,
    required this.createdAt,
  });

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory BloodPressureLog.fromMap(String id, Map<String, dynamic> map) {
    return BloodPressureLog(
      id: id,
      userId: map['userId'] as String,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      pulse: map['pulse'] as int,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with optional field updates
  BloodPressureLog copyWith({
    String? id,
    String? userId,
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
  }) {
    return BloodPressureLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if blood pressure is in normal range
  /// Normal: Systolic < 120 AND Diastolic < 80
  bool get isNormal => systolic < 120 && diastolic < 80;

  /// Check if blood pressure is elevated
  /// Elevated: Systolic 120-129 AND Diastolic < 80
  bool get isElevated => systolic >= 120 && systolic <= 129 && diastolic < 80;

  /// Check if blood pressure is high (Stage 1 Hypertension)
  /// Stage 1: Systolic 130-139 OR Diastolic 80-89
  bool get isHighStage1 =>
      (systolic >= 130 && systolic <= 139) ||
      (diastolic >= 80 && diastolic <= 89);

  /// Check if blood pressure is high (Stage 2 Hypertension)
  /// Stage 2: Systolic >= 140 OR Diastolic >= 90
  bool get isHighStage2 => systolic >= 140 || diastolic >= 90;

  /// Get blood pressure category as string
  String get category {
    if (isHighStage2) return 'High (Stage 2)';
    if (isHighStage1) return 'High (Stage 1)';
    if (isElevated) return 'Elevated';
    return 'Normal';
  }

  /// Get category color
  /// Returns MaterialColor value as int
  int get categoryColor {
    if (isHighStage2) return 0xFFD32F2F; // Red 700
    if (isHighStage1) return 0xFFF57C00; // Orange 700
    if (isElevated) return 0xFFFFA726; // Orange 400
    return 0xFF4CAF50; // Green 500
  }

  @override
  String toString() {
    return 'BloodPressureLog(id: $id, systolic: $systolic, diastolic: $diastolic, pulse: $pulse, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BloodPressureLog &&
        other.id == id &&
        other.userId == userId &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.pulse == pulse &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        systolic.hashCode ^
        diastolic.hashCode ^
        pulse.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}
