import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for blood glucose readings
/// Tracks glucose levels with measurement context
class GlucoseLog {
  final String id;
  final String userId;
  final double glucose; // mg/dL
  final String measurementType; // 'fasting', 'random', 'post-meal'
  final String? mealContext; // 'before-breakfast', 'after-lunch', etc.
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;

  GlucoseLog({
    required this.id,
    required this.userId,
    required this.glucose,
    required this.measurementType,
    this.mealContext,
    required this.timestamp,
    this.notes,
    required this.createdAt,
  });

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'glucose': glucose,
      'measurementType': measurementType,
      'mealContext': mealContext,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory GlucoseLog.fromMap(String id, Map<String, dynamic> map) {
    return GlucoseLog(
      id: id,
      userId: map['userId'] as String,
      glucose: (map['glucose'] as num).toDouble(),
      measurementType: map['measurementType'] as String,
      mealContext: map['mealContext'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with optional field updates
  GlucoseLog copyWith({
    String? id,
    String? userId,
    double? glucose,
    String? measurementType,
    String? mealContext,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
  }) {
    return GlucoseLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      glucose: glucose ?? this.glucose,
      measurementType: measurementType ?? this.measurementType,
      mealContext: mealContext ?? this.mealContext,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if fasting glucose is normal (< 100 mg/dL)
  bool get isFastingNormal => measurementType == 'fasting' && glucose < 100;

  /// Check if fasting glucose is prediabetic (100-125 mg/dL)
  bool get isFastingPrediabetic =>
      measurementType == 'fasting' && glucose >= 100 && glucose <= 125;

  /// Check if fasting glucose is diabetic (>= 126 mg/dL)
  bool get isFastingDiabetic => measurementType == 'fasting' && glucose >= 126;

  /// Check if random glucose is normal (< 140 mg/dL)
  bool get isRandomNormal =>
      (measurementType == 'random' || measurementType == 'post-meal') &&
      glucose < 140;

  /// Check if random glucose is prediabetic (140-199 mg/dL)
  bool get isRandomPrediabetic =>
      (measurementType == 'random' || measurementType == 'post-meal') &&
      glucose >= 140 &&
      glucose < 200;

  /// Check if random glucose is diabetic (>= 200 mg/dL)
  bool get isRandomDiabetic =>
      (measurementType == 'random' || measurementType == 'post-meal') &&
      glucose >= 200;

  /// Get glucose level category as string
  String get category {
    if (measurementType == 'fasting') {
      if (isFastingDiabetic) return 'High (Diabetic)';
      if (isFastingPrediabetic) return 'Elevated (Prediabetic)';
      return 'Normal';
    } else {
      if (isRandomDiabetic) return 'High (Diabetic)';
      if (isRandomPrediabetic) return 'Elevated (Prediabetic)';
      return 'Normal';
    }
  }

  /// Get category color
  /// Returns MaterialColor value as int
  int get categoryColor {
    if (measurementType == 'fasting') {
      if (isFastingDiabetic) return 0xFFD32F2F; // Red 700
      if (isFastingPrediabetic) return 0xFFFFA726; // Orange 400
      return 0xFF4CAF50; // Green 500
    } else {
      if (isRandomDiabetic) return 0xFFD32F2F; // Red 700
      if (isRandomPrediabetic) return 0xFFFFA726; // Orange 400
      return 0xFF4CAF50; // Green 500
    }
  }

  /// Get measurement type display name
  String get measurementTypeDisplay {
    switch (measurementType) {
      case 'fasting':
        return 'Fasting';
      case 'random':
        return 'Random';
      case 'post-meal':
        return 'Post-Meal';
      default:
        return measurementType;
    }
  }

  /// Get meal context display name
  String? get mealContextDisplay {
    if (mealContext == null) return null;
    switch (mealContext) {
      case 'before-breakfast':
        return 'Before Breakfast';
      case 'after-breakfast':
        return 'After Breakfast';
      case 'before-lunch':
        return 'Before Lunch';
      case 'after-lunch':
        return 'After Lunch';
      case 'before-dinner':
        return 'Before Dinner';
      case 'after-dinner':
        return 'After Dinner';
      case 'bedtime':
        return 'Bedtime';
      default:
        return mealContext;
    }
  }

  @override
  String toString() {
    return 'GlucoseLog(id: $id, glucose: $glucose, type: $measurementType, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GlucoseLog &&
        other.id == id &&
        other.userId == userId &&
        other.glucose == glucose &&
        other.measurementType == measurementType &&
        other.mealContext == mealContext &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        glucose.hashCode ^
        measurementType.hashCode ^
        mealContext.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }

  /// Static measurement types
  static const List<String> measurementTypes = [
    'fasting',
    'random',
    'post-meal',
  ];

  /// Static meal contexts
  static const List<String> mealContexts = [
    'before-breakfast',
    'after-breakfast',
    'before-lunch',
    'after-lunch',
    'before-dinner',
    'after-dinner',
    'bedtime',
  ];
}
