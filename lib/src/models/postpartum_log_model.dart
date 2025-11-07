// lib/src/models/postpartum_log_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum PostpartumLogType {
  breastfeeding,
  bottleFeeding,
  pumping,
  diaper,
  sleep,
  mood,
  pain,
  bleeding,
  medication,
  exercise,
  note,
}

class PostpartumLogModel {
  final String id;
  final String userId;
  final String pregnancyId;
  final PostpartumLogType type;
  final DateTime logDate;
  final String? notes;

  // Feeding specific
  final String? feedingSide; // 'left', 'right', 'both' for breastfeeding
  final int? feedingDuration; // in minutes
  final double? bottleAmount; // in ml

  // Diaper specific
  final String? diaperType; // 'wet', 'dirty', 'both'

  // Sleep specific
  final DateTime? sleepStartTime;
  final DateTime? sleepEndTime;

  // Mood specific
  final int? moodRating; // 1-5 scale
  final List<String> moodTags; // 'happy', 'sad', 'anxious', 'tired', etc.

  // Pain specific
  final String?
      painLocation; // 'incision', 'perineum', 'breast', 'back', 'other'
  final int? painLevel; // 1-10 scale

  // Bleeding specific
  final String? bleedingLevel; // 'light', 'moderate', 'heavy'

  // Medication specific
  final String? medicationName;
  final String? medicationDosage;

  final DateTime createdAt;

  PostpartumLogModel({
    required this.id,
    required this.userId,
    required this.pregnancyId,
    required this.type,
    required this.logDate,
    this.notes,
    this.feedingSide,
    this.feedingDuration,
    this.bottleAmount,
    this.diaperType,
    this.sleepStartTime,
    this.sleepEndTime,
    this.moodRating,
    this.moodTags = const [],
    this.painLocation,
    this.painLevel,
    this.bleedingLevel,
    this.medicationName,
    this.medicationDosage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pregnancyId': pregnancyId,
      'type': type.name,
      'logDate': Timestamp.fromDate(logDate),
      'notes': notes,
      'feedingSide': feedingSide,
      'feedingDuration': feedingDuration,
      'bottleAmount': bottleAmount,
      'diaperType': diaperType,
      'sleepStartTime':
          sleepStartTime != null ? Timestamp.fromDate(sleepStartTime!) : null,
      'sleepEndTime':
          sleepEndTime != null ? Timestamp.fromDate(sleepEndTime!) : null,
      'moodRating': moodRating,
      'moodTags': moodTags,
      'painLocation': painLocation,
      'painLevel': painLevel,
      'bleedingLevel': bleedingLevel,
      'medicationName': medicationName,
      'medicationDosage': medicationDosage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory PostpartumLogModel.fromMap(Map<String, dynamic> map) {
    return PostpartumLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      pregnancyId: map['pregnancyId'] ?? '',
      type: PostpartumLogType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PostpartumLogType.note,
      ),
      logDate: (map['logDate'] as Timestamp).toDate(),
      notes: map['notes'],
      feedingSide: map['feedingSide'],
      feedingDuration: map['feedingDuration'],
      bottleAmount: map['bottleAmount']?.toDouble(),
      diaperType: map['diaperType'],
      sleepStartTime: map['sleepStartTime'] != null
          ? (map['sleepStartTime'] as Timestamp).toDate()
          : null,
      sleepEndTime: map['sleepEndTime'] != null
          ? (map['sleepEndTime'] as Timestamp).toDate()
          : null,
      moodRating: map['moodRating'],
      moodTags: List<String>.from(map['moodTags'] ?? []),
      painLocation: map['painLocation'],
      painLevel: map['painLevel'],
      bleedingLevel: map['bleedingLevel'],
      medicationName: map['medicationName'],
      medicationDosage: map['medicationDosage'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Copy with method
  PostpartumLogModel copyWith({
    String? id,
    String? userId,
    String? pregnancyId,
    PostpartumLogType? type,
    DateTime? logDate,
    String? notes,
    String? feedingSide,
    int? feedingDuration,
    double? bottleAmount,
    String? diaperType,
    DateTime? sleepStartTime,
    DateTime? sleepEndTime,
    int? moodRating,
    List<String>? moodTags,
    String? painLocation,
    int? painLevel,
    String? bleedingLevel,
    String? medicationName,
    String? medicationDosage,
    DateTime? createdAt,
  }) {
    return PostpartumLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      type: type ?? this.type,
      logDate: logDate ?? this.logDate,
      notes: notes ?? this.notes,
      feedingSide: feedingSide ?? this.feedingSide,
      feedingDuration: feedingDuration ?? this.feedingDuration,
      bottleAmount: bottleAmount ?? this.bottleAmount,
      diaperType: diaperType ?? this.diaperType,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      moodRating: moodRating ?? this.moodRating,
      moodTags: moodTags ?? this.moodTags,
      painLocation: painLocation ?? this.painLocation,
      painLevel: painLevel ?? this.painLevel,
      bleedingLevel: bleedingLevel ?? this.bleedingLevel,
      medicationName: medicationName ?? this.medicationName,
      medicationDosage: medicationDosage ?? this.medicationDosage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  String get formattedDate {
    return '${logDate.day}/${logDate.month}/${logDate.year}';
  }

  String get formattedTime {
    final hour = logDate.hour.toString().padLeft(2, '0');
    final minute = logDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  // Sleep duration in minutes
  int? get sleepDuration {
    if (sleepStartTime == null || sleepEndTime == null) return null;
    return sleepEndTime!.difference(sleepStartTime!).inMinutes;
  }

  String? get formattedSleepDuration {
    final duration = sleepDuration;
    if (duration == null) return null;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Type names
  static const Map<PostpartumLogType, String> typeNamesEN = {
    PostpartumLogType.breastfeeding: 'Breastfeeding',
    PostpartumLogType.bottleFeeding: 'Bottle Feeding',
    PostpartumLogType.pumping: 'Pumping',
    PostpartumLogType.diaper: 'Diaper Change',
    PostpartumLogType.sleep: 'Sleep',
    PostpartumLogType.mood: 'Mood',
    PostpartumLogType.pain: 'Pain',
    PostpartumLogType.bleeding: 'Bleeding',
    PostpartumLogType.medication: 'Medication',
    PostpartumLogType.exercise: 'Exercise',
    PostpartumLogType.note: 'Note',
  };

  static const Map<PostpartumLogType, String> typeNamesBN = {
    PostpartumLogType.breastfeeding: 'স্তন্যপান',
    PostpartumLogType.bottleFeeding: 'বোতল খাওয়ানো',
    PostpartumLogType.pumping: 'পাম্পিং',
    PostpartumLogType.diaper: 'ডায়াপার পরিবর্তন',
    PostpartumLogType.sleep: 'ঘুম',
    PostpartumLogType.mood: 'মেজাজ',
    PostpartumLogType.pain: 'ব্যথা',
    PostpartumLogType.bleeding: 'রক্তপাত',
    PostpartumLogType.medication: 'ওষুধ',
    PostpartumLogType.exercise: 'ব্যায়াম',
    PostpartumLogType.note: 'নোট',
  };

  String getTypeName(bool isBangla) {
    return isBangla
        ? (typeNamesBN[type] ?? type.name)
        : (typeNamesEN[type] ?? type.name);
  }

  // Icon for each type
  static const Map<PostpartumLogType, String> typeIcons = {
    PostpartumLogType.breastfeeding: '🤱',
    PostpartumLogType.bottleFeeding: '🍼',
    PostpartumLogType.pumping: '💧',
    PostpartumLogType.diaper: '👶',
    PostpartumLogType.sleep: '😴',
    PostpartumLogType.mood: '😊',
    PostpartumLogType.pain: '😣',
    PostpartumLogType.bleeding: '🩸',
    PostpartumLogType.medication: '💊',
    PostpartumLogType.exercise: '🏃',
    PostpartumLogType.note: '📝',
  };

  String get icon => typeIcons[type] ?? '📝';
}
