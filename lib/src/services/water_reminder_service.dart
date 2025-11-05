// lib/src/services/water_reminder_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/water_reminder_model.dart';

class WaterReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final WaterReminderService _instance =
      WaterReminderService._internal();
  factory WaterReminderService() => _instance;
  WaterReminderService._internal();

  bool _initialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Navigate to water reminder screen
    // This will be handled by the app's navigation system
    print('Water reminder notification tapped');
  }

  // Save or update water reminder schedule
  Future<void> saveSchedule(WaterReminderModel reminder) async {
    await _firestore
        .collection('water_reminders')
        .doc(reminder.userId)
        .set(reminder.toMap());

    // Reschedule notifications
    if (reminder.isEnabled) {
      await scheduleNotifications(reminder);
    } else {
      await cancelNotifications(reminder.userId);
    }
  }

  // Get water reminder schedule
  Future<WaterReminderModel?> getSchedule(String userId) async {
    final doc =
        await _firestore.collection('water_reminders').doc(userId).get();

    if (doc.exists) {
      return WaterReminderModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Stream water reminder schedule
  Stream<WaterReminderModel?> getScheduleStream(String userId) {
    return _firestore
        .collection('water_reminders')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return WaterReminderModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Log water intake
  Future<void> logWaterIntake(String userId, int glasses) async {
    final docRef = _firestore.collection('water_reminders').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final reminder = WaterReminderModel.fromMap(doc.data()!);

      // Check if needs reset
      if (reminder.needsReset()) {
        // Save yesterday's data to history
        await _saveToHistory(reminder);

        // Reset today's intake
        await docRef.update({
          'todayIntake': glasses,
          'lastDrinkTime': DateTime.now().toIso8601String(),
          'lastResetDate': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Update today's intake
        await docRef.update({
          'todayIntake': reminder.todayIntake + glasses,
          'lastDrinkTime': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Save to history
  Future<void> _saveToHistory(WaterReminderModel reminder) async {
    if (reminder.todayIntake > 0) {
      final history = WaterIntakeHistory(
        id: '',
        userId: reminder.userId,
        date: reminder.lastResetDate,
        glassesCount: reminder.todayIntake,
        totalMl: reminder.totalMlToday,
        targetGlasses: reminder.targetGlasses,
        percentage: reminder.percentageCompleted,
      );

      await _firestore
          .collection('water_intake_history')
          .add(history.toMap());
    }
  }

  // Get history for last 7 days
  Future<List<WaterIntakeHistory>> getHistory(String userId,
      {int days = 7}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    final snapshot = await _firestore
        .collection('water_intake_history')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WaterIntakeHistory.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Schedule notifications for all reminder times
  Future<void> scheduleNotifications(WaterReminderModel reminder) async {
    await initialize();

    // Cancel existing notifications
    await cancelNotifications(reminder.userId);

    // Schedule new notifications
    for (int i = 0; i < reminder.reminderTimes.length; i++) {
      final timeStr = reminder.reminderTimes[i];
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await _scheduleNotification(
        id: reminder.userId.hashCode + i,
        hour: hour,
        minute: minute,
        title: '💧 Time to Drink Water!',
        body: _getMotivationalMessage(i),
      );
    }
  }

  // Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminder',
          channelDescription: 'Notifications for water drinking reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFF2196F3),
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  // Cancel all notifications for a user
  Future<void> cancelNotifications(String userId) async {
    // Cancel up to 20 possible notification IDs (more than enough for 8 default times)
    for (int i = 0; i < 20; i++) {
      await _notifications.cancel(userId.hashCode + i);
    }
  }

  // Get motivational messages
  String _getMotivationalMessage(int index) {
    final messages = [
      'Start your day hydrated! 🌅',
      'Keep your energy up! 💪',
      'Stay focused and hydrated! 🧠',
      'Time for a water break! 💧',
      'Don\'t forget to hydrate! 🥤',
      'Your body needs water! 💙',
      'Drink up for better health! 🌟',
      'Hydrate before bed! 🌙',
    ];

    return messages[index % messages.length];
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    await initialize();

    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }
}
