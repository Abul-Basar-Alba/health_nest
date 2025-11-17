// lib/src/models/women_health/cycle_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CycleEntry {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int flowLevel; // 1-5 (light to heavy)
  final List<String> symptoms;
  final String? notes;
  final DateTime createdAt;

  CycleEntry({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flowLevel = 3,
    this.symptoms = const [],
    this.notes,
    required this.createdAt,
  });

  // Calculate cycle length in days
  int? get cycleLength {
    if (endDate != null) {
      return endDate!.difference(startDate).inDays + 1;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'flowLevel': flowLevel,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CycleEntry.fromMap(String id, Map<String, dynamic> map) {
    return CycleEntry(
      id: id,
      userId: map['userId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      flowLevel: map['flowLevel'] ?? 3,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  CycleEntry copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? flowLevel,
    List<String>? symptoms,
    String? notes,
    DateTime? createdAt,
  }) {
    return CycleEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowLevel: flowLevel ?? this.flowLevel,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
