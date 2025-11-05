// lib/src/models/drug_interaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a drug interaction between two medicines
class DrugInteraction {
  final String id;
  final String medicine1;
  final String medicine2;
  final String severity; // 'minor', 'moderate', 'major'
  final String description;
  final String recommendation;
  final DateTime timestamp;

  DrugInteraction({
    required this.id,
    required this.medicine1,
    required this.medicine2,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.timestamp,
  });

  /// Create from Firestore document
  factory DrugInteraction.fromMap(Map<String, dynamic> map) {
    return DrugInteraction(
      id: map['id'] ?? '',
      medicine1: map['medicine1'] ?? '',
      medicine2: map['medicine2'] ?? '',
      severity: map['severity'] ?? 'moderate',
      description: map['description'] ?? '',
      recommendation: map['recommendation'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine1': medicine1,
      'medicine2': medicine2,
      'severity': severity,
      'description': description,
      'recommendation': recommendation,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Copy with modifications
  DrugInteraction copyWith({
    String? id,
    String? medicine1,
    String? medicine2,
    String? severity,
    String? description,
    String? recommendation,
    DateTime? timestamp,
  }) {
    return DrugInteraction(
      id: id ?? this.id,
      medicine1: medicine1 ?? this.medicine1,
      medicine2: medicine2 ?? this.medicine2,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Get severity level as integer (1=minor, 2=moderate, 3=major)
  int get severityLevel {
    switch (severity.toLowerCase()) {
      case 'major':
        return 3;
      case 'moderate':
        return 2;
      case 'minor':
        return 1;
      default:
        return 2;
    }
  }

  /// Check if this is a major (dangerous) interaction
  bool get isMajor => severity.toLowerCase() == 'major';

  /// Check if this is a moderate interaction
  bool get isModerate => severity.toLowerCase() == 'moderate';

  /// Check if this is a minor interaction
  bool get isMinor => severity.toLowerCase() == 'minor';

  /// Get color for this severity level
  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'major':
        return '#F44336'; // Red
      case 'moderate':
        return '#FF9800'; // Orange
      case 'minor':
        return '#FFC107'; // Amber
      default:
        return '#FF9800';
    }
  }

  /// Get icon name for this severity level
  String get severityIcon {
    switch (severity.toLowerCase()) {
      case 'major':
        return 'error'; // Error icon
      case 'moderate':
        return 'warning'; // Warning icon
      case 'minor':
        return 'info'; // Info icon
      default:
        return 'warning';
    }
  }

  @override
  String toString() {
    return 'DrugInteraction{$medicine1 + $medicine2: $severity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrugInteraction &&
        other.id == id &&
        other.medicine1 == medicine1 &&
        other.medicine2 == medicine2;
  }

  @override
  int get hashCode => id.hashCode ^ medicine1.hashCode ^ medicine2.hashCode;
}

/// Represents detailed medicine information
class MedicineInfo {
  final String name;
  final String? genericName;
  final String? description;
  final List<String> commonUses;
  final List<String> sideEffects;
  final List<String> precautions;
  final String? dosageInfo;
  final String? category;

  MedicineInfo({
    required this.name,
    this.genericName,
    this.description,
    this.commonUses = const [],
    this.sideEffects = const [],
    this.precautions = const [],
    this.dosageInfo,
    this.category,
  });

  factory MedicineInfo.fromMap(Map<String, dynamic> map) {
    return MedicineInfo(
      name: map['name'] ?? '',
      genericName: map['generic_name'],
      description: map['description'],
      commonUses: List<String>.from(map['common_uses'] ?? []),
      sideEffects: List<String>.from(map['side_effects'] ?? []),
      precautions: List<String>.from(map['precautions'] ?? []),
      dosageInfo: map['dosage_info'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'generic_name': genericName,
      'description': description,
      'common_uses': commonUses,
      'side_effects': sideEffects,
      'precautions': precautions,
      'dosage_info': dosageInfo,
      'category': category,
    };
  }
}
