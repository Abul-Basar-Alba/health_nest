// lib/src/models/doctor_visit_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorVisitModel {
  final String id;
  final String userId;
  final String pregnancyId;
  final DateTime visitDate;
  final String visitType; // checkup, ultrasound, blood-test, etc.
  final String? doctorName;
  final String? clinicName;
  final String? notes;
  final bool isCompleted;
  final bool reminderSet;
  final DateTime? reminderTime;
  final DateTime createdAt;

  DoctorVisitModel({
    required this.id,
    required this.userId,
    required this.pregnancyId,
    required this.visitDate,
    required this.visitType,
    this.doctorName,
    this.clinicName,
    this.notes,
    this.isCompleted = false,
    this.reminderSet = true,
    this.reminderTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pregnancyId': pregnancyId,
      'visitDate': Timestamp.fromDate(visitDate),
      'visitType': visitType,
      'doctorName': doctorName,
      'clinicName': clinicName,
      'notes': notes,
      'isCompleted': isCompleted,
      'reminderSet': reminderSet,
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory DoctorVisitModel.fromMap(Map<String, dynamic> map) {
    return DoctorVisitModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      pregnancyId: map['pregnancyId'] ?? '',
      visitDate: (map['visitDate'] as Timestamp).toDate(),
      visitType: map['visitType'] ?? '',
      doctorName: map['doctorName'],
      clinicName: map['clinicName'],
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
      reminderSet: map['reminderSet'] ?? true,
      reminderTime: map['reminderTime'] != null
          ? (map['reminderTime'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Copy with method
  DoctorVisitModel copyWith({
    String? id,
    String? userId,
    String? pregnancyId,
    DateTime? visitDate,
    String? visitType,
    String? doctorName,
    String? clinicName,
    String? notes,
    bool? isCompleted,
    bool? reminderSet,
    DateTime? reminderTime,
    DateTime? createdAt,
  }) {
    return DoctorVisitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      visitDate: visitDate ?? this.visitDate,
      visitType: visitType ?? this.visitType,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderSet: reminderSet ?? this.reminderSet,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  bool get isPastDue => DateTime.now().isAfter(visitDate) && !isCompleted;
  bool get isUpcoming => DateTime.now().isBefore(visitDate);

  String get formattedDate {
    return '${visitDate.day}/${visitDate.month}/${visitDate.year}';
  }

  String get formattedTime {
    final hour = visitDate.hour > 12 ? visitDate.hour - 12 : visitDate.hour;
    final minute = visitDate.minute.toString().padLeft(2, '0');
    final period = visitDate.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Visit type translations
  static const Map<String, String> visitTypesEN = {
    'checkup': 'Regular Checkup',
    'ultrasound': 'Ultrasound',
    'blood-test': 'Blood Test',
    'glucose-test': 'Glucose Test',
    'vaccination': 'Vaccination',
    'specialist': 'Specialist Consultation',
    'other': 'Other',
  };

  static const Map<String, String> visitTypesBN = {
    'checkup': 'নিয়মিত চেকআপ',
    'ultrasound': 'আল্ট্রাসাউন্ড',
    'blood-test': 'রক্ত পরীক্ষা',
    'glucose-test': 'গ্লুকোজ টেস্ট',
    'vaccination': 'টিকা',
    'specialist': 'বিশেষজ্ঞ পরামর্শ',
    'other': 'অন্যান্য',
  };

  String getVisitTypeName(bool isBangla) {
    return isBangla
        ? visitTypesBN[visitType] ?? visitType
        : visitTypesEN[visitType] ?? visitType;
  }
}
