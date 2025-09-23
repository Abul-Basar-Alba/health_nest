// lib/src/services/admin_message_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_message_model.dart';
import '../models/user_model.dart';

class AdminMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    final timestamp = Timestamp.now();
    final messageModel = AdminMessageModel(
      senderId: senderId,
      receiverId: receiverId,
      text: message,
      timestamp: timestamp,
    );

    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('adminChats')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageModel.toMap());
  }

  // This function has been corrected
  Stream<List<AdminMessageModel>> getMessages(
      String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId]; // Corrected here
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('adminChats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminMessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }
}
