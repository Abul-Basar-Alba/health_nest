class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map, String id) {
    return FoodModel(
      id: id,
      name: map['name'] as String? ?? '',
      calories: (map['calories'] as num? ?? 0).toDouble(),
      protein: (map['protein'] as num? ?? 0).toDouble(),
      fat: (map['fat'] as num? ?? 0).toDouble(),
      carbohydrates: (map['carbohydrates'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
    };
  }
}
