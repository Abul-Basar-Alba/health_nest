// lib/src/models/bump_photo_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class BumpPhotoModel {
  final String id;
  final String userId;
  final String pregnancyId;
  final int week;
  final DateTime photoDate;
  final String photoUrl; // Firebase Storage URL
  final String? notes;
  final double? weight; // Optional weight at this week
  final double? bellySize; // Optional belly measurement in cm
  final List<String> tags; // e.g., 'happy', 'tired', 'glowing'
  final DateTime createdAt;

  BumpPhotoModel({
    required this.id,
    required this.userId,
    required this.pregnancyId,
    required this.week,
    required this.photoDate,
    required this.photoUrl,
    this.notes,
    this.weight,
    this.bellySize,
    this.tags = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pregnancyId': pregnancyId,
      'week': week,
      'photoDate': Timestamp.fromDate(photoDate),
      'photoUrl': photoUrl,
      'notes': notes,
      'weight': weight,
      'bellySize': bellySize,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory BumpPhotoModel.fromMap(Map<String, dynamic> map) {
    return BumpPhotoModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      pregnancyId: map['pregnancyId'] ?? '',
      week: map['week'] ?? 0,
      photoDate: (map['photoDate'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'] ?? '',
      notes: map['notes'],
      weight: map['weight']?.toDouble(),
      bellySize: map['bellySize']?.toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Copy with method
  BumpPhotoModel copyWith({
    String? id,
    String? userId,
    String? pregnancyId,
    int? week,
    DateTime? photoDate,
    String? photoUrl,
    String? notes,
    double? weight,
    double? bellySize,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return BumpPhotoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      week: week ?? this.week,
      photoDate: photoDate ?? this.photoDate,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      weight: weight ?? this.weight,
      bellySize: bellySize ?? this.bellySize,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  String get formattedDate {
    return '${photoDate.day}/${photoDate.month}/${photoDate.year}';
  }

  String get formattedWeight {
    if (weight == null) return '';
    return '${weight!.toStringAsFixed(1)} kg';
  }

  String get formattedBellySize {
    if (bellySize == null) return '';
    return '${bellySize!.toStringAsFixed(1)} cm';
  }

  String get weekLabel => 'Week $week';
  String get weekLabelBN => 'সপ্তাহ $week';

  // Common tags
  static const Map<String, String> commonTagsEN = {
    'happy': 'Happy',
    'tired': 'Tired',
    'glowing': 'Glowing',
    'excited': 'Excited',
    'nervous': 'Nervous',
    'energetic': 'Energetic',
    'nauseous': 'Nauseous',
    'beautiful': 'Beautiful',
  };

  static const Map<String, String> commonTagsBN = {
    'happy': 'খুশি',
    'tired': 'ক্লান্ত',
    'glowing': 'উজ্জ্বল',
    'excited': 'উত্তেজিত',
    'nervous': 'উদ্বিগ্ন',
    'energetic': 'শক্তিশালী',
    'nauseous': 'বমি বমি ভাব',
    'beautiful': 'সুন্দর',
  };

  List<String> getTagNames(bool isBangla) {
    return tags.map((tag) {
      return isBangla ? (commonTagsBN[tag] ?? tag) : (commonTagsEN[tag] ?? tag);
    }).toList();
  }
}
