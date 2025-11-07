import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'notification_service.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Add a new post
  Future<void> addPost(PostModel post) async {
    try {
      final docRef = _firestore.collection('posts').doc();
      await docRef.set(post.toMap()); // Firestore will generate ID
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  // Stream all posts in real-time
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // Stream posts by category
  Stream<List<PostModel>> getPostsByCategory(String category) {
    return _firestore
        .collection('posts')
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // Stream pregnancy posts by due date month/year
  Stream<List<PostModel>> getPregnancyPostsByDueDate(
      String monthYear) // Format: "January 2025"
  {
    return _firestore
        .collection('posts')
        .where('category', isEqualTo: 'pregnancy')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final posts =
          snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
      // Filter by due date month/year
      return posts.where((post) {
        if (post.pregnancyDueDate == null) return false;
        try {
          final dueDate = DateTime.parse(post.pregnancyDueDate!);
          final dueDateMonthYear =
              '${_getMonthName(dueDate.month)} ${dueDate.year}';
          return dueDateMonthYear == monthYear;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  // Toggle reaction on a post (FB-style: like, love, haha, wow, sad, angry)
  Future<void> toggleReaction(
      String postId, String userId, String reactionType) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final userReactionRef = postRef.collection('user_reactions').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      final userReactionSnapshot = await transaction.get(userReactionRef);

      if (!postSnapshot.exists) throw Exception("Post does not exist!");

      final postData = postSnapshot.data() as Map<String, dynamic>;
      final reactions = Map<String, int>.from(postData['reactions'] ?? {});

      if (userReactionSnapshot.exists) {
        // User already reacted
        final currentReaction =
            userReactionSnapshot.data()!['reactionType'] as String;

        if (currentReaction == reactionType) {
          // Remove reaction (toggle off)
          reactions[currentReaction] = (reactions[currentReaction] ?? 1) - 1;
          if (reactions[currentReaction]! <= 0)
            reactions.remove(currentReaction);
          transaction.delete(userReactionRef);
        } else {
          // Change reaction
          reactions[currentReaction] = (reactions[currentReaction] ?? 1) - 1;
          if (reactions[currentReaction]! <= 0)
            reactions.remove(currentReaction);
          reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;
          transaction.update(userReactionRef, {
            'reactionType': reactionType,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Send notification for new reaction type
          _sendReactionNotification(postData, userId, reactionType);
        }
      } else {
        // New reaction
        reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;
        transaction.set(userReactionRef, {
          'userId': userId,
          'reactionType': reactionType,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Send notification
        _sendReactionNotification(postData, userId, reactionType);
      }

      transaction.update(postRef, {'reactions': reactions});
    });
  }

  // Get user's current reaction on a post
  Future<String?> getUserReaction(String postId, String userId) async {
    final doc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('user_reactions')
        .doc(userId)
        .get();

    if (doc.exists) {
      return doc.data()?['reactionType'] as String?;
    }
    return null;
  }

  // Send reaction notification
  void _sendReactionNotification(
      Map<String, dynamic> postData, String userId, String reactionType) async {
    final postAuthorId = postData['userId'];
    if (postAuthorId != userId) {
      // Don't notify if reacting to own post
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userName = userDoc.data()?['name'] ?? 'Someone';

        final reactionEmojis = {
          'like': '👍',
          'love': '❤️',
          'haha': '😂',
          'wow': '😮',
          'sad': '😢',
          'angry': '😠',
        };

        await _notificationService.sendNotification(
          userId: postAuthorId,
          title: '${reactionEmojis[reactionType] ?? '👍'} New Reaction',
          message: '$userName reacted $reactionType to your post',
          type: 'reaction',
          data: {
            'postId': postData['id'] ?? '',
            'fromUserId': userId,
            'reactionType': reactionType
          },
        );
      } catch (e) {
        print('Error sending reaction notification: $e');
      }
    }
  }

  // Toggle like on a post (deprecated - use toggleReaction instead)
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final userRef = _firestore.collection('users').doc(userId);
    final likeRef = postRef.collection('likes').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) throw Exception("Post does not exist!");

      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) throw Exception("User does not exist!");

      final userLikedPosts =
          (userSnapshot.data() as Map<String, dynamic>)['likedPosts'] ?? [];

      if (userLikedPosts.contains(postId)) {
        // Unlike
        transaction.update(postRef, {'likes': FieldValue.increment(-1)});
        transaction.update(userRef, {
          'likedPosts': FieldValue.arrayRemove([postId])
        });
        transaction.delete(likeRef);
      } else {
        // Like - Send notification to post author
        transaction.update(postRef, {'likes': FieldValue.increment(1)});
        transaction.update(userRef, {
          'likedPosts': FieldValue.arrayUnion([postId])
        });
        transaction.set(likeRef,
            {'userId': userId, 'timestamp': FieldValue.serverTimestamp()});

        // Send notification to post author (if not liking own post)
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final postAuthorId = postData['userId'];
        if (postAuthorId != userId) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'Someone';

          // Send notification after transaction completes
          Future.delayed(Duration.zero, () {
            _notificationService.sendNotification(
              userId: postAuthorId,
              title: '❤️ New Like',
              message: '$userName liked your post',
              type: 'like',
              data: {'postId': postId, 'fromUserId': userId},
            );
          });
        }
      }
    });
  }

  // Add comment
  Future<void> addComment(CommentModel comment) async {
    try {
      final postRef = _firestore.collection('posts').doc(comment.postId);
      final commentsRef = postRef.collection('comments');

      await commentsRef.add(comment.toMap()); // Firestore generates ID
      await postRef.update({'comments': FieldValue.increment(1)});

      // Send notification to post author
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final postData = postDoc.data() as Map<String, dynamic>;
        final postAuthorId = postData['userId'];

        // Don't send notification if commenting on own post
        if (postAuthorId != comment.userId) {
          // Get commenter's name
          final userDoc =
              await _firestore.collection('users').doc(comment.userId).get();
          final userName = userDoc.data()?['name'] ?? 'Someone';

          await _notificationService.sendNotification(
            userId: postAuthorId,
            title: '💬 New Comment',
            message: '$userName commented on your post',
            type: 'comment',
            data: {
              'postId': comment.postId,
              'commentId': comment.id,
              'fromUserId': comment.userId
            },
          );
        }
      }
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Stream comments for a post
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
