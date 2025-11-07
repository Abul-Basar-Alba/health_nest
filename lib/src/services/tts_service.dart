// lib/src/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Voice settings
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _isEnabled = true;

  // Getters
  double get volume => _volume;
  double get pitch => _pitch;
  double get rate => _rate;
  bool get isEnabled => _isEnabled;

  // Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load saved preferences
      await _loadPreferences();

      // Configure TTS
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);

      // Set language (try Bangla first, fallback to English)
      await _flutterTts.setLanguage('bn-IN'); // Bangla (India)

      // For Android
      await _flutterTts.setSharedInstance(true);

      _isInitialized = true;
    } catch (e) {
      print('TTS initialization error: $e');
    }
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('tts_volume') ?? 1.0;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
    _rate = prefs.getDouble('tts_rate') ?? 0.5;
    _isEnabled = prefs.getBool('tts_enabled') ?? true;
  }

  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_volume', _volume);
    await prefs.setDouble('tts_pitch', _pitch);
    await prefs.setDouble('tts_rate', _rate);
    await prefs.setBool('tts_enabled', _isEnabled);
  }

  // Speak text
  Future<void> speak(String text, {bool isBangla = false}) async {
    if (!_isEnabled) return;

    try {
      await initialize();

      // Set language based on text
      if (isBangla) {
        await _flutterTts.setLanguage('bn-IN'); // Bangla
      } else {
        await _flutterTts.setLanguage('en-US'); // English
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  // Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
    await _savePreferences();
  }

  // Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
    await _savePreferences();
  }

  // Set rate/speed (0.0 to 1.0)
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_rate);
    await _savePreferences();
  }

  // Enable/disable TTS
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _savePreferences();
    if (!enabled) {
      await stop();
    }
  }

  // Check if language is available
  Future<bool> isLanguageAvailable(String language) async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.contains(language);
    } catch (e) {
      return false;
    }
  }

  // Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      return [];
    }
  }

  // Speak reminder text
  Future<void> speakReminder(String title, String message,
      {bool isBangla = false}) async {
    if (!_isEnabled) return;

    final reminderText = isBangla
        ? 'রিমাইন্ডার: $title. $message'
        : 'Reminder: $title. $message';

    await speak(reminderText, isBangla: isBangla);
  }

  // Speak doctor visit reminder
  Future<void> speakDoctorVisitReminder({
    required String visitType,
    required String doctorName,
    required DateTime visitDate,
    required bool isBangla,
  }) async {
    if (!_isEnabled) return;

    final String text;
    if (isBangla) {
      text =
          'ডাক্তার ভিজিটের রিমাইন্ডার। $visitType এর জন্য ডাক্তার $doctorName এর সাথে আপনার অ্যাপয়েন্টমেন্ট আছে।';
    } else {
      text =
          'Doctor visit reminder. You have an appointment for $visitType with Dr. $doctorName.';
    }

    await speak(text, isBangla: isBangla);
  }

  // Speak medicine reminder
  Future<void> speakMedicineReminder({
    required String medicineName,
    required String dosage,
    required bool isBangla,
  }) async {
    if (!_isEnabled) return;

    final String text;
    if (isBangla) {
      text =
          'ওষুধের রিমাইন্ডার। $medicineName খাওয়ার সময় হয়েছে। ডোজ: $dosage।';
    } else {
      text = 'Medicine reminder. Time to take $medicineName. Dosage: $dosage.';
    }

    await speak(text, isBangla: isBangla);
  }

  // Speak contraction alert
  Future<void> speakContractionAlert({
    required int frequency,
    required bool isBangla,
  }) async {
    if (!_isEnabled) return;

    final String text;
    if (isBangla) {
      text =
          'সতর্কতা! আপনার সংকোচন প্রতি $frequency মিনিটে হচ্ছে। দয়া করে হাসপাতালে যান।';
    } else {
      text =
          'Alert! Your contractions are $frequency minutes apart. Please head to the hospital.';
    }

    await speak(text, isBangla: isBangla);
  }

  // Speak week milestone
  Future<void> speakWeekMilestone({
    required int week,
    required String milestone,
    required bool isBangla,
  }) async {
    if (!_isEnabled) return;

    final String text;
    if (isBangla) {
      text = 'অভিনন্দন! আপনি সপ্তাহ $week তে পৌঁছেছেন। $milestone।';
    } else {
      text = 'Congratulations! You have reached week $week. $milestone.';
    }

    await speak(text, isBangla: isBangla);
  }

  // Dispose
  void dispose() {
    _flutterTts.stop();
  }
}
