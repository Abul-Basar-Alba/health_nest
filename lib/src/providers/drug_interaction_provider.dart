// lib/src/providers/drug_interaction_provider.dart

import 'package:flutter/foundation.dart';

import '../models/drug_interaction_model.dart';
import '../services/drug_interaction_service.dart';

/// Provider for managing drug interactions
class DrugInteractionProvider with ChangeNotifier {
  final DrugInteractionService _service = DrugInteractionService();

  List<DrugInteraction> _currentInteractions = [];
  bool _isLoading = false;
  String? _errorMessage;
  MedicineInfo? _selectedMedicineInfo;

  List<DrugInteraction> get currentInteractions => _currentInteractions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MedicineInfo? get selectedMedicineInfo => _selectedMedicineInfo;

  /// Check interactions for a new medicine against existing medicines
  Future<List<DrugInteraction>> checkInteractionsForNewMedicine(
    String newMedicine,
    List<String> existingMedicines,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final interactions = await _service.checkInteractions(
        newMedicine,
        existingMedicines,
      );

      _currentInteractions = interactions;
      _isLoading = false;
      notifyListeners();

      return interactions;
    } catch (e) {
      _errorMessage = 'Failed to check interactions: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Get all interactions for a list of medicines
  Future<List<DrugInteraction>> getAllInteractionsForMedicines(
    List<String> medicines,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final interactions = await _service.getAllInteractions(medicines);

      _currentInteractions = interactions;
      _isLoading = false;
      notifyListeners();

      return interactions;
    } catch (e) {
      _errorMessage = 'Failed to get interactions: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Get medicine information
  Future<void> loadMedicineInfo(String medicineName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final info = await _service.getMedicineInfo(medicineName);
      _selectedMedicineInfo = info;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load medicine info: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current interactions
  void clearInteractions() {
    _currentInteractions = [];
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get interaction count by severity
  Map<String, int> getInteractionsBySeverity() {
    int major = 0;
    int moderate = 0;
    int minor = 0;

    for (final interaction in _currentInteractions) {
      if (interaction.isMajor) {
        major++;
      } else if (interaction.isModerate) {
        moderate++;
      } else if (interaction.isMinor) {
        minor++;
      }
    }

    return {
      'major': major,
      'moderate': moderate,
      'minor': minor,
    };
  }

  /// Check if there are any major interactions
  bool get hasMajorInteractions {
    return _currentInteractions.any((i) => i.isMajor);
  }

  /// Check if there are any interactions at all
  bool get hasAnyInteractions {
    return _currentInteractions.isNotEmpty;
  }

  /// Get summary text for interactions
  String getInteractionSummary() {
    if (_currentInteractions.isEmpty) {
      return 'No known interactions found';
    }

    final counts = getInteractionsBySeverity();
    final parts = <String>[];

    if (counts['major']! > 0) {
      parts.add('${counts['major']} major');
    }
    if (counts['moderate']! > 0) {
      parts.add('${counts['moderate']} moderate');
    }
    if (counts['minor']! > 0) {
      parts.add('${counts['minor']} minor');
    }

    return '${_currentInteractions.length} interaction${_currentInteractions.length == 1 ? '' : 's'} found: ${parts.join(', ')}';
  }

  /// Search medicines
  List<String> searchMedicines(String query) {
    return _service.searchMedicines(query);
  }

  /// Get all medicine names
  List<String> getAllMedicineNames() {
    return _service.getAllMedicineNames();
  }
}
