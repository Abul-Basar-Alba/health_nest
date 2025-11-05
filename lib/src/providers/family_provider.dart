import 'package:flutter/foundation.dart';

import '../models/family_member_model.dart';
import '../services/family_service.dart';

/// Provider for managing family member state
class FamilyProvider with ChangeNotifier {
  final FamilyService _familyService = FamilyService();

  List<FamilyMemberModel> _familyMembers = [];
  List<FamilyMemberModel> _caregivers = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<FamilyMemberModel> get familyMembers => _familyMembers;
  List<FamilyMemberModel> get caregivers => _caregivers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;

  /// Initialize family members stream for a user
  void initializeFamilyMembers(String userId) {
    _familyService.getFamilyMembersStream(userId).listen(
      (members) {
        _familyMembers = members;
        _error = null;
        notifyListeners();

        // Update statistics
        _updateStatistics(userId);
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // Also listen to caregivers stream
    _familyService.getCaregiversStream(userId).listen(
      (caregivers) {
        _caregivers = caregivers;
        notifyListeners();
      },
    );
  }

  /// Update statistics
  Future<void> _updateStatistics(String userId) async {
    try {
      _statistics = await _familyService.getStatistics(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating statistics: $e');
    }
  }

  /// Add a new family member
  Future<bool> addFamilyMember(FamilyMemberModel member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyService.addFamilyMember(member);
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

  /// Update an existing family member
  Future<bool> updateFamilyMember(FamilyMemberModel member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyService.updateFamilyMember(member);
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

  /// Delete a family member
  Future<bool> deleteFamilyMember(String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyService.deleteFamilyMember(memberId);
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

  /// Get a specific family member
  Future<FamilyMemberModel?> getFamilyMember(String memberId) async {
    try {
      return await _familyService.getFamilyMember(memberId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Search family members
  Future<List<FamilyMemberModel>> searchFamilyMembers(
    String userId,
    String query,
  ) async {
    try {
      return await _familyService.searchFamilyMembers(userId, query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Add caregiver permission
  Future<bool> addCaregiverPermission(
    String memberId,
    String patientUserId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyService.addCaregiverPermission(memberId, patientUserId);
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

  /// Remove caregiver permission
  Future<bool> removeCaregiverPermission(
    String memberId,
    String patientUserId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _familyService.removeCaregiverPermission(memberId, patientUserId);
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

  /// Notify caregivers about missed medicine
  Future<void> notifyCaregivers(
    String userId,
    String medicineName,
    DateTime missedTime,
  ) async {
    try {
      await _familyService.notifyCaregivers(userId, medicineName, missedTime);
    } catch (e) {
      debugPrint('Error notifying caregivers: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh(String userId) async {
    _isLoading = true;
    notifyListeners();

    await _updateStatistics(userId);

    _isLoading = false;
    notifyListeners();
  }
}
