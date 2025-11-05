import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for weight tracking
/// Tracks weight with BMI calculation support
class WeightLog {
  final String id;
  final String userId;
  final double weight; // in kg
  final double? height; // in cm (optional, for BMI calculation)
  final double? bmi; // calculated from weight and height
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;

  WeightLog({
    required this.id,
    required this.userId,
    required this.weight,
    this.height,
    this.bmi,
    required this.timestamp,
    this.notes,
    required this.createdAt,
  });

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory WeightLog.fromMap(String id, Map<String, dynamic> map) {
    return WeightLog(
      id: id,
      userId: map['userId'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      bmi: map['bmi'] != null ? (map['bmi'] as num).toDouble() : null,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with optional field updates
  WeightLog copyWith({
    String? id,
    String? userId,
    double? weight,
    double? height,
    double? bmi,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
  }) {
    return WeightLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate BMI from weight and height
  /// BMI = weight (kg) / (height (m))^2
  static double? calculateBMI(double? weight, double? height) {
    if (weight == null || height == null || height <= 0) return null;
    final heightInMeters = height / 100; // Convert cm to m
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get calculated BMI (if height is available)
  double? get calculatedBMI {
    if (bmi != null) return bmi;
    return calculateBMI(weight, height);
  }

  /// Check if BMI is underweight (< 18.5)
  bool get isUnderweight {
    final bmiValue = calculatedBMI;
    return bmiValue != null && bmiValue < 18.5;
  }

  /// Check if BMI is normal (18.5-24.9)
  bool get isNormalWeight {
    final bmiValue = calculatedBMI;
    return bmiValue != null && bmiValue >= 18.5 && bmiValue < 25;
  }

  /// Check if BMI is overweight (25-29.9)
  bool get isOverweight {
    final bmiValue = calculatedBMI;
    return bmiValue != null && bmiValue >= 25 && bmiValue < 30;
  }

  /// Check if BMI is obese (>= 30)
  bool get isObese {
    final bmiValue = calculatedBMI;
    return bmiValue != null && bmiValue >= 30;
  }

  /// Get BMI category as string
  String get bmiCategory {
    if (calculatedBMI == null) return 'Unknown';
    if (isObese) return 'Obese';
    if (isOverweight) return 'Overweight';
    if (isNormalWeight) return 'Normal';
    if (isUnderweight) return 'Underweight';
    return 'Unknown';
  }

  /// Get BMI category color
  /// Returns MaterialColor value as int
  int get bmiCategoryColor {
    if (calculatedBMI == null) return 0xFF9E9E9E; // Grey 500
    if (isObese) return 0xFFD32F2F; // Red 700
    if (isOverweight) return 0xFFFFA726; // Orange 400
    if (isNormalWeight) return 0xFF4CAF50; // Green 500
    if (isUnderweight) return 0xFF42A5F5; // Blue 400
    return 0xFF9E9E9E; // Grey 500
  }

  /// Get weight in pounds
  double get weightInPounds => weight * 2.20462;

  /// Get height in inches
  double? get heightInInches => height != null ? height! / 2.54 : null;

  /// Create WeightLog with automatic BMI calculation
  factory WeightLog.withBMI({
    required String id,
    required String userId,
    required double weight,
    double? height,
    required DateTime timestamp,
    String? notes,
    required DateTime createdAt,
  }) {
    return WeightLog(
      id: id,
      userId: userId,
      weight: weight,
      height: height,
      bmi: calculateBMI(weight, height),
      timestamp: timestamp,
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'WeightLog(id: $id, weight: $weight kg, bmi: ${calculatedBMI?.toStringAsFixed(1)}, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeightLog &&
        other.id == id &&
        other.userId == userId &&
        other.weight == weight &&
        other.height == height &&
        other.bmi == bmi &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        weight.hashCode ^
        height.hashCode ^
        bmi.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}
