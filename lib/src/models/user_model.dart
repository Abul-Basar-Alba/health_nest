// lib/src/models/user_model.dart

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
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final bool isPremium;
  final bool isProfilePublic;
  final String? profileImageUrl;
  final double? bmi;
  final String? bmiCategory; // New field for BMI category
  final String? activityLevel; // New field for activity level
  final int? dailyCalories; // New field for daily calorie recommendation
  final bool isAdmin; // New field to check if the user is an admin
  final List<String> likedPosts; // List of liked post IDs

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.isPremium = false,
    this.profileImageUrl,
    this.bmi,
    this.bmiCategory,
    this.activityLevel,
    this.dailyCalories,
    this.isProfilePublic = false,
    this.isAdmin = false, // Set default value to false
    this.likedPosts = const [], // Default to empty list
  });

  // Factory constructor to create a UserModel from a Firestore map
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      isPremium: map['isPremium'] as bool? ?? false,
      profileImageUrl: map['profileImageUrl'] as String?,
      bmi: (map['bmi'] as num?)?.toDouble(),
      bmiCategory: map['bmiCategory'] as String?,
      activityLevel: map['activityLevel'] as String?,
      dailyCalories: (map['dailyCalories'] as num?)?.toInt(),
      isProfilePublic: map['isProfilePublic'] as bool? ?? false,
      isAdmin: map['isAdmin'] as bool? ?? false, // Get the value from the map
      likedPosts: (map['likedPosts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  // Method to convert the UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'isPremium': isPremium,
      'profileImageUrl': profileImageUrl,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'activityLevel': activityLevel,
      'dailyCalories': dailyCalories,
      'isProfilePublic': isProfilePublic,
      'isAdmin': isAdmin, // Add the new field to the map
      'likedPosts': likedPosts,
    };
  }

  double? get calculatedBmi {
    if (weight != null && height != null && height! > 0) {
      return weight! / ((height! / 100) * (height! / 100));
    }
    return null;
  }

  String get uid => id;

  String? get profilePhotoUrl => profileImageUrl;
}
