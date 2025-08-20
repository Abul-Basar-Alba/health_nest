import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final int likes;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.likes,
    required this.timestamp,
  });

  // Factory constructor to create a PostModel from a Firestore document.
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert the PostModel object to a JSON map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'likes': likes,
      'timestamp': timestamp,
    };
  }
}
