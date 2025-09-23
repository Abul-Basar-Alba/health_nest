import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final int likes;
  final int comments;
  final Timestamp timestamp;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    required this.timestamp,
  });

  // Factory constructor to create a PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  // Convert PostModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp,
    };
  }
}
