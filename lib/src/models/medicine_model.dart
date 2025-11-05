// lib/src/models/medicine_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  final String id;
  final String userId;
  final String medicineName;
  final String dosage; // e.g., "1 tablet", "2 spoons"
  final String frequency; // daily, weekly, custom, interval
  final List<String> scheduledTimes; // ["08:00", "20:00"]
  final List<int>? weekDays; // [1,3,5] for Mon, Wed, Fri (null if daily)
  final int? intervalHours; // For "every X hours" frequency
  final DateTime startDate;
  final DateTime? endDate;
  final int? stockCount;
  final int? refillThreshold; // Alert when stock < this
  final String? instructions; // "After meal", "With water"
  final String? medicineType; // Tablet, Syrup, Injection, etc.
  final bool isActive;
  final DateTime createdAt;
  final DateTime? prescriptionExpiryDate; // Prescription expiry
  final int? renewalReminderDays; // Remind X days before expiry

  MedicineModel({
    required this.id,
    required this.userId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.scheduledTimes,
    this.weekDays,
    this.intervalHours,
    required this.startDate,
    this.endDate,
    this.stockCount,
    this.refillThreshold,
    this.instructions,
    this.medicineType,
    this.isActive = true,
    DateTime? createdAt,
    this.prescriptionExpiryDate,
    this.renewalReminderDays,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if medicine should be taken today
  bool shouldTakeToday() {
    final now = DateTime.now();

    // Check date range
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    // Check frequency
    if (frequency == 'daily') return true;
    if (frequency == 'weekly' && weekDays != null) {
      return weekDays!.contains(now.weekday);
    }
    // For interval frequency, always return true since it's time-based, not day-based
    if (frequency == 'interval' && intervalHours != null) {
      return true;
    }

    return true;
  }

  // Check if stock is low
  bool isStockLow() {
    if (stockCount == null || refillThreshold == null) return false;
    return stockCount! <= refillThreshold!;
  }

  // Check if prescription needs renewal
  bool needsRenewal() {
    if (prescriptionExpiryDate == null) return false;
    final daysUntilExpiry =
        prescriptionExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= (renewalReminderDays ?? 7) &&
        daysUntilExpiry >= 0;
  }

  // Check if prescription expired
  bool isPrescriptionExpired() {
    if (prescriptionExpiryDate == null) return false;
    return DateTime.now().isAfter(prescriptionExpiryDate!);
  }

  // Copy with
  MedicineModel copyWith({
    String? id,
    String? userId,
    String? medicineName,
    String? dosage,
    String? frequency,
    List<String>? scheduledTimes,
    List<int>? weekDays,
    int? intervalHours,
    DateTime? startDate,
    DateTime? endDate,
    int? stockCount,
    int? refillThreshold,
    String? instructions,
    String? medicineType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? prescriptionExpiryDate,
    int? renewalReminderDays,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      weekDays: weekDays ?? this.weekDays,
      intervalHours: intervalHours ?? this.intervalHours,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      stockCount: stockCount ?? this.stockCount,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      instructions: instructions ?? this.instructions,
      medicineType: medicineType ?? this.medicineType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      prescriptionExpiryDate:
          prescriptionExpiryDate ?? this.prescriptionExpiryDate,
      renewalReminderDays: renewalReminderDays ?? this.renewalReminderDays,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'scheduledTimes': scheduledTimes,
      'weekDays': weekDays,
      'intervalHours': intervalHours,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'stockCount': stockCount,
      'refillThreshold': refillThreshold,
      'instructions': instructions,
      'medicineType': medicineType,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'prescriptionExpiryDate': prescriptionExpiryDate != null
          ? Timestamp.fromDate(prescriptionExpiryDate!)
          : null,
      'renewalReminderDays': renewalReminderDays,
    };
  }

  // From Firestore
  factory MedicineModel.fromMap(String id, Map<String, dynamic> map) {
    return MedicineModel(
      id: id,
      userId: map['userId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'daily',
      scheduledTimes: List<String>.from(map['scheduledTimes'] ?? []),
      weekDays:
          map['weekDays'] != null ? List<int>.from(map['weekDays']) : null,
      intervalHours: map['intervalHours'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      stockCount: map['stockCount'],
      refillThreshold: map['refillThreshold'],
      instructions: map['instructions'],
      medicineType: map['medicineType'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      prescriptionExpiryDate: map['prescriptionExpiryDate'] != null
          ? (map['prescriptionExpiryDate'] as Timestamp).toDate()
          : null,
      renewalReminderDays: map['renewalReminderDays'],
    );
  }
}

// Medicine Intake Log Model
class MedicineIntakeLog {
  final String id;
  final String medicineId;
  final String userId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status; // taken, missed, snoozed, skipped
  final String? note;

  MedicineIntakeLog({
    required this.id,
    required this.medicineId,
    required this.userId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'userId': userId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status,
      'note': note,
    };
  }

  factory MedicineIntakeLog.fromMap(String id, Map<String, dynamic> map) {
    return MedicineIntakeLog(
      id: id,
      medicineId: map['medicineId'] ?? '',
      userId: map['userId'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      takenTime: map['takenTime'] != null
          ? (map['takenTime'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'missed',
      note: map['note'],
    );
  }
}
