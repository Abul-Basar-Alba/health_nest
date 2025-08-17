class HistoryModel {
  final String id;
  final double? bmi;
  final int? calories;
  final double? protein;
  final double? waterIntake;
  final int? steps;
  final String timestamp;

  HistoryModel({
    required this.id,
    this.bmi,
    this.calories,
    this.protein,
    this.waterIntake,
    this.steps,
    required this.timestamp,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      bmi: (map['bmi'] as num?)?.toDouble(),
      calories: (map['calories'] as num?)?.toInt(),
      protein: (map['protein'] as num?)?.toDouble(),
      waterIntake: (map['waterIntake'] as num?)?.toDouble(),
      steps: (map['steps'] as num?)?.toInt(),
      timestamp: map['timestamp'] as String? ?? '',
    );
  }
}
