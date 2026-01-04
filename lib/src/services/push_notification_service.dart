// ...other imports...

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ...other imports...

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for iOS
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'health_nest_channel',
      'Health Notifications',
      description: 'Notifications for health updates and reminders',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen to incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      _showLocalNotification(message);
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }

  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'health_nest_channel', // Channel ID
      'Health Notifications', // Channel name
      channelDescription: 'Notifications for health updates and reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
    );

    const NotificationDetails platformChannelDetails =
        NotificationDetails(android: androidDetails);

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelDetails,
      payload: 'notification_payload',
    );
  }
}

// Top-level function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
