import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../models/history_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addHistory(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(data);
    } catch (e) {
      debugPrint('Firestore error: $e');
      rethrow;
    }
  }

  Stream<List<HistoryModel>> getHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<FoodModel>> getFoods() {
    return _firestore.collection('foods').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> addFood(FoodModel food) async {
    try {
      await _firestore.collection('foods').doc(food.id).set(food.toMap());
    } catch (e) {
      debugPrint('Firestore error: $e');
      rethrow;
    }
  }
}
