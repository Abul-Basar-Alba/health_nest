// lib/src/models/food_model.dart

class FoodItem {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'imageUrl': imageUrl,
    };
  }

  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String imageUrl;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final food = json['food'];
    final nutrients = food['nutrients'];

    return FoodItem(
      name: food['label'],
      calories: nutrients['ENERC_KCAL'] ?? 0.0,
      protein: nutrients['PROCNT'] ?? 0.0,
      fat: nutrients['FAT'] ?? 0.0,
      carbs: nutrients['CHOCDF'] ?? 0.0,
      imageUrl: food['image'] ?? '',
    );
  }
}
