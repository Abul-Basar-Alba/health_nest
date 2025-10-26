// lib/src/services/history_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_history_model.dart';
import '../models/bmi_history_model.dart';
import '../models/nutrition_history_model.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  String get _bmiCollection => 'bmi_history';
  String get _activityCollection => 'activity_history';
  String get _nutritionCollection => 'nutrition_history';

  // ============ BMI History ============
  Future<void> saveBMIHistory({
    required String userId,
    required double bmi,
    required String category,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    double? bmr,
    int? dailyCalories,
    double? idealWeight,
    double? bodyFat,
  }) async {
    try {
      await _firestore.collection(_bmiCollection).add({
        'userId': userId,
        'date': Timestamp.now(),
        'bmi': bmi,
        'category': category,
        'weight': weight,
        'height': height,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
        'bmr': bmr,
        'dailyCalories': dailyCalories,
        'idealWeight': idealWeight,
        'bodyFat': bodyFat,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save BMI history: $e');
    }
  }

  Stream<List<BMIHistoryModel>> getBMIHistory(String userId) {
    return _firestore
        .collection(_bmiCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BMIHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<BMIHistoryModel>> getBMIHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_bmiCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BMIHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get BMI history: $e');
    }
  }

  // ============ Activity History ============
  Future<void> saveActivityHistory({
    required String userId,
    required String activityLevel,
    String? exerciseType,
    int? durationMinutes,
    int? caloriesBurned,
    int? steps,
    double? distanceKm,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_activityCollection).add({
        'userId': userId,
        'date': Timestamp.now(),
        'activityLevel': activityLevel,
        'exerciseType': exerciseType,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'steps': steps,
        'distanceKm': distanceKm,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save activity history: $e');
    }
  }

  Stream<List<ActivityHistoryModel>> getActivityHistory(String userId) {
    return _firestore
        .collection(_activityCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<ActivityHistoryModel>> getActivityHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_activityCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivityHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activity history: $e');
    }
  }

  // ============ Nutrition History ============
  Future<void> saveNutritionHistory({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
    double? protein,
    double? carbs,
    double? fats,
    double? quantity,
    String? unit,
    String? imageUrl,
    String? notes,
  }) async {
    try {
      await _firestore.collection(_nutritionCollection).add({
        'userId': userId,
        'date': Timestamp.now(),
        'mealType': mealType,
        'foodName': foodName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'quantity': quantity,
        'unit': unit,
        'imageUrl': imageUrl,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save nutrition history: $e');
    }
  }

  Stream<List<NutritionHistoryModel>> getNutritionHistory(String userId) {
    return _firestore
        .collection(_nutritionCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NutritionHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<NutritionHistoryModel>> getTodaysFoodLog(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection(_nutritionCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => NutritionHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today\'s food log: $e');
    }
  }

  Future<void> deleteNutritionEntry(String entryId) async {
    try {
      await _firestore.collection(_nutritionCollection).doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete nutrition entry: $e');
    }
  }

  // ============ Analytics ============
  Future<Map<String, dynamic>> getWeeklyAnalytics(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    try {
      // Get BMI trend
      final bmiHistory = await getBMIHistoryByDateRange(userId, weekAgo, now);

      // Get activity summary
      final activitySnapshot = await _firestore
          .collection(_activityCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      final totalWorkouts = activitySnapshot.docs.length;
      final totalMinutes = activitySnapshot.docs
          .map((doc) => doc.data()['durationMinutes'] as int? ?? 0)
          .fold<int>(0, (sum, duration) => sum + duration);

      // Get nutrition summary
      final nutritionSnapshot = await _firestore
          .collection(_nutritionCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      final totalCalories = nutritionSnapshot.docs
          .map((doc) => doc.data()['calories'] as int? ?? 0)
          .fold<int>(0, (sum, cal) => sum + cal);

      return {
        'bmiTrend': bmiHistory,
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'averageCalories': nutritionSnapshot.docs.isEmpty
            ? 0
            : totalCalories ~/ nutritionSnapshot.docs.length,
        'weekStart': weekAgo,
        'weekEnd': now,
      };
    } catch (e) {
      throw Exception('Failed to get weekly analytics: $e');
    }
  }
}
