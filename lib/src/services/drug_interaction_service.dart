// lib/src/services/drug_interaction_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/drug_interaction_model.dart';

/// Service for checking drug interactions and managing medicine information
class DrugInteractionService {
  static final DrugInteractionService _instance =
      DrugInteractionService._internal();
  factory DrugInteractionService() => _instance;
  DrugInteractionService._internal();

  /// Comprehensive database of common drug interactions
  static const Map<String, List<Map<String, String>>> _interactionDatabase = {
    // Blood Thinners
    'warfarin': [
      {
        'with': 'aspirin',
        'severity': 'major',
        'description':
            'Taking warfarin with aspirin significantly increases bleeding risk.',
        'recommendation':
            'Avoid combination unless specifically prescribed by doctor. Monitor INR closely if used together.',
      },
      {
        'with': 'ibuprofen',
        'severity': 'major',
        'description':
            'NSAIDs like ibuprofen increase bleeding risk with warfarin.',
        'recommendation':
            'Use acetaminophen (paracetamol) instead for pain relief. If NSAID needed, consult doctor.',
      },
      {
        'with': 'vitamin k',
        'severity': 'moderate',
        'description': 'Vitamin K reduces warfarin effectiveness.',
        'recommendation':
            'Maintain consistent vitamin K intake. Avoid sudden diet changes.',
      },
    ],
    'aspirin': [
      {
        'with': 'warfarin',
        'severity': 'major',
        'description': 'Increases bleeding risk significantly.',
        'recommendation': 'Consult doctor before combining.',
      },
      {
        'with': 'ibuprofen',
        'severity': 'moderate',
        'description': 'Combined NSAIDs increase stomach bleeding risk.',
        'recommendation':
            'Avoid taking together. Space doses by several hours.',
      },
      {
        'with': 'clopidogrel',
        'severity': 'major',
        'description': 'Dual antiplatelet therapy increases bleeding risk.',
        'recommendation':
            'Only use together under medical supervision with gastroprotection.',
      },
    ],

    // NSAIDs
    'ibuprofen': [
      {
        'with': 'aspirin',
        'severity': 'moderate',
        'description': 'Increases gastrointestinal bleeding risk.',
        'recommendation': 'Avoid combination. Use one NSAID at a time.',
      },
      {
        'with': 'warfarin',
        'severity': 'major',
        'description': 'Significantly increases bleeding risk.',
        'recommendation': 'Use acetaminophen instead if possible.',
      },
      {
        'with': 'methotrexate',
        'severity': 'major',
        'description':
            'NSAIDs reduce methotrexate elimination, increasing toxicity.',
        'recommendation':
            'Avoid combination. If necessary, monitor methotrexate levels closely.',
      },
      {
        'with': 'lisinopril',
        'severity': 'moderate',
        'description': 'NSAIDs reduce effectiveness of ACE inhibitors.',
        'recommendation':
            'Monitor blood pressure closely. Use lowest effective NSAID dose.',
      },
    ],
    'naproxen': [
      {
        'with': 'aspirin',
        'severity': 'moderate',
        'description': 'Increases bleeding and stomach ulcer risk.',
        'recommendation': 'Avoid combination.',
      },
      {
        'with': 'warfarin',
        'severity': 'major',
        'description': 'Increases bleeding risk.',
        'recommendation': 'Use alternative pain reliever.',
      },
    ],

    // Blood Pressure Medications
    'lisinopril': [
      {
        'with': 'ibuprofen',
        'severity': 'moderate',
        'description': 'NSAIDs reduce ACE inhibitor effectiveness.',
        'recommendation': 'Monitor blood pressure. Use acetaminophen instead.',
      },
      {
        'with': 'potassium',
        'severity': 'moderate',
        'description': 'ACE inhibitors increase potassium levels.',
        'recommendation':
            'Avoid potassium supplements. Monitor potassium levels regularly.',
      },
      {
        'with': 'spironolactone',
        'severity': 'moderate',
        'description': 'Both increase potassium, risk of hyperkalemia.',
        'recommendation': 'Monitor potassium levels closely.',
      },
    ],
    'amlodipine': [
      {
        'with': 'simvastatin',
        'severity': 'moderate',
        'description':
            'Amlodipine increases simvastatin levels, increasing muscle damage risk.',
        'recommendation':
            'Limit simvastatin to 20mg daily when taking amlodipine.',
      },
      {
        'with': 'grapefruit',
        'severity': 'minor',
        'description': 'Grapefruit juice increases amlodipine levels.',
        'recommendation': 'Avoid grapefruit juice while taking amlodipine.',
      },
    ],

    // Diabetes Medications
    'metformin': [
      {
        'with': 'alcohol',
        'severity': 'moderate',
        'description': 'Alcohol increases lactic acidosis risk with metformin.',
        'recommendation':
            'Limit alcohol intake. Avoid heavy drinking while taking metformin.',
      },
      {
        'with': 'iodinated contrast',
        'severity': 'major',
        'description':
            'Contrast dye increases lactic acidosis risk with metformin.',
        'recommendation':
            'Stop metformin 48 hours before imaging with contrast. Resume after kidney function checked.',
      },
    ],
    'insulin': [
      {
        'with': 'beta-blockers',
        'severity': 'moderate',
        'description': 'Beta-blockers mask hypoglycemia symptoms.',
        'recommendation':
            'Monitor blood sugar more frequently. Be aware symptoms may be masked.',
      },
    ],

    // Antibiotics
    'ciprofloxacin': [
      {
        'with': 'tizanidine',
        'severity': 'major',
        'description':
            'Ciprofloxacin dramatically increases tizanidine levels.',
        'recommendation': 'Avoid combination completely.',
      },
      {
        'with': 'antacids',
        'severity': 'moderate',
        'description': 'Antacids reduce ciprofloxacin absorption.',
        'recommendation':
            'Take ciprofloxacin 2 hours before or 6 hours after antacids.',
      },
      {
        'with': 'dairy',
        'severity': 'minor',
        'description': 'Dairy products reduce ciprofloxacin absorption.',
        'recommendation': 'Avoid dairy 2 hours before/after ciprofloxacin.',
      },
    ],
    'amoxicillin': [
      {
        'with': 'allopurinol',
        'severity': 'minor',
        'description': 'Increases risk of skin rash.',
        'recommendation': 'Monitor for rash. Usually not serious.',
      },
    ],

    // Antidepressants
    'sertraline': [
      {
        'with': 'ibuprofen',
        'severity': 'moderate',
        'description': 'SSRIs with NSAIDs increase bleeding risk.',
        'recommendation':
            'Use acetaminophen for pain relief when possible. Monitor for unusual bleeding.',
      },
      {
        'with': 'tramadol',
        'severity': 'major',
        'description': 'Risk of serotonin syndrome.',
        'recommendation':
            'Avoid combination. If necessary, monitor closely for serotonin syndrome symptoms.',
      },
    ],
    'fluoxetine': [
      {
        'with': 'aspirin',
        'severity': 'moderate',
        'description': 'SSRIs increase bleeding risk with aspirin.',
        'recommendation': 'Monitor for unusual bleeding or bruising.',
      },
    ],

    // Statins
    'simvastatin': [
      {
        'with': 'amlodipine',
        'severity': 'moderate',
        'description': 'Amlodipine increases simvastatin levels.',
        'recommendation': 'Limit simvastatin to 20mg daily.',
      },
      {
        'with': 'grapefruit',
        'severity': 'major',
        'description':
            'Grapefruit juice significantly increases simvastatin levels.',
        'recommendation':
            'Avoid grapefruit juice completely while taking simvastatin.',
      },
    ],
    'atorvastatin': [
      {
        'with': 'grapefruit',
        'severity': 'moderate',
        'description': 'Grapefruit increases atorvastatin levels.',
        'recommendation': 'Limit grapefruit juice or avoid it.',
      },
    ],

    // Thyroid
    'levothyroxine': [
      {
        'with': 'calcium',
        'severity': 'moderate',
        'description': 'Calcium reduces levothyroxine absorption.',
        'recommendation':
            'Take levothyroxine 4 hours before or after calcium supplements.',
      },
      {
        'with': 'iron',
        'severity': 'moderate',
        'description': 'Iron reduces levothyroxine absorption.',
        'recommendation':
            'Take levothyroxine 4 hours before or after iron supplements.',
      },
      {
        'with': 'omeprazole',
        'severity': 'minor',
        'description': 'PPIs may reduce levothyroxine absorption.',
        'recommendation': 'Monitor TSH levels. May need dose adjustment.',
      },
    ],

    // Anticoagulants
    'clopidogrel': [
      {
        'with': 'omeprazole',
        'severity': 'moderate',
        'description': 'Omeprazole reduces clopidogrel effectiveness.',
        'recommendation':
            'Use pantoprazole instead if PPI needed. Avoid omeprazole.',
      },
      {
        'with': 'aspirin',
        'severity': 'major',
        'description': 'Dual antiplatelet increases bleeding risk.',
        'recommendation': 'Only use together under medical supervision.',
      },
    ],
  };

  /// Check for interactions between a new medicine and existing medicines
  Future<List<DrugInteraction>> checkInteractions(
    String newMedicine,
    List<String> existingMedicines,
  ) async {
    final List<DrugInteraction> interactions = [];
    final newMedLower = newMedicine.toLowerCase().trim();

    for (final existingMed in existingMedicines) {
      final existingMedLower = existingMed.toLowerCase().trim();

      // Check both directions in database
      final interaction = _findInteraction(newMedLower, existingMedLower) ??
          _findInteraction(existingMedLower, newMedLower);

      if (interaction != null) {
        interactions.add(DrugInteraction(
          id: '${newMedLower}_${existingMedLower}_${DateTime.now().millisecondsSinceEpoch}',
          medicine1: newMedicine,
          medicine2: existingMed,
          severity: interaction['severity']!,
          description: interaction['description']!,
          recommendation: interaction['recommendation']!,
          timestamp: DateTime.now(),
        ));
      }
    }

    // Sort by severity (major first)
    interactions.sort((a, b) => b.severityLevel.compareTo(a.severityLevel));

    return interactions;
  }

  /// Find interaction in database
  Map<String, String>? _findInteraction(String medicine1, String medicine2) {
    // Check if medicine1 exists in database
    if (!_interactionDatabase.containsKey(medicine1)) {
      return null;
    }

    // Find interaction with medicine2
    final interactions = _interactionDatabase[medicine1]!;
    for (final interaction in interactions) {
      if (medicine2.contains(interaction['with']!) ||
          interaction['with']!.contains(medicine2)) {
        return interaction;
      }
    }

    return null;
  }

  /// Get all interactions for a list of medicines
  Future<List<DrugInteraction>> getAllInteractions(
    List<String> medicines,
  ) async {
    final List<DrugInteraction> allInteractions = [];

    // Check each pair of medicines
    for (int i = 0; i < medicines.length; i++) {
      for (int j = i + 1; j < medicines.length; j++) {
        final interactions = await checkInteractions(
          medicines[i],
          [medicines[j]],
        );
        allInteractions.addAll(interactions);
      }
    }

    return allInteractions;
  }

  /// Cache interactions locally
  Future<void> cacheInteraction(DrugInteraction interaction) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'cached_interaction_${interaction.medicine1}_${interaction.medicine2}';
    await prefs.setString(key, jsonEncode(interaction.toMap()));
  }

  /// Get cached interaction
  Future<DrugInteraction?> getCachedInteraction(
    String medicine1,
    String medicine2,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'cached_interaction_${medicine1}_$medicine2';
    final cached = prefs.getString(key);

    if (cached != null) {
      return DrugInteraction.fromMap(jsonDecode(cached));
    }
    return null;
  }

  /// Get medicine information (basic implementation)
  Future<MedicineInfo?> getMedicineInfo(String medicineName) async {
    // This is a placeholder. In production, integrate with drug database API
    final medLower = medicineName.toLowerCase().trim();

    // Basic information for common medicines
    final Map<String, MedicineInfo> basicInfo = {
      'aspirin': MedicineInfo(
        name: 'Aspirin',
        genericName: 'Acetylsalicylic Acid',
        description: 'Pain reliever and blood thinner',
        commonUses: [
          'Pain relief',
          'Fever reduction',
          'Heart attack prevention'
        ],
        sideEffects: ['Stomach upset', 'Bleeding', 'Heartburn'],
        precautions: ['Take with food', 'Avoid if allergic to NSAIDs'],
        category: 'NSAID',
      ),
      'ibuprofen': MedicineInfo(
        name: 'Ibuprofen',
        genericName: 'Ibuprofen',
        description: 'Nonsteroidal anti-inflammatory drug',
        commonUses: ['Pain relief', 'Inflammation', 'Fever'],
        sideEffects: ['Stomach pain', 'Heartburn', 'Dizziness'],
        precautions: ['Take with food', 'Avoid long-term use'],
        category: 'NSAID',
      ),
      'metformin': MedicineInfo(
        name: 'Metformin',
        genericName: 'Metformin Hydrochloride',
        description: 'Diabetes medication',
        commonUses: ['Type 2 diabetes', 'PCOS'],
        sideEffects: ['Nausea', 'Diarrhea', 'Stomach upset'],
        precautions: ['Take with meals', 'Monitor kidney function'],
        category: 'Antidiabetic',
      ),
    };

    return basicInfo[medLower];
  }

  /// Get list of all medicines in database
  List<String> getAllMedicineNames() {
    return _interactionDatabase.keys.toList()..sort();
  }

  /// Search medicines by partial name
  List<String> searchMedicines(String query) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    return _interactionDatabase.keys
        .where((med) => med.contains(queryLower))
        .toList()
      ..sort();
  }
}
