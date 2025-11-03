// lib/src/services/sleep_tracker_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/sleep_schedule_model.dart';

class SleepTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int bedtimeReminderId = 100;
  static const int bedtimeNotificationId = 101;
  static const int wakeTimeNotificationId = 102;

  // Initialize notifications
  Future<void> initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission for Android 12+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    print('✅ Sleep Tracker notifications initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to sleep tracker screen
    print('Notification tapped: ${response.payload}');
  }

  // Save sleep schedule to Firestore
  Future<void> saveSleepSchedule(SleepScheduleModel schedule) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      print('💾 Saving sleep schedule to Firestore...');
      print('   Bedtime: ${schedule.formattedBedtime}');
      print('   Wake Time: ${schedule.formattedWakeTime}');
      print('   Duration: ${schedule.sleepDuration.toStringAsFixed(1)} hours');

      await _firestore
          .collection('sleep_schedules')
          .doc(user.uid)
          .set(schedule.toMap());

      print('✅ Sleep schedule saved to Firestore');

      // Schedule notifications
      if (schedule.notificationsEnabled) {
        print('🔔 Scheduling notifications...');
        await _scheduleNotifications(schedule);

        // Send immediate test notification to confirm it works
        await _sendTestNotification();
      } else {
        print('🔕 Notifications disabled, canceling all...');
        await cancelAllNotifications();
      }
    } catch (e) {
      print('❌ Error saving sleep schedule: $e');
      rethrow;
    }
  }

  // Send test notification immediately
  Future<void> _sendTestNotification() async {
    try {
      await _notificationsPlugin.show(
        999, // Test notification ID
        '✅ Sleep Tracker Active!',
        'Your sleep schedule has been saved. You will receive notifications at your set times.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sleep_tracker_channel',
            'Sleep Tracker',
            channelDescription: 'Notifications for sleep schedule reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF7C4DFF),
            playSound: true,
            enableVibration: true,
            // Using default notification sound (no custom sound file needed)
          ),
        ),
      );
      print('✅ Test notification sent successfully!');
    } catch (e) {
      print('❌ Failed to send test notification: $e');
    }
  }

  // Get user's sleep schedule
  Future<SleepScheduleModel?> getSleepSchedule() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore.collection('sleep_schedules').doc(user.uid).get();

      if (!doc.exists) return null;

      return SleepScheduleModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting sleep schedule: $e');
      return null;
    }
  }

  // Stream sleep schedule
  Stream<SleepScheduleModel?> sleepScheduleStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('sleep_schedules')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return SleepScheduleModel.fromFirestore(doc);
    });
  }

  // Schedule all notifications for sleep schedule
  Future<void> _scheduleNotifications(SleepScheduleModel schedule) async {
    // Cancel existing notifications first
    await cancelAllNotifications();
    print('🗑️ Cancelled all previous notifications');

    final now = DateTime.now();
    print('⏰ Current time: ${now.hour}:${now.minute}');

    // Schedule bedtime reminder (X minutes before bedtime)
    if (schedule.bedtimeReminderEnabled) {
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        schedule.bedtime.hour,
        schedule.bedtime.minute,
      ).subtract(Duration(minutes: schedule.reminderMinutesBefore));

      await _scheduleNotification(
        id: bedtimeReminderId,
        title: '🌙 Bedtime Reminder',
        body:
            'Time to start winding down! Your bedtime is in ${schedule.reminderMinutesBefore} minutes.',
        scheduledTime: reminderTime,
        payload: 'bedtime_reminder',
      );
      print(
          '   ✓ Bedtime reminder: ${reminderTime.hour}:${reminderTime.minute}');
    }

    // Schedule bedtime notification
    if (schedule.notificationsEnabled) {
      final bedtimeScheduled = DateTime(
        now.year,
        now.month,
        now.day,
        schedule.bedtime.hour,
        schedule.bedtime.minute,
      );

      await _scheduleNotification(
        id: bedtimeNotificationId,
        title: '😴 Time for Bed!',
        body:
            'Your sleep schedule has started. Good night and sweet dreams! 🌙',
        scheduledTime: bedtimeScheduled,
        payload: 'bedtime',
      );
      print('   ✓ Bedtime notification: ${schedule.formattedBedtime}');
    }

    // Schedule wake time notification
    if (schedule.wakeUpAlarmEnabled) {
      var wakeTimeScheduled = DateTime(
        now.year,
        now.month,
        now.day,
        schedule.wakeTime.hour,
        schedule.wakeTime.minute,
      );

      // If wake time is earlier than bedtime, it's the next day
      if (wakeTimeScheduled.isBefore(
          DateTime(now.year, now.month, now.day, schedule.bedtime.hour))) {
        wakeTimeScheduled = wakeTimeScheduled.add(const Duration(days: 1));
      }

      await _scheduleNotification(
        id: wakeTimeNotificationId,
        title: '☀️ Good Morning!',
        body:
            'Time to wake up! You slept for ${schedule.sleepDuration.toStringAsFixed(1)} hours. Have a great day! 🌟',
        scheduledTime: wakeTimeScheduled,
        payload: 'wake_time',
      );
      print('   ✓ Wake time notification: ${schedule.formattedWakeTime}');
    }

    print('✅ All notifications scheduled successfully!');
  }

  // Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      final now = DateTime.now();
      var notificationTime = scheduledTime;

      // If the time has passed today, schedule for tomorrow
      if (notificationTime.isBefore(now)) {
        notificationTime = notificationTime.add(const Duration(days: 1));
        print('      ⏭️ Time passed today, scheduling for tomorrow');
      }

      final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

      print(
          '      📅 Scheduled for: ${notificationTime.year}-${notificationTime.month}-${notificationTime.day} ${notificationTime.hour}:${notificationTime.minute}');
      print('      🕐 TZ DateTime: $tzDateTime');

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sleep_tracker_channel',
            'Sleep Tracker',
            channelDescription: 'Notifications for sleep schedule reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF7C4DFF), // Purple color for sleep
            // Using default notification sound (no custom sound file needed)
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      print('      ✅ Notification #$id scheduled successfully');
    } catch (e) {
      print('      ❌ Error scheduling notification #$id: $e');
      rethrow;
    }
  }

  // Cancel all sleep notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancel(bedtimeReminderId);
    await _notificationsPlugin.cancel(bedtimeNotificationId);
    await _notificationsPlugin.cancel(wakeTimeNotificationId);
  }

  // Delete sleep schedule
  Future<void> deleteSleepSchedule() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore.collection('sleep_schedules').doc(user.uid).delete();
      await cancelAllNotifications();
    } catch (e) {
      print('Error deleting sleep schedule: $e');
      rethrow;
    }
  }

  // Update notification settings only
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool bedtimeReminderEnabled,
    required bool wakeUpAlarmEnabled,
    required int reminderMinutesBefore,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore.collection('sleep_schedules').doc(user.uid).update({
        'notificationsEnabled': notificationsEnabled,
        'bedtimeReminderEnabled': bedtimeReminderEnabled,
        'wakeUpAlarmEnabled': wakeUpAlarmEnabled,
        'reminderMinutesBefore': reminderMinutesBefore,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reschedule notifications with new settings
      final schedule = await getSleepSchedule();
      if (schedule != null && notificationsEnabled) {
        await _scheduleNotifications(schedule);
      } else {
        await cancelAllNotifications();
      }
    } catch (e) {
      print('Error updating notification settings: $e');
      rethrow;
    }
  }
}
