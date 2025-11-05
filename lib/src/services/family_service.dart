// lib/src/services/family_service.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/family_member_model.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  // Add family member
  Future<String> addFamilyMember(FamilyMemberModel member) async {
    final docRef =
        await _firestore.collection('family_members').add(member.toMap());
    return docRef.id;
  }

  // Update family member
  Future<void> updateFamilyMember(FamilyMemberModel member) async {
    await _firestore
        .collection('family_members')
        .doc(member.id)
        .update(member.copyWith(lastModified: DateTime.now()).toMap());
  }

  // Delete family member
  Future<void> deleteFamilyMember(String memberId) async {
    await _firestore.collection('family_members').doc(memberId).delete();
  }

  // Get all family members for a user
  Stream<List<FamilyMemberModel>> getFamilyMembersStream(String userId) {
    return _firestore
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final members = snapshot.docs
          .map((doc) => FamilyMemberModel.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by created date descending
      members.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return members;
    });
  }

  // Get family members who are caregivers
  Stream<List<FamilyMemberModel>> getCaregiversStream(String userId) {
    return _firestore
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .where('isCaregiver', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FamilyMemberModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Add caregiver permission
  Future<void> addCaregiverPermission(
      String memberId, String patientUserId) async {
    final memberDoc =
        await _firestore.collection('family_members').doc(memberId).get();

    if (memberDoc.exists) {
      final member = FamilyMemberModel.fromMap(memberDoc.id, memberDoc.data()!);
      final updatedIds = List<String>.from(member.caregiverForUserIds);

      if (!updatedIds.contains(patientUserId)) {
        updatedIds.add(patientUserId);
        await _firestore.collection('family_members').doc(memberId).update({
          'caregiverForUserIds': updatedIds,
          'isCaregiver': true,
          'lastModified': Timestamp.fromDate(DateTime.now()),
        });
      }
    }
  }

  // Remove caregiver permission
  Future<void> removeCaregiverPermission(
      String memberId, String patientUserId) async {
    final memberDoc =
        await _firestore.collection('family_members').doc(memberId).get();

    if (memberDoc.exists) {
      final member = FamilyMemberModel.fromMap(memberDoc.id, memberDoc.data()!);
      final updatedIds = List<String>.from(member.caregiverForUserIds);

      updatedIds.remove(patientUserId);
      await _firestore.collection('family_members').doc(memberId).update({
        'caregiverForUserIds': updatedIds,
        'isCaregiver': updatedIds.isNotEmpty,
        'lastModified': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // Send notification to caregivers when medicine missed
  Future<void> notifyCaregivers(
    String userId,
    String medicineName,
    DateTime missedTime,
  ) async {
    // Get all caregivers for this user
    final snapshot = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .where('isCaregiver', isEqualTo: true)
        .where('canReceiveNotifications', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      final caregiver = FamilyMemberModel.fromMap(doc.id, doc.data());

      // Send notification (using local notifications for now)
      // In production, you'd use Firebase Cloud Messaging to send to caregiver's device
      await _sendCaregiverNotification(
        caregiver: caregiver,
        medicineName: medicineName,
        missedTime: missedTime,
      );
    }
  }

  // Send caregiver notification
  Future<void> _sendCaregiverNotification({
    required FamilyMemberModel caregiver,
    required String medicineName,
    required DateTime missedTime,
  }) async {
    final notificationId = caregiver.id.hashCode + DateTime.now().hashCode;

    await _notifications.show(
      notificationId,
      '⚠️ Medicine Reminder Alert',
      '${caregiver.name} missed taking $medicineName at ${_formatTime(missedTime)}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'caregiver_alert_channel',
          'Caregiver Alerts',
          channelDescription:
              'Notifications for caregivers about missed medicines',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFFFF9800),
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Format time for notification
  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Get family member by ID
  Future<FamilyMemberModel?> getFamilyMember(String memberId) async {
    final doc =
        await _firestore.collection('family_members').doc(memberId).get();

    if (doc.exists) {
      return FamilyMemberModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Search family members
  Future<List<FamilyMemberModel>> searchFamilyMembers(
    String userId,
    String query,
  ) async {
    final snapshot = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .get();

    final members = snapshot.docs
        .map((doc) => FamilyMemberModel.fromMap(doc.id, doc.data()))
        .where((member) =>
            member.name.toLowerCase().contains(query.toLowerCase()) ||
            member.relationship.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return members;
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    final snapshot = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: userId)
        .get();

    final members = snapshot.docs
        .map((doc) => FamilyMemberModel.fromMap(doc.id, doc.data()))
        .toList();

    final totalMembers = members.length;
    final caregivers = members.where((m) => m.isCaregiver).length;
    final withNotifications =
        members.where((m) => m.canReceiveNotifications).length;

    return {
      'totalMembers': totalMembers,
      'caregivers': caregivers,
      'withNotifications': withNotifications,
    };
  }
}
