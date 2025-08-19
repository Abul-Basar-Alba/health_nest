import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/history_model.dart';
import '../models/food_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Management
  Future<void> saveUserData(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel> getUserData(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User data not found.');
    }
    return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // History Management
  Future<void> saveHistory(String userId, HistoryModel history) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .add(history.toMap());
  }

  Stream<List<HistoryModel>> getHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Food Management
  Future<void> saveFoodEntry(String userId, FoodModel food) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('food_log')
        .add(food.toMap());
  }
}
