import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/history_model.dart';
import '../models/food_model.dart';
import '../models/post_model.dart'; // New import
import '../models/message_model.dart'; // New import
import '../models/conversation_model.dart'; // New import

class FirestoreService {
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Firestore updateUser error: $e');
      rethrow;
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Management ---
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

  // New: Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // --- History Management ---
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

  // --- Food Management ---
  Future<void> saveFoodEntry(String userId, FoodModel food) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('food_log')
        .add(food.toMap());
  }

  // --- Community Posts Management ---
  Future<void> addPost(PostModel post) async {
    await _db.collection('posts').add(post.toMap());
  }

  Stream<List<PostModel>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // --- Messaging Management ---
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Future<void> updateConversation(ConversationModel conversation) async {
    await _db
        .collection('chats')
        .doc(conversation.id)
        .set(conversation.toMap());
  }
}
