import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomLogModel {
  final String id;
  final String pregnancyId;
  final String userId;
  final DateTime logDate;
  final List<String> symptoms; // Selected symptoms
  final String severity; // low, medium, high
  final String? notes; // Optional notes
  final DateTime createdAt;

  SymptomLogModel({
    required this.id,
    required this.pregnancyId,
    required this.userId,
    required this.logDate,
    required this.symptoms,
    required this.severity,
    this.notes,
    required this.createdAt,
  });

  // Common pregnancy symptoms in English
  static const List<String> commonSymptomsEN = [
    'Nausea',
    'Fatigue',
    'Headache',
    'Back Pain',
    'Breast Tenderness',
    'Frequent Urination',
    'Mood Swings',
    'Food Cravings',
    'Constipation',
    'Heartburn',
    'Dizziness',
    'Leg Cramps',
    'Shortness of Breath',
    'Swelling',
    'Insomnia',
  ];

  // Common pregnancy symptoms in Bangla
  static const List<String> commonSymptomsBN = [
    'বমি বমি ভাব',
    'ক্লান্তি',
    'মাথাব্যথা',
    'পিঠে ব্যথা',
    'স্তন ব্যথা',
    'ঘন ঘন প্রস্রাব',
    'মেজাজ পরিবর্তন',
    'খাবারের প্রতি আকাঙ্ক্ষা',
    'কোষ্ঠকাঠিন্য',
    'বুক জ্বালাপোড়া',
    'মাথা ঘোরা',
    'পায়ে খিঁচুনি',
    'শ্বাসকষ্ট',
    'ফোলা ভাব',
    'অনিদ্রা',
  ];

  factory SymptomLogModel.fromMap(Map<String, dynamic> map, String id) {
    return SymptomLogModel(
      id: id,
      pregnancyId: map['pregnancyId'] ?? '',
      userId: map['userId'] ?? '',
      logDate: (map['logDate'] as Timestamp).toDate(),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      severity: map['severity'] ?? 'medium',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pregnancyId': pregnancyId,
      'userId': userId,
      'logDate': Timestamp.fromDate(logDate),
      'symptoms': symptoms,
      'severity': severity,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SymptomLogModel copyWith({
    String? id,
    String? pregnancyId,
    String? userId,
    DateTime? logDate,
    List<String>? symptoms,
    String? severity,
    String? notes,
    DateTime? createdAt,
  }) {
    return SymptomLogModel(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      symptoms: symptoms ?? this.symptoms,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
