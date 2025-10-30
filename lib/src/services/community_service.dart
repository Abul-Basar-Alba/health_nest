import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
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

  // Toggle like on a post
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
          final userName = userData['displayName'] ?? 'Someone';

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
          final userName =
              userDoc.data()?['displayName'] ?? 'Someone';

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
