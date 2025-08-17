class HistoryModel {
  final String id;
  final double? bmi;
  final int? calories;
  final double? weight;
  final double? height;
  final int? age;
  final String? activityLevel;
  final int? steps;
  final DateTime timestamp;

  HistoryModel({
    required this.id,
    this.bmi,
    this.calories,
    this.weight,
    this.height,
    this.age,
    this.activityLevel,
    this.steps,
    required this.timestamp,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      bmi: map['bmi']?.toDouble(),
      calories: map['calories'],
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      age: map['age'],
      activityLevel: map['activityLevel'],
      steps: map['steps'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}