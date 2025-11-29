import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool? edited;
  final DateTime? editedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.edited,
    this.editedAt,
  });

  // Factory constructor to create a MessageModel from a Firestore document.
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      edited: data['edited'] as bool?,
      editedAt: data['editedAt'] != null
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Method to convert the MessageModel object to a JSON map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      if (edited != null) 'edited': edited,
      if (editedAt != null) 'editedAt': editedAt,
    };
  }
}
