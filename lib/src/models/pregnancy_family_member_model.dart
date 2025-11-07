// lib/src/models/pregnancy_family_member_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyFamilyMemberModel {
  final String id;
  final String pregnancyId;
  final String userId; // The family member's user ID
  final String memberName;
  final String relationship; // husband, mother, sister, etc.
  final String? phoneNumber;
  final String? email;
  final bool receiveNotifications;
  final List<String> notificationTypes; // checkup, kicks, contractions, etc.
  final DateTime addedAt;
  final bool isActive;

  PregnancyFamilyMemberModel({
    required this.id,
    required this.pregnancyId,
    required this.userId,
    required this.memberName,
    required this.relationship,
    this.phoneNumber,
    this.email,
    this.receiveNotifications = true,
    this.notificationTypes = const [
      'checkup',
      'emergency',
      'milestone',
      'reminder'
    ],
    DateTime? addedAt,
    this.isActive = true,
  }) : addedAt = addedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregnancyId': pregnancyId,
      'userId': userId,
      'memberName': memberName,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'receiveNotifications': receiveNotifications,
      'notificationTypes': notificationTypes,
      'addedAt': Timestamp.fromDate(addedAt),
      'isActive': isActive,
    };
  }

  // Create from Firestore document
  factory PregnancyFamilyMemberModel.fromMap(Map<String, dynamic> map) {
    return PregnancyFamilyMemberModel(
      id: map['id'] ?? '',
      pregnancyId: map['pregnancyId'] ?? '',
      userId: map['userId'] ?? '',
      memberName: map['memberName'] ?? '',
      relationship: map['relationship'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      receiveNotifications: map['receiveNotifications'] ?? true,
      notificationTypes: List<String>.from(map['notificationTypes'] ?? []),
      addedAt: map['addedAt'] != null
          ? (map['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with method
  PregnancyFamilyMemberModel copyWith({
    String? id,
    String? pregnancyId,
    String? userId,
    String? memberName,
    String? relationship,
    String? phoneNumber,
    String? email,
    bool? receiveNotifications,
    List<String>? notificationTypes,
    DateTime? addedAt,
    bool? isActive,
  }) {
    return PregnancyFamilyMemberModel(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      userId: userId ?? this.userId,
      memberName: memberName ?? this.memberName,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      addedAt: addedAt ?? this.addedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Relationship translations
  static const Map<String, String> relationshipsEN = {
    'husband': 'Husband',
    'partner': 'Partner',
    'mother': 'Mother',
    'father': 'Father',
    'sister': 'Sister',
    'brother': 'Brother',
    'mother-in-law': 'Mother-in-law',
    'friend': 'Friend',
    'other': 'Other',
  };

  static const Map<String, String> relationshipsBN = {
    'husband': 'স্বামী',
    'partner': 'সঙ্গী',
    'mother': 'মা',
    'father': 'বাবা',
    'sister': 'বোন',
    'brother': 'ভাই',
    'mother-in-law': 'শাশুড়ি',
    'friend': 'বন্ধু',
    'other': 'অন্যান্য',
  };

  String getRelationshipName(bool isBangla) {
    return isBangla
        ? relationshipsBN[relationship] ?? relationship
        : relationshipsEN[relationship] ?? relationship;
  }

  // Notification type translations
  static const Map<String, String> notificationTypesEN = {
    'checkup': 'Doctor Checkups',
    'emergency': 'Emergency Alerts',
    'milestone': 'Pregnancy Milestones',
    'reminder': 'Daily Reminders',
    'kicks': 'Baby Kicks',
    'contractions': 'Contractions',
  };

  static const Map<String, String> notificationTypesBN = {
    'checkup': 'ডাক্তার চেকআপ',
    'emergency': 'জরুরি সতর্কতা',
    'milestone': 'গর্ভাবস্থার মাইলস্টোন',
    'reminder': 'দৈনিক রিমাইন্ডার',
    'kicks': 'শিশুর কিক',
    'contractions': 'সংকোচন',
  };
}
