import 'package:flutter/material.dart';

import '../data/weekly_development_data.dart';
import '../models/baby_development_model.dart';
import '../models/bump_photo_model.dart';
import '../models/contraction_log_model.dart';
import '../models/doctor_visit_model.dart';
import '../models/kick_count_model.dart';
import '../models/postpartum_log_model.dart';
import '../models/pregnancy_family_member_model.dart';
import '../models/pregnancy_model.dart';
import '../models/symptom_log_model.dart';
import '../services/pregnancy_calculator.dart';
import '../services/pregnancy_service.dart';
import '../services/storage_service.dart';

class PregnancyProvider with ChangeNotifier {
  final PregnancyService _service = PregnancyService();

  PregnancyModel? _activePregnancy;
  List<SymptomLogModel> _symptomLogs = [];
  List<KickCountModel> _kickCounts = [];
  List<ContractionLogModel> _contractions = [];
  List<DoctorVisitModel> _doctorVisits = [];
  List<PregnancyFamilyMemberModel> _familyMembers = [];
  List<BumpPhotoModel> _bumpPhotos = [];
  List<PostpartumLogModel> _postpartumLogs = [];
  bool _isLoading = false;
  String? _error;

  // Language preference (true = Bangla, false = English)
  bool _isBangla = false;

  // Getters
  PregnancyModel? get activePregnancy => _activePregnancy;
  List<SymptomLogModel> get symptomLogs => _symptomLogs;
  List<KickCountModel> get kickCounts => _kickCounts;
  List<ContractionLogModel> get contractions => _contractions;
  List<DoctorVisitModel> get doctorVisits => _doctorVisits;
  List<PregnancyFamilyMemberModel> get familyMembers => _familyMembers;
  List<BumpPhotoModel> get bumpPhotos => _bumpPhotos;
  List<PostpartumLogModel> get postpartumLogs => _postpartumLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBangla => _isBangla;
  bool get hasActivePregnancy => _activePregnancy != null;

  // Toggle language
  void toggleLanguage() {
    _isBangla = !_isBangla;
    notifyListeners();
  }

  void setLanguage(bool isBangla) {
    _isBangla = isBangla;
    notifyListeners();
  }

  // Get current week
  int get currentWeek {
    if (_activePregnancy == null) return 1;
    return _activePregnancy!.getCurrentWeek();
  }

  // Get current week data
  BabyDevelopmentModel? getCurrentWeekData() {
    if (_activePregnancy == null) return null;
    final week = _activePregnancy!.getCurrentWeek();
    return WeeklyDevelopmentData.getWeekData(week);
  }

  // ===== PREGNANCY MANAGEMENT =====

  // Load active pregnancy
  Future<void> loadActivePregnancy(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activePregnancy = await _service.getActivePregnancy(userId);

      if (_activePregnancy != null) {
        // Load related data
        await Future.wait([
          loadSymptomLogs(_activePregnancy!.id),
          loadKickCounts(_activePregnancy!.id),
          loadContractions(_activePregnancy!.id),
        ]);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new pregnancy
  Future<bool> createPregnancy({
    required String userId,
    required DateTime lastPeriodDate,
    String? babyName,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dueDate = PregnancyCalculator.calculateDueDate(lastPeriodDate);

      final pregnancy = PregnancyModel(
        id: '',
        userId: userId,
        lastPeriodDate: lastPeriodDate,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        babyName: babyName,
        notes: notes,
        isActive: true,
      );

      final id = await _service.createPregnancy(pregnancy);
      _activePregnancy = pregnancy.copyWith(id: id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update pregnancy
  Future<bool> updatePregnancy({
    DateTime? lastPeriodDate,
    String? babyName,
    String? notes,
  }) async {
    if (_activePregnancy == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DateTime? newDueDate;
      if (lastPeriodDate != null) {
        newDueDate = PregnancyCalculator.calculateDueDate(lastPeriodDate);
      }

      final updatedPregnancy = _activePregnancy!.copyWith(
        lastPeriodDate: lastPeriodDate,
        dueDate: newDueDate,
        babyName: babyName,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      await _service.updatePregnancy(updatedPregnancy);
      _activePregnancy = updatedPregnancy;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Archive pregnancy
  Future<bool> archivePregnancy() async {
    if (_activePregnancy == null) return false;

    try {
      await _service.archivePregnancy(_activePregnancy!.id);
      _activePregnancy = null;
      _symptomLogs = [];
      _kickCounts = [];
      _contractions = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // End pregnancy (mark as inactive)
  Future<bool> endPregnancy(String pregnancyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.endPregnancy(pregnancyId);
      _activePregnancy = null;
      _symptomLogs = [];
      _kickCounts = [];
      _contractions = [];
      _doctorVisits = [];
      _familyMembers = [];
      _bumpPhotos = [];
      _postpartumLogs = [];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete pregnancy completely (including all related data)
  Future<bool> deletePregnancy(String pregnancyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete all related data first
      await Future.wait([
        _service.deleteAllSymptomLogs(pregnancyId),
        _service.deleteAllKickCounts(pregnancyId),
        _service.deleteAllContractions(pregnancyId),
        _service.deleteAllDoctorVisits(pregnancyId),
        _service.deleteAllFamilyMembers(pregnancyId),
        _service.deleteAllBumpPhotos(pregnancyId),
        _service.deleteAllPostpartumLogs(pregnancyId),
      ]);

      // Then delete the pregnancy itself
      await _service.deletePregnancy(pregnancyId);

      // Clear local state
      _activePregnancy = null;
      _symptomLogs = [];
      _kickCounts = [];
      _contractions = [];
      _doctorVisits = [];
      _familyMembers = [];
      _bumpPhotos = [];
      _postpartumLogs = [];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== SYMPTOM LOGS =====

  Future<void> loadSymptomLogs(String pregnancyId) async {
    try {
      _symptomLogs = await _service.getSymptomLogs(pregnancyId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addSymptomLog({
    required List<String> symptoms,
    required String severity,
    String? notes,
  }) async {
    if (_activePregnancy == null) return false;

    try {
      final log = SymptomLogModel(
        id: '',
        pregnancyId: _activePregnancy!.id,
        userId: _activePregnancy!.userId,
        logDate: DateTime.now(),
        symptoms: symptoms,
        severity: severity,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final id = await _service.addSymptomLog(log);
      _symptomLogs.insert(0, log.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSymptomLog(String logId) async {
    try {
      await _service.deleteSymptomLog(logId);
      _symptomLogs.removeWhere((log) => log.id == logId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===== KICK COUNTS =====

  Future<void> loadKickCounts(String pregnancyId) async {
    try {
      _kickCounts = await _service.getKickCounts(pregnancyId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> startKickCountSession() async {
    if (_activePregnancy == null) return null;

    try {
      final kickCount = KickCountModel(
        id: '',
        pregnancyId: _activePregnancy!.id,
        userId: _activePregnancy!.userId,
        startTime: DateTime.now(),
        kickCount: 0,
        durationMinutes: 0,
        createdAt: DateTime.now(),
      );

      final id = await _service.addKickCount(kickCount);
      _kickCounts.insert(0, kickCount.copyWith(id: id));
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateKickCount(String id, int kickCount) async {
    try {
      final index = _kickCounts.indexWhere((k) => k.id == id);
      if (index == -1) return false;

      final kickCountModel = _kickCounts[index];
      final duration =
          DateTime.now().difference(kickCountModel.startTime).inMinutes;

      final updated = kickCountModel.copyWith(
        kickCount: kickCount,
        durationMinutes: duration,
        endTime: kickCount >= 10 ? DateTime.now() : null,
      );

      await _service.updateKickCount(updated);
      _kickCounts[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteKickCount(String id) async {
    try {
      await _service.deleteKickCount(id);
      _kickCounts.removeWhere((k) => k.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===== CONTRACTIONS =====

  Future<void> loadContractions(String pregnancyId) async {
    try {
      _contractions = await _service.getTodayContractions(pregnancyId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> addContraction({
    required int durationSeconds,
    required String intensity,
  }) async {
    if (_activePregnancy == null) return null;

    try {
      // Calculate interval from last contraction
      int? intervalMinutes;
      if (_contractions.isNotEmpty) {
        final lastContraction = _contractions.first;
        intervalMinutes =
            DateTime.now().difference(lastContraction.startTime).inMinutes;
      }

      final contraction = ContractionLogModel(
        id: '',
        pregnancyId: _activePregnancy!.id,
        userId: _activePregnancy!.userId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(seconds: durationSeconds)),
        durationSeconds: durationSeconds,
        intervalMinutes: intervalMinutes,
        intensity: intensity,
        createdAt: DateTime.now(),
      );

      final id = await _service.addContraction(contraction);
      _contractions.insert(0, contraction.copyWith(id: id));
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteContraction(String id) async {
    try {
      await _service.deleteContraction(id);
      _contractions.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearAllContractions() async {
    if (_activePregnancy == null) return false;

    try {
      await _service.clearTodayContractions(_activePregnancy!.id);
      _contractions = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if contractions indicate active labor
  bool isActiveLaborPattern() {
    return ContractionLogModel.isActiveLaborPattern(_contractions);
  }

  // ===== DOCTOR VISITS =====

  // Load doctor visits
  Future<void> loadDoctorVisits(String userId, String pregnancyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _doctorVisits = await _service.getDoctorVisits(userId, pregnancyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add doctor visit
  Future<void> addDoctorVisit(DoctorVisitModel visit) async {
    try {
      _isLoading = true;
      notifyListeners();

      final visitId = await _service.addDoctorVisit(visit);
      final newVisit = visit.copyWith(id: visitId);
      _doctorVisits.add(newVisit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete visit
  Future<void> completeVisit(String visitId) async {
    try {
      await _service.completeVisit(visitId);

      final index = _doctorVisits.indexWhere((v) => v.id == visitId);
      if (index != -1) {
        _doctorVisits[index] = _doctorVisits[index].copyWith(isCompleted: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete doctor visit
  Future<void> deleteDoctorVisit(String visitId) async {
    try {
      await _service.deleteDoctorVisit(visitId);
      _doctorVisits.removeWhere((v) => v.id == visitId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get upcoming visits
  List<DoctorVisitModel> getUpcomingVisits() {
    final now = DateTime.now();
    return _doctorVisits
        .where((v) => v.visitDate.isAfter(now) && !v.isCompleted)
        .toList()
      ..sort((a, b) => a.visitDate.compareTo(b.visitDate));
  }

  // ===== FAMILY MEMBERS =====

  // Load family members
  Future<void> loadFamilyMembers(String pregnancyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _familyMembers = await _service.getFamilyMembers(pregnancyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add family member
  Future<void> addFamilyMember(PregnancyFamilyMemberModel member) async {
    try {
      _isLoading = true;
      notifyListeners();

      final memberId = await _service.addFamilyMember(member);
      final newMember = member.copyWith(id: memberId);
      _familyMembers.add(newMember);
      _error = null;

      // Send welcome notification to family member
      await _service.notifyFamilyMembers(
        member.pregnancyId,
        'milestone',
        _isBangla ? 'পরিবার সাপোর্টে স্বাগতম' : 'Welcome to Family Support',
        _isBangla
            ? 'আপনি এখন গর্ভাবস্থা ট্র্যাকিং আপডেট পাবেন'
            : 'You will now receive pregnancy tracking updates',
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update family member
  Future<void> updateFamilyMember(PregnancyFamilyMemberModel member) async {
    try {
      await _service.updateFamilyMember(member);

      final index = _familyMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _familyMembers[index] = member;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove family member
  Future<void> removeFamilyMember(String memberId) async {
    try {
      await _service.removeFamilyMember(memberId);
      _familyMembers.removeWhere((m) => m.id == memberId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Notify family members about important events
  Future<void> notifyFamily(
    String eventType,
    String title,
    String message,
  ) async {
    if (_activePregnancy == null) return;

    try {
      await _service.notifyFamilyMembers(
        _activePregnancy!.id,
        eventType,
        title,
        message,
      );
    } catch (e) {
      // Silently fail for notifications
    }
  }

  // ===== BUMP PHOTOS =====

  // Load bump photos
  Future<void> loadBumpPhotos(String userId, String pregnancyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _bumpPhotos = await _service.getBumpPhotos(userId, pregnancyId);
    } catch (e) {
      _error = 'Failed to load bump photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add bump photo
  Future<void> addBumpPhoto(
    dynamic imageFile, // Can be File or XFile
    BumpPhotoModel photo,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload image to Firebase Storage
      final photoUrl = await StorageService().uploadBumpPhoto(
        imageFile,
        photo.userId,
        photo.pregnancyId,
        photo.week,
      );

      // Create photo model with URL
      final photoWithUrl = photo.copyWith(
        photoUrl: photoUrl,
        photoDate: DateTime.now(),
      );

      // Save to Firestore
      await _service.addBumpPhoto(photoWithUrl);

      // Reload photos to ensure we have latest from Firestore
      if (_activePregnancy != null) {
        await loadBumpPhotos(photo.userId, photo.pregnancyId);
      }

      // Notify family members
      if (_activePregnancy != null && _familyMembers.isNotEmpty) {
        await notifyFamily(
          'milestone',
          _isBangla ? 'নতুন বাম্প ফটো যোগ করা হয়েছে' : 'New bump photo added',
          _isBangla
              ? 'সপ্তাহ ${photo.week}-এর জন্য একটি নতুন বাম্প ফটো যোগ করা হয়েছে'
              : 'A new bump photo has been added for week ${photo.week}',
        );
      }
    } catch (e) {
      _error = 'Failed to add bump photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update bump photo metadata
  Future<void> updateBumpPhoto(BumpPhotoModel photo) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.updateBumpPhoto(photo);

      // Update in local list
      final index = _bumpPhotos.indexWhere((p) => p.id == photo.id);
      if (index != -1) {
        _bumpPhotos[index] = photo;
      }
    } catch (e) {
      _error = 'Failed to update bump photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete bump photo
  Future<void> deleteBumpPhoto(BumpPhotoModel photo) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete from Firebase Storage
      await StorageService().deleteBumpPhoto(photo.photoUrl);

      // Delete from Firestore
      await _service.deleteBumpPhoto(photo.id);

      // Remove from local list
      _bumpPhotos.removeWhere((p) => p.id == photo.id);
    } catch (e) {
      _error = 'Failed to delete bump photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get photos by week
  List<BumpPhotoModel> getBumpPhotosByWeek(int week) {
    return _bumpPhotos.where((photo) => photo.week == week).toList();
  }

  // Get most recent photo
  BumpPhotoModel? getMostRecentPhoto() {
    if (_bumpPhotos.isEmpty) return null;
    _bumpPhotos.sort((a, b) => b.photoDate.compareTo(a.photoDate));
    return _bumpPhotos.first;
  }

  // Get photo comparison (milestone weeks)
  Future<List<BumpPhotoModel>> getPhotoComparison(int currentWeek) async {
    if (_activePregnancy == null) return [];

    try {
      return await _service.getPhotoComparison(
        _activePregnancy!.userId,
        _activePregnancy!.id,
        currentWeek,
      );
    } catch (e) {
      _error = 'Failed to get photo comparison: $e';
      return [];
    }
  }

  // ===== POSTPARTUM LOGS =====

  // Load postpartum logs
  Future<void> loadPostpartumLogs(String userId, String pregnancyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _postpartumLogs = await _service.getPostpartumLogs(userId, pregnancyId);
    } catch (e) {
      _error = 'Failed to load postpartum logs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add postpartum log
  Future<void> addPostpartumLog(PostpartumLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final logId = await _service.addPostpartumLog(log);
      _postpartumLogs.insert(0, log.copyWith(id: logId));
    } catch (e) {
      _error = 'Failed to add postpartum log: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update postpartum log
  Future<void> updatePostpartumLog(PostpartumLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.updatePostpartumLog(log);

      final index = _postpartumLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _postpartumLogs[index] = log;
      }
    } catch (e) {
      _error = 'Failed to update postpartum log: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete postpartum log
  Future<void> deletePostpartumLog(String logId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.deletePostpartumLog(logId);
      _postpartumLogs.removeWhere((log) => log.id == logId);
    } catch (e) {
      _error = 'Failed to delete postpartum log: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get logs by type
  List<PostpartumLogModel> getPostpartumLogsByType(PostpartumLogType type) {
    return _postpartumLogs.where((log) => log.type == type).toList();
  }

  // Get today's logs
  List<PostpartumLogModel> getTodayPostpartumLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _postpartumLogs.where((log) {
      final logDate = DateTime(
        log.logDate.year,
        log.logDate.month,
        log.logDate.day,
      );
      return logDate == today;
    }).toList();
  }

  // Get feeding statistics for today
  Map<String, dynamic> getTodayFeedingStats() {
    final todayLogs = getTodayPostpartumLogs();

    final breastfeedingLogs = todayLogs
        .where((log) => log.type == PostpartumLogType.breastfeeding)
        .toList();
    final bottleLogs = todayLogs
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
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
