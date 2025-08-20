class HistoryModel {
  final String id;
  final double? bmi;
  final int? calories;
  final double? protein;
  final double? waterIntake;
  final int? steps;
  final DateTime date;
  final String timestamp; // ISO 8601 string for easy sorting

  HistoryModel({
    required this.id,
    this.bmi,
    this.calories,
    this.protein,
    this.waterIntake,
    this.steps,
    required this.date,
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
      date: DateTime.parse(map['timestamp']),
      timestamp: map['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bmi': bmi,
      'calories': calories,
      'protein': protein,
      'waterIntake': waterIntake,
      'steps': steps,
      'timestamp': timestamp,
    };
  }
}
