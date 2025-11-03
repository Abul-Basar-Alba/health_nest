import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final Map<String, int> reactions; // {'like': 5, 'love': 3, 'haha': 1}
  final int comments;
  final Timestamp timestamp;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.content,
    this.imageUrl,
    Map<String, int>? reactions,
    this.comments = 0,
    required this.timestamp,
  }) : reactions = reactions ?? {};

  // Get total reactions count
  int get totalReactions =>
      reactions.values.fold(0, (sum, count) => sum + count);

  // Method to get reaction count (for compatibility)
  int getReactionCount() {
    return totalReactions;
  }

  // Get user's reaction type if they reacted
  String? getUserReaction(String userId) {
    // This would need to be implemented based on how you store individual user reactions
    // For now, returning null
    return null;
  }

  // Factory constructor to create a PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
      comments: data['comments'] ?? 0,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  // Convert PostModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'reactions': reactions,
      'comments': comments,
      'timestamp': timestamp,
    };
  }
}
