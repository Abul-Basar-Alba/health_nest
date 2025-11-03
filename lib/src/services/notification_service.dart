import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // You can show a local notification here
    });
  }

  // Send a notification to Firestore
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Firestore will generate
        userId: userId,
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        data: data,
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Get notifications stream for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to recent 50 notifications
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all as read: $e');
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Save FCM token for user
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Send push notification (requires Cloud Functions)
  // This is a placeholder - actual implementation requires Firebase Cloud Functions
  Future<void> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // In production, this would call a Cloud Function that sends the push notification
    // For now, we'll just create a Firestore notification
    await sendNotification(
      userId: targetUserId,
      title: title,
      message: body,
      type: 'system',
      data: data,
    );
  }

  // Send notification for post reaction
  Future<void> sendReactionNotification({
    required String postAuthorId,
    required String reactorName,
    required String reactionType,
    required String postId,
  }) async {
    final emoji = _getReactionEmoji(reactionType);
    await sendNotification(
      userId: postAuthorId,
      title: 'New Reaction',
      message: '$reactorName reacted $emoji to your post',
      type: 'post_reaction',
      data: {
        'postId': postId,
        'reactionType': reactionType,
      },
    );
  }

  // Send notification for post comment
  Future<void> sendCommentNotification({
    required String postAuthorId,
    required String commenterName,
    required String commentText,
    required String postId,
  }) async {
    await sendNotification(
      userId: postAuthorId,
      title: 'New Comment',
      message:
          '$commenterName commented: ${commentText.length > 50 ? "${commentText.substring(0, 50)}..." : commentText}',
      type: 'post_comment',
      data: {
        'postId': postId,
      },
    );
  }

  // Send notification for comment reply
  Future<void> sendCommentReplyNotification({
    required String commentAuthorId,
    required String replierName,
    required String replyText,
    required String postId,
  }) async {
    await sendNotification(
      userId: commentAuthorId,
      title: 'New Reply',
      message:
          '$replierName replied: ${replyText.length > 50 ? "${replyText.substring(0, 50)}..." : replyText}',
      type: 'comment_reply',
      data: {
        'postId': postId,
      },
    );
  }

  // Get emoji for reaction type
  String _getReactionEmoji(String type) {
    switch (type) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'haha':
        return '😄';
      case 'wow':
        return '😮';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      default:
        return '👍';
    }
  }
}
