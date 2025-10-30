import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'dart:async';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _notificationSubscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialize and listen to notifications
  void initialize(String userId) {
    _notificationService.initialize();
    listenToNotifications(userId);
  }

  // Listen to real-time notifications
  void listenToNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationService
        .getNotificationsStream(userId)
        .listen((notifications) {
      _notifications = notifications;
      _updateUnreadCount();
      notifyListeners();
    });
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Send a notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        data: data,
      );
    } catch (e) {
      print('Error in provider sending notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _notificationService.markAllAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _notificationService.deleteAllNotifications(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting all notifications: $e');
    }
  }

  // Dispose
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
