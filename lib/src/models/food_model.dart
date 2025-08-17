class FoodModel {
  final String id;
  final String name;
  final double calories;

  FoodModel({required this.id, required this.name, required this.calories});

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      calories: (map['calories'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
    };
  }
}
