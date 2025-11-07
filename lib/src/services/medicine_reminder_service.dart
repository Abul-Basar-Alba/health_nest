// lib/src/services/medicine_reminder_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_model.dart';
import 'family_service.dart';

class MedicineReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FamilyService _familyService = FamilyService();

  static final MedicineReminderService _instance =
      MedicineReminderService._internal();
  factory MedicineReminderService() => _instance;
  MedicineReminderService._internal();

  // Add medicine
  Future<String> addMedicine(MedicineModel medicine) async {
    final docRef =
        await _firestore.collection('medicines').add(medicine.toMap());

    // Schedule notifications
    await scheduleNotifications(medicine.copyWith(id: docRef.id));

    return docRef.id;
  }

  // Update medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _firestore
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toMap());

    // Reschedule notifications
    await cancelNotifications(medicine.id);
    if (medicine.isActive) {
      await scheduleNotifications(medicine);
    }
  }

  // Delete medicine
  Future<void> deleteMedicine(String medicineId) async {
    await _firestore.collection('medicines').doc(medicineId).delete();
    await cancelNotifications(medicineId);
  }

  // Get all medicines for user
  Stream<List<MedicineModel>> getMedicinesStream(String userId) {
    return _firestore
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final medicines = snapshot.docs
          .map((doc) => MedicineModel.fromMap(doc.id, doc.data()))
          .toList();
      // Sort in memory instead of Firestore
      medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return medicines;
    });
  }

  // Mark medicine as taken
  Future<void> markAsTaken(
      String medicineId, String userId, DateTime scheduledTime) async {
    final takenTime = DateTime.now();
    final log = MedicineIntakeLog(
      id: '',
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      takenTime: takenTime,
      status: 'taken',
    );

    await _firestore.collection('medicine_logs').add(log.toMap());

    // Update stock count and schedule next interval notification
    final medicineDoc =
        await _firestore.collection('medicines').doc(medicineId).get();
    if (medicineDoc.exists) {
      final medicine =
          MedicineModel.fromMap(medicineDoc.id, medicineDoc.data()!);

      // Update stock
      if (medicine.stockCount != null && medicine.stockCount! > 0) {
        await _firestore.collection('medicines').doc(medicineId).update({
          'stockCount': medicine.stockCount! - 1,
        });
      }

      // Schedule next interval notification
      if (medicine.frequency == 'interval' && medicine.intervalHours != null) {
        await scheduleNextIntervalNotification(medicine, takenTime);
      }
    }
  }

  // Mark medicine as missed
  Future<void> markAsMissed(
      String medicineId, String userId, DateTime scheduledTime) async {
    final log = MedicineIntakeLog(
      id: '',
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      status: 'missed',
    );

    await _firestore.collection('medicine_logs').add(log.toMap());

    // Get medicine name for notification
    try {
      final medicineDoc =
          await _firestore.collection('medicines').doc(medicineId).get();

      if (medicineDoc.exists) {
        final medicine = MedicineModel.fromMap(medicineId, medicineDoc.data()!);

        // Notify caregivers about missed medicine
        await _familyService.notifyCaregivers(
          userId,
          medicine.medicineName,
          scheduledTime,
        );
      }
    } catch (e) {
      debugPrint('Error notifying caregivers: $e');
    }
  }

  // Get medicine logs
  Stream<List<MedicineIntakeLog>> getLogsStream(String userId,
      {int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection('medicine_logs')
        .where('userId', isEqualTo: userId)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MedicineIntakeLog.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Calculate adherence rate
  Future<double> calculateAdherence(String userId, {int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    final snapshot = await _firestore
        .collection('medicine_logs')
        .where('userId', isEqualTo: userId)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final takenCount =
        snapshot.docs.where((doc) => doc.data()['status'] == 'taken').length;
    return (takenCount / snapshot.docs.length) * 100;
  }

  // Schedule notifications for a medicine
  Future<void> scheduleNotifications(MedicineModel medicine) async {
    // For interval frequency, we don't pre-schedule notifications
    // Instead, we schedule the next notification dynamically after each intake
    if (medicine.frequency == 'interval' && medicine.intervalHours != null) {
      // Schedule first dose if no logs exist
      final logsSnapshot = await _firestore
          .collection('medicine_logs')
          .where('medicineId', isEqualTo: medicine.id)
          .where('userId', isEqualTo: medicine.userId)
          .limit(1)
          .get();

      if (logsSnapshot.docs.isEmpty) {
        // First dose - use first scheduled time or default to now
        final firstTime = medicine.scheduledTimes.isNotEmpty
            ? medicine.scheduledTimes[0]
            : '09:00';
        final parts = firstTime.split(':');
        final notificationId = medicine.id.hashCode;

        await _scheduleNotification(
          id: notificationId,
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
          title: '💊 Medicine Reminder',
          body: 'Time to take ${medicine.medicineName} - ${medicine.dosage}',
          payload: '${medicine.id}|$firstTime',
          matchComponents: DateTimeComponents.time, // Daily until first dose
        );
      }
      // After first intake, next notification will be scheduled dynamically
      return;
    }

    // For daily/weekly/custom frequency, schedule all times
    for (int i = 0; i < medicine.scheduledTimes.length; i++) {
      final timeStr = medicine.scheduledTimes[i];
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final notificationId = medicine.id.hashCode + i;

      await _scheduleNotification(
        id: notificationId,
        hour: hour,
        minute: minute,
        title: '💊 Medicine Reminder',
        body: 'Time to take ${medicine.medicineName} - ${medicine.dosage}',
        payload: '${medicine.id}|$timeStr',
        matchComponents: DateTimeComponents.time, // Daily
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
    String? payload,
    DateTimeComponents? matchComponents,
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
          'medicine_reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Notifications for medicine intake reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF009688),
          playSound: true,
          enableVibration: true,
          actions: [
            const AndroidNotificationAction(
              'mark_taken',
              'Mark Taken',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze 15m',
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents ?? DateTimeComponents.time,
      payload: payload,
    );
  }

  // Schedule next interval notification after taking medicine
  Future<void> scheduleNextIntervalNotification(
      MedicineModel medicine, DateTime lastTakenTime) async {
    if (medicine.frequency != 'interval' || medicine.intervalHours == null) {
      return;
    }

    final nextDoseTime =
        lastTakenTime.add(Duration(hours: medicine.intervalHours!));
    final notificationId = medicine.id.hashCode;

    // Cancel previous notification
    await _notifications.cancel(notificationId);

    // Schedule next notification
    final scheduledDate = tz.TZDateTime.from(nextDoseTime, tz.local);

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Medicine Reminder',
      'Time to take ${medicine.medicineName} - ${medicine.dosage}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Notifications for medicine intake reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF009688),
          playSound: true,
          enableVibration: true,
          actions: [
            const AndroidNotificationAction(
              'mark_taken',
              'Mark Taken',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze 15m',
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${medicine.id}|interval',
    );
  }

  // Cancel notifications for a medicine
  Future<void> cancelNotifications(String medicineId) async {
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel(medicineId.hashCode + i);
    }
  }

  // Get today's scheduled medicines
  Future<List<Map<String, dynamic>>> getTodaysSchedule(String userId) async {
    final snapshot = await _firestore
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    final List<Map<String, dynamic>> schedule = [];
    final today = DateTime.now();

    for (final doc in snapshot.docs) {
      final medicine = MedicineModel.fromMap(doc.id, doc.data());

      if (medicine.shouldTakeToday()) {
        // Handle interval frequency differently
        if (medicine.frequency == 'interval' &&
            medicine.intervalHours != null) {
          // Get the last taken log for this medicine
          final lastLogSnapshot = await _firestore
              .collection('medicine_logs')
              .where('medicineId', isEqualTo: medicine.id)
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'taken')
              .get();

          // Sort logs in memory by scheduledTime descending
          final sortedLogs = lastLogSnapshot.docs.toList();
          sortedLogs.sort((a, b) {
            final aTime = (a.data()['scheduledTime'] as Timestamp).toDate();
            final bTime = (b.data()['scheduledTime'] as Timestamp).toDate();
            return bTime.compareTo(aTime);
          });

          DateTime nextDoseTime;
          if (sortedLogs.isEmpty) {
            // First dose - use start date + first scheduled time
            final firstTime = medicine.scheduledTimes.isNotEmpty
                ? medicine.scheduledTimes[0]
                : '09:00';
            final parts = firstTime.split(':');
            nextDoseTime = DateTime(
              medicine.startDate.year,
              medicine.startDate.month,
              medicine.startDate.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          } else {
            // Calculate next dose from last taken time
            final lastTakenTime =
                (sortedLogs[0].data()['takenTime'] as Timestamp?)?.toDate() ??
                    (sortedLogs[0].data()['scheduledTime'] as Timestamp)
                        .toDate();
            nextDoseTime =
                lastTakenTime.add(Duration(hours: medicine.intervalHours!));
          }

          // Only show if next dose is due today or overdue
          if (nextDoseTime.year == today.year &&
              nextDoseTime.month == today.month &&
              nextDoseTime.day == today.day) {
            // Check if already taken at this specific time
            final logSnapshot = await _firestore
                .collection('medicine_logs')
                .where('medicineId', isEqualTo: medicine.id)
                .where('userId', isEqualTo: userId)
                .where('scheduledTime',
                    isEqualTo: Timestamp.fromDate(nextDoseTime))
                .limit(1)
                .get();

            final status = logSnapshot.docs.isNotEmpty
                ? logSnapshot.docs.first.data()['status']
                : 'pending';

            schedule.add({
              'medicine': medicine,
              'scheduledTime': nextDoseTime,
              'status': status,
            });
          }
        } else {
          // Handle daily/weekly/custom frequency with scheduled times
          for (final timeStr in medicine.scheduledTimes) {
            final parts = timeStr.split(':');
            final scheduledTime = DateTime(
              today.year,
              today.month,
              today.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );

            // Check if already taken
            final logSnapshot = await _firestore
                .collection('medicine_logs')
                .where('medicineId', isEqualTo: medicine.id)
                .where('userId', isEqualTo: userId)
                .where('scheduledTime',
                    isEqualTo: Timestamp.fromDate(scheduledTime))
                .limit(1)
                .get();

            final status = logSnapshot.docs.isNotEmpty
                ? logSnapshot.docs.first.data()['status']
                : 'pending';

            schedule.add({
              'medicine': medicine,
              'scheduledTime': scheduledTime,
              'status': status,
            });
          }
        }
      }
    }

    // Sort by time
    schedule.sort((a, b) => (a['scheduledTime'] as DateTime)
        .compareTo(b['scheduledTime'] as DateTime));

    return schedule;
  }

  // Get detailed statistics
  Future<Map<String, dynamic>> getDetailedStatistics(
      String userId, int days) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      // Get all logs in date range - removed orderBy to avoid index requirement
      final logsSnapshot = await _firestore
          .collection('medicine_logs')
          .where('userId', isEqualTo: userId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      // Sort in memory
      final sortedDocs = logsSnapshot.docs.toList();
      sortedDocs.sort((a, b) {
        final aTime = (a.data()['scheduledTime'] as Timestamp).toDate();
        final bTime = (b.data()['scheduledTime'] as Timestamp).toDate();
        return bTime.compareTo(aTime); // descending
      });

      final totalDoses = sortedDocs.length;
      final takenDoses =
          sortedDocs.where((doc) => doc.data()['status'] == 'taken').length;
      final missedDoses =
          sortedDocs.where((doc) => doc.data()['status'] == 'missed').length;

      // Get active medicines count
      final medicinesSnapshot = await _firestore
          .collection('medicines')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final activeMedicines = medicinesSnapshot.docs.length;

      // Get medicine-wise stats
      final medicineStats = <Map<String, dynamic>>[];
      for (final medDoc in medicinesSnapshot.docs) {
        final medicine = MedicineModel.fromMap(medDoc.id, medDoc.data());

        final medLogs = sortedDocs
            .where((log) => log.data()['medicineId'] == medicine.id)
            .toList();

        if (medLogs.isNotEmpty) {
          final medTaken =
              medLogs.where((log) => log.data()['status'] == 'taken').length;

          medicineStats.add({
            'medicineName': medicine.medicineName,
            'total': medLogs.length,
            'taken': medTaken,
            'missed': medLogs.length - medTaken,
          });
        }
      }

      // Get recent logs with medicine names
      final recentLogs = <Map<String, dynamic>>[];
      for (final log in sortedDocs.take(10)) {
        final logData = log.data();
        final medicineId = logData['medicineId'];

        final medDoc =
            await _firestore.collection('medicines').doc(medicineId).get();
        if (medDoc.exists) {
          final medicineName = medDoc.data()?['medicineName'] ?? 'Unknown';

          recentLogs.add({
            'medicineName': medicineName,
            'scheduledTime': logData['scheduledTime'],
            'takenTime': logData['takenTime'],
            'status': logData['status'],
          });
        }
      }

      return {
        'totalDoses': totalDoses,
        'takenDoses': takenDoses,
        'missedDoses': missedDoses,
        'activeMedicines': activeMedicines,
        'medicineStats': medicineStats,
        'recentLogs': recentLogs,
      };
    } catch (e) {
      print('Error in getDetailedStatistics: $e');
      // Return empty stats on error
      return {
        'totalDoses': 0,
        'takenDoses': 0,
        'missedDoses': 0,
        'activeMedicines': 0,
        'medicineStats': [],
        'recentLogs': [],
      };
    }
  }
}
