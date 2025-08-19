class UserModel {
  final String id;
  final String name;
  final String email;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final bool isPremium;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.isPremium = false,
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
    };
  }
}
