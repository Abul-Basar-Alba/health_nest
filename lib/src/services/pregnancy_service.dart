import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bump_photo_model.dart';
import '../models/contraction_log_model.dart';
import '../models/doctor_visit_model.dart';
import '../models/kick_count_model.dart';
import '../models/postpartum_log_model.dart';
import '../models/pregnancy_family_member_model.dart';
import '../models/pregnancy_model.dart';
import '../models/symptom_log_model.dart';

class PregnancyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  String get _pregnanciesCollection => 'pregnancies';
  String get _symptomLogsCollection => 'symptom_logs';
  String get _kickCountsCollection => 'kick_counts';
  String get _contractionsCollection => 'contractions';
  String get _doctorVisitsCollection => 'doctor_visits';
  String get _familyMembersCollection => 'pregnancy_family_members';
  String get _bumpPhotosCollection => 'bump_photos';
  String get _postpartumLogsCollection => 'postpartum_logs';

  // ===== PREGNANCY CRUD =====

  // Create new pregnancy
  Future<String> createPregnancy(PregnancyModel pregnancy) async {
    try {
      final docRef = await _firestore
          .collection(_pregnanciesCollection)
          .add(pregnancy.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pregnancy: $e');
    }
  }

  // Get active pregnancy for user
  Future<PregnancyModel?> getActivePregnancy(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_pregnanciesCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return PregnancyModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Failed to get active pregnancy: $e');
    }
  }

  // Get all pregnancies for user (including archived)
  Future<List<PregnancyModel>> getAllPregnancies(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_pregnanciesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PregnancyModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pregnancies: $e');
    }
  }

  // Update pregnancy
  Future<void> updatePregnancy(PregnancyModel pregnancy) async {
    try {
      await _firestore
          .collection(_pregnanciesCollection)
          .doc(pregnancy.id)
          .update(pregnancy.toMap());
    } catch (e) {
      throw Exception('Failed to update pregnancy: $e');
    }
  }

  // Archive pregnancy (mark as inactive)
  Future<void> archivePregnancy(String pregnancyId) async {
    try {
      await _firestore
          .collection(_pregnanciesCollection)
          .doc(pregnancyId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to archive pregnancy: $e');
    }
  }

  // End pregnancy (mark as inactive) - alias for archivePregnancy
  Future<void> endPregnancy(String pregnancyId) async {
    await archivePregnancy(pregnancyId);
  }

  // Delete pregnancy
  Future<void> deletePregnancy(String pregnancyId) async {
    try {
      await _firestore
          .collection(_pregnanciesCollection)
          .doc(pregnancyId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete pregnancy: $e');
    }
  }

  // ===== SYMPTOM LOGS =====

  // Add symptom log
  Future<String> addSymptomLog(SymptomLogModel log) async {
    try {
      final docRef =
          await _firestore.collection(_symptomLogsCollection).add(log.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add symptom log: $e');
    }
  }

  // Get symptom logs for pregnancy
  Future<List<SymptomLogModel>> getSymptomLogs(String pregnancyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_symptomLogsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('logDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SymptomLogModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get symptom logs: $e');
    }
  }

  // Get symptom logs for date range
  Future<List<SymptomLogModel>> getSymptomLogsByDateRange(
    String pregnancyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_symptomLogsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('logDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('logDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('logDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SymptomLogModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get symptom logs by date: $e');
    }
  }

  // Delete symptom log
  Future<void> deleteSymptomLog(String logId) async {
    try {
      await _firestore.collection(_symptomLogsCollection).doc(logId).delete();
    } catch (e) {
      throw Exception('Failed to delete symptom log: $e');
    }
  }

  // ===== KICK COUNTS =====

  // Add kick count session
  Future<String> addKickCount(KickCountModel kickCount) async {
    try {
      final docRef = await _firestore
          .collection(_kickCountsCollection)
          .add(kickCount.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add kick count: $e');
    }
  }

  // Update kick count session
  Future<void> updateKickCount(KickCountModel kickCount) async {
    try {
      await _firestore
          .collection(_kickCountsCollection)
          .doc(kickCount.id)
          .update(kickCount.toMap());
    } catch (e) {
      throw Exception('Failed to update kick count: $e');
    }
  }

  // Get kick count history
  Future<List<KickCountModel>> getKickCounts(String pregnancyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_kickCountsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('startTime', descending: true)
          .limit(30) // Last 30 sessions
          .get();

      return querySnapshot.docs
          .map((doc) => KickCountModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get kick counts: $e');
    }
  }

  // Delete kick count session
  Future<void> deleteKickCount(String kickCountId) async {
    try {
      await _firestore
          .collection(_kickCountsCollection)
          .doc(kickCountId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete kick count: $e');
    }
  }

  // ===== CONTRACTIONS =====

  // Add contraction
  Future<String> addContraction(ContractionLogModel contraction) async {
    try {
      final docRef = await _firestore
          .collection(_contractionsCollection)
          .add(contraction.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add contraction: $e');
    }
  }

  // Update contraction
  Future<void> updateContraction(ContractionLogModel contraction) async {
    try {
      await _firestore
          .collection(_contractionsCollection)
          .doc(contraction.id)
          .update(contraction.toMap());
    } catch (e) {
      throw Exception('Failed to update contraction: $e');
    }
  }

  // Get contractions for today
  Future<List<ContractionLogModel>> getTodayContractions(
      String pregnancyId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(_contractionsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ContractionLogModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today\'s contractions: $e');
    }
  }

  // Get all contractions
  Future<List<ContractionLogModel>> getContractions(String pregnancyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_contractionsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('startTime', descending: true)
          .limit(50) // Last 50 contractions
          .get();

      return querySnapshot.docs
          .map((doc) => ContractionLogModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get contractions: $e');
    }
  }

  // Delete contraction
  Future<void> deleteContraction(String contractionId) async {
    try {
      await _firestore
          .collection(_contractionsCollection)
          .doc(contractionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete contraction: $e');
    }
  }

  // Clear all contractions for the day (reset button)
  Future<void> clearTodayContractions(String pregnancyId) async {
    try {
      final contractions = await getTodayContractions(pregnancyId);

      // Delete all today's contractions
      final batch = _firestore.batch();
      for (final contraction in contractions) {
        batch.delete(
            _firestore.collection(_contractionsCollection).doc(contraction.id));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear contractions: $e');
    }
  }

  // ===== DOCTOR VISITS =====

  // Add doctor visit
  Future<String> addDoctorVisit(DoctorVisitModel visit) async {
    try {
      final docRef = await _firestore
          .collection(_doctorVisitsCollection)
          .add(visit.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add doctor visit: $e');
    }
  }

  // Update doctor visit
  Future<void> updateDoctorVisit(DoctorVisitModel visit) async {
    try {
      await _firestore
          .collection(_doctorVisitsCollection)
          .doc(visit.id)
          .update(visit.toMap());
    } catch (e) {
      throw Exception('Failed to update doctor visit: $e');
    }
  }

  // Get all visits for pregnancy
  Future<List<DoctorVisitModel>> getDoctorVisits(
    String userId,
    String pregnancyId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_doctorVisitsCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('visitDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => DoctorVisitModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctor visits: $e');
    }
  }

  // Get upcoming visits
  Future<List<DoctorVisitModel>> getUpcomingVisits(
    String userId,
    String pregnancyId,
  ) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_doctorVisitsCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('visitDate', isGreaterThan: Timestamp.fromDate(now))
          .where('isCompleted', isEqualTo: false)
          .orderBy('visitDate', descending: false)
          .limit(5)
          .get();

      return querySnapshot.docs
          .map((doc) => DoctorVisitModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming visits: $e');
    }
  }

  // Mark visit as completed
  Future<void> completeVisit(String visitId) async {
    try {
      await _firestore
          .collection(_doctorVisitsCollection)
          .doc(visitId)
          .update({'isCompleted': true});
    } catch (e) {
      throw Exception('Failed to complete visit: $e');
    }
  }

  // Delete visit
  Future<void> deleteDoctorVisit(String visitId) async {
    try {
      await _firestore
          .collection(_doctorVisitsCollection)
          .doc(visitId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete visit: $e');
    }
  }

  // Stream of doctor visits
  Stream<List<DoctorVisitModel>> getDoctorVisitsStream(
    String userId,
    String pregnancyId,
  ) {
    return _firestore
        .collection(_doctorVisitsCollection)
        .where('userId', isEqualTo: userId)
        .where('pregnancyId', isEqualTo: pregnancyId)
        .orderBy('visitDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorVisitModel.fromMap(doc.data()))
            .toList());
  }

  // ===== FAMILY MEMBERS =====

  // Add family member
  Future<String> addFamilyMember(PregnancyFamilyMemberModel member) async {
    try {
      final docRef = await _firestore
          .collection(_familyMembersCollection)
          .add(member.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add family member: $e');
    }
  }

  // Update family member
  Future<void> updateFamilyMember(PregnancyFamilyMemberModel member) async {
    try {
      await _firestore
          .collection(_familyMembersCollection)
          .doc(member.id)
          .update(member.toMap());
    } catch (e) {
      throw Exception('Failed to update family member: $e');
    }
  }

  // Get all family members for pregnancy
  Future<List<PregnancyFamilyMemberModel>> getFamilyMembers(
      String pregnancyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_familyMembersCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PregnancyFamilyMemberModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get family members: $e');
    }
  }

  // Remove family member
  Future<void> removeFamilyMember(String memberId) async {
    try {
      await _firestore
          .collection(_familyMembersCollection)
          .doc(memberId)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to remove family member: $e');
    }
  }

  // Delete family member permanently
  Future<void> deleteFamilyMember(String memberId) async {
    try {
      await _firestore
          .collection(_familyMembersCollection)
          .doc(memberId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete family member: $e');
    }
  }

  // Stream of family members
  Stream<List<PregnancyFamilyMemberModel>> getFamilyMembersStream(
      String pregnancyId) {
    return _firestore
        .collection(_familyMembersCollection)
        .where('pregnancyId', isEqualTo: pregnancyId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PregnancyFamilyMemberModel.fromMap(doc.data()))
            .toList());
  }

  // Send notification to family members
  Future<void> notifyFamilyMembers(
    String pregnancyId,
    String notificationType,
    String title,
    String message,
  ) async {
    try {
      final members = await getFamilyMembers(pregnancyId);

      for (final member in members) {
        if (member.receiveNotifications &&
            member.notificationTypes.contains(notificationType)) {
          // Send notification to this member
          // This will integrate with your existing notification service
          await _sendNotificationToUser(
            member.userId,
            title,
            message,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to notify family members: $e');
    }
  }

  // Helper method to send notification (to be integrated with your notification service)
  Future<void> _sendNotificationToUser(
    String userId,
    String title,
    String message,
  ) async {
    // This will use your existing Firebase Cloud Messaging
    // For now, we'll store it in a notifications collection
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'pregnancy',
      });
    } catch (e) {
      // Silently fail for now
    }
  }

  // ===== BUMP PHOTOS =====

  // Add bump photo
  Future<String> addBumpPhoto(BumpPhotoModel photo) async {
    try {
      // Generate a unique ID
      final docRef = _firestore.collection(_bumpPhotosCollection).doc();

      // Update photo with the generated ID
      final photoWithId = photo.copyWith(id: docRef.id);

      // Save to Firestore
      await docRef.set(photoWithId.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add bump photo: $e');
    }
  }

  // Update bump photo
  Future<void> updateBumpPhoto(BumpPhotoModel photo) async {
    try {
      await _firestore
          .collection(_bumpPhotosCollection)
          .doc(photo.id)
          .update(photo.toMap());
    } catch (e) {
      throw Exception('Failed to update bump photo: $e');
    }
  }

  // Get all bump photos for pregnancy
  Future<List<BumpPhotoModel>> getBumpPhotos(
    String userId,
    String pregnancyId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bumpPhotosCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('week', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return BumpPhotoModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bump photos: $e');
    }
  }

  // Get bump photo by week
  Future<BumpPhotoModel?> getBumpPhotoByWeek(
    String userId,
    String pregnancyId,
    int week,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bumpPhotosCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('week', isEqualTo: week)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id; // Include document ID
      return BumpPhotoModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get bump photo: $e');
    }
  }

  // Delete bump photo
  Future<void> deleteBumpPhoto(String photoId) async {
    try {
      await _firestore.collection(_bumpPhotosCollection).doc(photoId).delete();
    } catch (e) {
      throw Exception('Failed to delete bump photo: $e');
    }
  }

  // Stream of bump photos
  Stream<List<BumpPhotoModel>> getBumpPhotosStream(
    String userId,
    String pregnancyId,
  ) {
    return _firestore
        .collection(_bumpPhotosCollection)
        .where('userId', isEqualTo: userId)
        .where('pregnancyId', isEqualTo: pregnancyId)
        .orderBy('week', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Include document ID
              return BumpPhotoModel.fromMap(data);
            }).toList());
  }

  // Get photo comparison (current week vs previous weeks)
  Future<List<BumpPhotoModel>> getPhotoComparison(
    String userId,
    String pregnancyId,
    int currentWeek,
  ) async {
    try {
      // Get photos from milestone weeks: 8, 12, 16, 20, 24, 28, 32, 36, 40
      final milestoneWeeks = [8, 12, 16, 20, 24, 28, 32, 36, 40]
          .where((w) => w <= currentWeek)
          .toList();

      final photos = <BumpPhotoModel>[];

      for (final week in milestoneWeeks) {
        final photo = await getBumpPhotoByWeek(userId, pregnancyId, week);
        if (photo != null) {
          photos.add(photo);
        }
      }

      return photos;
    } catch (e) {
      throw Exception('Failed to get photo comparison: $e');
    }
  }

  // ===== POSTPARTUM LOGS =====

  // Add postpartum log
  Future<String> addPostpartumLog(PostpartumLogModel log) async {
    try {
      final docRef = await _firestore
          .collection(_postpartumLogsCollection)
          .add(log.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add postpartum log: $e');
    }
  }

  // Update postpartum log
  Future<void> updatePostpartumLog(PostpartumLogModel log) async {
    try {
      await _firestore
          .collection(_postpartumLogsCollection)
          .doc(log.id)
          .update(log.toMap());
    } catch (e) {
      throw Exception('Failed to update postpartum log: $e');
    }
  }

  // Get all postpartum logs
  Future<List<PostpartumLogModel>> getPostpartumLogs(
    String userId,
    String pregnancyId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_postpartumLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .orderBy('logDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostpartumLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get postpartum logs: $e');
    }
  }

  // Get logs by type
  Future<List<PostpartumLogModel>> getPostpartumLogsByType(
    String userId,
    String pregnancyId,
    PostpartumLogType type,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_postpartumLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('type', isEqualTo: type.name)
          .orderBy('logDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostpartumLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get postpartum logs by type: $e');
    }
  }

  // Get logs by date range
  Future<List<PostpartumLogModel>> getPostpartumLogsByDateRange(
    String userId,
    String pregnancyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_postpartumLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .where('logDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('logDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('logDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostpartumLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get postpartum logs by date range: $e');
    }
  }

  // Delete postpartum log
  Future<void> deletePostpartumLog(String logId) async {
    try {
      await _firestore
          .collection(_postpartumLogsCollection)
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete postpartum log: $e');
    }
  }

  // Stream of postpartum logs
  Stream<List<PostpartumLogModel>> getPostpartumLogsStream(
    String userId,
    String pregnancyId,
  ) {
    return _firestore
        .collection(_postpartumLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('pregnancyId', isEqualTo: pregnancyId)
        .orderBy('logDate', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostpartumLogModel.fromMap(doc.data()))
            .toList());
  }

  // Get today's logs
  Future<List<PostpartumLogModel>> getTodayPostpartumLogs(
    String userId,
    String pregnancyId,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getPostpartumLogsByDateRange(
      userId,
      pregnancyId,
      startOfDay,
      endOfDay,
    );
  }

  // Get feeding statistics
  Future<Map<String, dynamic>> getFeedingStatistics(
    String userId,
    String pregnancyId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final logs = await getPostpartumLogsByDateRange(
        userId,
        pregnancyId,
        startOfDay,
        endOfDay,
      );

      final breastfeedingLogs = logs
          .where((log) => log.type == PostpartumLogType.breastfeeding)
          .toList();
      final bottleLogs = logs
          .where((log) => log.type == PostpartumLogType.bottleFeeding)
          .toList();

      int totalBreastfeedingDuration = 0;
      for (final log in breastfeedingLogs) {
        totalBreastfeedingDuration += log.feedingDuration ?? 0;
      }

      double totalBottleAmount = 0;
      for (final log in bottleLogs) {
        totalBottleAmount += log.bottleAmount ?? 0;
      }

      return {
        'breastfeedingCount': breastfeedingLogs.length,
        'breastfeedingDuration': totalBreastfeedingDuration,
        'bottleFeedingCount': bottleLogs.length,
        'bottleAmount': totalBottleAmount,
      };
    } catch (e) {
      throw Exception('Failed to get feeding statistics: $e');
    }
  }

  // ===== BULK DELETE METHODS (for resetting pregnancy) =====

  // Delete all symptom logs for a pregnancy
  Future<void> deleteAllSymptomLogs(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_symptomLogsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete symptom logs: $e');
    }
  }

  // Delete all kick counts for a pregnancy
  Future<void> deleteAllKickCounts(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_kickCountsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete kick counts: $e');
    }
  }

  // Delete all contractions for a pregnancy
  Future<void> deleteAllContractions(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_contractionsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete contractions: $e');
    }
  }

  // Delete all doctor visits for a pregnancy
  Future<void> deleteAllDoctorVisits(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_doctorVisitsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete doctor visits: $e');
    }
  }

  // Delete all family members for a pregnancy
  Future<void> deleteAllFamilyMembers(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_familyMembersCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete family members: $e');
    }
  }

  // Delete all bump photos for a pregnancy
  Future<void> deleteAllBumpPhotos(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_bumpPhotosCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete bump photos: $e');
    }
  }

  // Delete all postpartum logs for a pregnancy
  Future<void> deleteAllPostpartumLogs(String pregnancyId) async {
    try {
      final snapshot = await _firestore
          .collection(_postpartumLogsCollection)
          .where('pregnancyId', isEqualTo: pregnancyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete postpartum logs: $e');
    }
  }
}
