// lib/src/services/alarm_permission_service.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissionService {
  static const platform = MethodChannel('com.example.health_nest/alarms');

  /// Check if exact alarm permission is granted (Android 12+)
  static Future<bool> isExactAlarmPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 12+ (API 31+)
      final int sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 31) {
        // Check if SCHEDULE_EXACT_ALARM permission is granted
        final result = await platform.invokeMethod('canScheduleExactAlarms');
        return result as bool;
      }
      return true; // Lower Android versions don't need this permission
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Request exact alarm permission
  static Future<bool> requestExactAlarmPermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      final int sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 31) {
        final isGranted = await isExactAlarmPermissionGranted();

        if (!isGranted) {
          // Show dialog explaining why we need this permission
          final shouldRequest = await _showPermissionDialog(context);

          if (shouldRequest) {
            // Open system settings for alarm permissions
            await platform.invokeMethod('openAlarmSettings');

            // Wait a bit for user to grant permission
            await Future.delayed(const Duration(seconds: 2));

            // Check again
            return await isExactAlarmPermissionGranted();
          }
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Show dialog explaining the permission
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('🔔 Alarm Permission Required'),
              content: const Text(
                'HealthNest needs permission to set exact alarms for:\n\n'
                '💊 Medicine reminders\n'
                '💧 Water reminders\n'
                '🤰 Pregnancy check-ups\n'
                '😴 Sleep reminders\n\n'
                'This ensures you get notifications at the exact scheduled time.\n\n'
                'Please enable "Alarms & reminders" in the next screen.',
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSdkInt() async {
    try {
      final sdkInt = await platform.invokeMethod<int>('getSdkInt');
      return sdkInt ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request all necessary permissions for alarms and notifications
  static Future<Map<String, bool>> requestAllPermissions(
      BuildContext context) async {
    final results = <String, bool>{};

    // 1. Notification permission (Android 13+)
    results['notifications'] = await requestNotificationPermission();

    // 2. Exact alarm permission (Android 12+)
    results['exactAlarms'] = await requestExactAlarmPermission(context);

    return results;
  }

  /// Check all permissions status
  static Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    // Notification permission
    results['notifications'] = await Permission.notification.isGranted;

    // Exact alarm permission
    results['exactAlarms'] = await isExactAlarmPermissionGranted();

    return results;
  }
}
