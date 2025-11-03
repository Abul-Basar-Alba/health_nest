import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id; // Firestore document ID
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final Timestamp timestamp;

  CommentModel({
    required this.id, // final id, assign at creation
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.content,
    required this.timestamp,
  });

  /// Factory constructor to create a CommentModel from a Firestore document.
  factory CommentModel.fromMap(Map<String, dynamic> data, String docId) {
    return CommentModel(
      id: docId, // assign Firestore doc ID here
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Method to convert the CommentModel object to a Map for Firestore.
  /// Note: 'id' is NOT included because Firestore document ID is separate.
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp,
    };
  }

  /// Create a new CommentModel with a Firestore-generated ID
  static CommentModel createNew({
    required String postId,
    required String userId,
    required String userName,
    String userAvatar = '',
    required String content,
  }) {
    final docId =
        ''; // Firestore doc ID will be assigned later in CommunityService
    return CommentModel(
      id: docId,
      postId: postId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      timestamp: Timestamp.now(),
    );
  }
}
