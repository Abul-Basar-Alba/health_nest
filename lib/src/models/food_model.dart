class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double carbs;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.fat = 0,
    this.carbohydrates = 0,
    required this.carbs,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      calories: (map['calories'] as num? ?? 0).toDouble(),
      protein: (map['protein'] as num? ?? 0).toDouble(),
      fat: (map['fat'] as num? ?? 0).toDouble(),
      carbohydrates: (map['carbohydrates'] as num? ?? 0).toDouble(),
      carbs: (map['carbs'] as num? ?? 0).toDouble(),
    );
  }

  static FoodModel fromApi(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String? ?? '',
      name: json['label'] as String? ?? '',
      calories: (json['nutrients']?['ENERC_KCAL'] as num? ?? 0).toDouble(),
      protein: (json['nutrients']?['PROCNT'] as num? ?? 0).toDouble(),
      fat: (json['nutrients']?['FAT'] as num? ?? 0).toDouble(),
      carbohydrates: (json['nutrients']?['CHOCDF'] as num? ?? 0).toDouble(),
      carbs: (json['nutrients']?['CHOCDF'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'carbs': carbs,
    };
  }
}
