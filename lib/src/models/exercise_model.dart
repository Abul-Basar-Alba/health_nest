// lib/src/models/exercise_model.dart


class ExerciseModel {
  final String? id;
  final String? name;
  final String? primaryMuscle; // JSON-এ 'primaryMuscles' থেকে প্রথমটি
  final String? secondaryMuscle; // JSON-এ 'secondaryMuscles' থেকে প্রথমটি
  final String? equipment;
  final String? category;
  final String? level;
  final String? force;
  final List<String>? images;
  final double? caloriesPerMinute; // Add calories per minute field

  // একটি নতুন ফিল্ড যা images অ্যারে থেকে সম্পূর্ণ URL তৈরি করবে
  final String? fullImageUrl;

  // Constructor
  ExerciseModel({
    this.id,
    this.name,
    this.primaryMuscle,
    this.secondaryMuscle,
    this.equipment,
    this.category,
    this.level,
    this.force,
    this.images,
    this.caloriesPerMinute,
    this.fullImageUrl,
  });

  // Factory constructor for creating an ExerciseModel from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    // Check if the 'images' field exists and is a List<dynamic>
    final List<String>? imagesList =
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    // Construct the full image URL from the first image in the array
    final String? fullImageUrl = (imagesList != null && imagesList.isNotEmpty)
        ? 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${imagesList[0]}'
        : null;

    // Extract the first primaryMuscle if available
    final String? primaryMuscle =
        (json['primaryMuscles'] as List<dynamic>?)?.isNotEmpty == true
            ? (json['primaryMuscles'][0] as String)
            : null;

    // Extract the first secondaryMuscle if available
    final String? secondaryMuscle =
        (json['secondaryMuscles'] as List<dynamic>?)?.isNotEmpty == true
            ? (json['secondaryMuscles'][0] as String)
            : null;

    return ExerciseModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      primaryMuscle: primaryMuscle,
      secondaryMuscle: secondaryMuscle,
      equipment: json['equipment'] as String?,
      category: json['category'] as String?,
      level: json['level'] as String?,
      force: json['force'] as String?,
      images: imagesList,
      caloriesPerMinute: (json['caloriesPerMinute'] as num?)?.toDouble(),
      fullImageUrl: fullImageUrl,
    );
  }

  // Convert to JSON/Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscles': primaryMuscle != null ? [primaryMuscle] : [],
      'secondaryMuscles': secondaryMuscle != null ? [secondaryMuscle] : [],
      'equipment': equipment,
      'category': category,
      'level': level,
      'force': force,
      'images': images,
      'caloriesPerMinute': caloriesPerMinute,
    };
  }
}
