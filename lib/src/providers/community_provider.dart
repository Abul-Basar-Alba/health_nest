import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../services/community_service.dart';
import './user_provider.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();

  // A list to hold all the posts.
  List<PostModel> _posts = [];
  bool _isLoading = false;

  // Getters to expose data to the UI.
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  // Constructor to start fetching posts as soon as the provider is created.
  CommunityProvider() {
    _service.getPostsStream().listen((posts) {
      _posts = posts;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Function to add a new post to Firestore.
  Future<void> addPost(String content, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser != null) {
      final newPost = PostModel(
        id: '', // Firestore will generate the ID
        userId: currentUser.id,
        userName: currentUser.name,
        content: content,
        reactions: {}, // Empty reactions map
        comments: 0,
        timestamp: Timestamp.now(),
      );
      await _service.addPost(newPost);
    }
  }

  // Function to add a comment to a specific post.
  Future<void> addComment(
      String postId, String content, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser != null) {
      final newComment = CommentModel(
        id: '', // Firestore will generate the ID
        postId: postId,
        userId: currentUser.id,
        userName: currentUser.name,
        content: content,
        timestamp: Timestamp.now(),
      );
      await _service.addComment(newComment);
    }
  }

  // Updated function to toggle a like on a post with userProvider sync
  Future<void> toggleLike(
      String postId, String userId, UserProvider userProvider) async {
    await _service.toggleLike(postId, userId);

    // Update the local userProvider.likedPosts for instant UI feedback
    if (userProvider.user != null) {
      if (userProvider.user!.likedPosts.contains(postId)) {
        userProvider.user!.likedPosts.remove(postId);
      } else {
        userProvider.user!.likedPosts.add(postId);
      }
      userProvider.notifyListeners();
    }
  }

  // Stream to get comments for a specific post in real-time.
  Stream<List<CommentModel>> getCommentsForPost(String postId) {
    return _service.getCommentsStream(postId);
  }
}
