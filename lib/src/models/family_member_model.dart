// lib/src/models/family_member_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMemberModel {
  final String id;
  final String userId; // Primary user who added this family member
  final String name;
  final String relationship; // Mother, Father, Son, Daughter, etc.
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime dateOfBirth;
  final bool isCaregiver; // Can view/manage medicines for primary user
  final bool canReceiveNotifications; // Receive alerts when medicine missed
  final List<String> caregiverForUserIds; // List of user IDs this person is caregiver for
  final DateTime createdAt;
  final DateTime? lastModified;

  FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.dateOfBirth,
    this.isCaregiver = false,
    this.canReceiveNotifications = false,
    List<String>? caregiverForUserIds,
    DateTime? createdAt,
    this.lastModified,
  })  : caregiverForUserIds = caregiverForUserIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Copy with
  FamilyMemberModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? relationship,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? dateOfBirth,
    bool? isCaregiver,
    bool? canReceiveNotifications,
    List<String>? caregiverForUserIds,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isCaregiver: isCaregiver ?? this.isCaregiver,
      canReceiveNotifications:
          canReceiveNotifications ?? this.canReceiveNotifications,
      caregiverForUserIds: caregiverForUserIds ?? this.caregiverForUserIds,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'relationship': relationship,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'isCaregiver': isCaregiver,
      'canReceiveNotifications': canReceiveNotifications,
      'caregiverForUserIds': caregiverForUserIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified':
          lastModified != null ? Timestamp.fromDate(lastModified!) : null,
    };
  }

  // From Firestore
  factory FamilyMemberModel.fromMap(String id, Map<String, dynamic> map) {
    return FamilyMemberModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      isCaregiver: map['isCaregiver'] ?? false,
      canReceiveNotifications: map['canReceiveNotifications'] ?? false,
      caregiverForUserIds: map['caregiverForUserIds'] != null
          ? List<String>.from(map['caregiverForUserIds'])
          : [],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastModified: map['lastModified'] != null
          ? (map['lastModified'] as Timestamp).toDate()
          : null,
    );
  }
}

// Relationship types
class FamilyRelationship {
  static const String mother = 'Mother';
  static const String father = 'Father';
  static const String son = 'Son';
  static const String daughter = 'Daughter';
  static const String brother = 'Brother';
  static const String sister = 'Sister';
  static const String grandfather = 'Grandfather';
  static const String grandmother = 'Grandmother';
  static const String grandson = 'Grandson';
  static const String granddaughter = 'Granddaughter';
  static const String spouse = 'Spouse';
  static const String other = 'Other';

  static const List<String> all = [
    mother,
    father,
    son,
    daughter,
    brother,
    sister,
    grandfather,
    grandmother,
    grandson,
    granddaughter,
    spouse,
    other,
  ];

  static String getIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'mother':
      case 'grandmother':
        return '👩';
      case 'father':
      case 'grandfather':
        return '👨';
      case 'son':
      case 'brother':
      case 'grandson':
        return '👦';
      case 'daughter':
      case 'sister':
      case 'granddaughter':
        return '👧';
      case 'spouse':
        return '💑';
      default:
        return '👤';
    }
  }
}
