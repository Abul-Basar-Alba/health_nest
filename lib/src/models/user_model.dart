import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Static method to create a UserModel from Firestore DocumentSnapshot
  static UserModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(doc.id, data);
  }

  final String id;
  final String name;
  final String email;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final bool isPremium;
  final bool isProfilePublic;
  final String? profileImageUrl;
  final double? bmi;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.isPremium = false,
    this.profileImageUrl,
    this.bmi,
    this.isProfilePublic = false,
  });

  // Factory constructor to create a UserModel from a Firestore map
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: (map['age'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      isPremium: map['isPremium'] as bool? ?? false,
      profileImageUrl: map['profileImageUrl'] as String?,
      bmi: (map['bmi'] as num?)?.toDouble(),
      isProfilePublic: map['isProfilePublic'] as bool? ?? false,
    );
  }

  // Method to convert the UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'isPremium': isPremium,
      'profileImageUrl': profileImageUrl,
      'bmi': bmi,
      'isProfilePublic': isProfilePublic,
    };
  }

  double? get calculatedBmi {
    if (weight != null && height != null && height! > 0) {
      return weight! / ((height! / 100) * (height! / 100));
    }
    return null;
  }
}
