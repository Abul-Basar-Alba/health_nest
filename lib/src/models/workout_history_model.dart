class WorkoutHistoryModel {
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final double durationInMinutes;
  final double caloriesBurned;
  final int sets;
  final int reps;

  WorkoutHistoryModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.durationInMinutes,
    required this.caloriesBurned,
    required this.sets,
    required this.reps,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'date': date.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'caloriesBurned': caloriesBurned,
      'sets': sets,
      'reps': reps,
    };
  }

  // Create model from JSON data fetched from Firestore
  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      date: DateTime.parse(json['date'] as String),
      durationInMinutes: (json['durationInMinutes'] as num).toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      sets: json['sets'] as int,
      reps: json['reps'] as int,
    );
  }
}
