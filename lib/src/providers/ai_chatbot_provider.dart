// lib/src/providers/ai_chatbot_provider.dart
// Provider for AI Chatbot (Flask backend integration)

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/ai_chatbot_service.dart';

class AIChatbotProvider with ChangeNotifier {
  final AIChatbotService _service = AIChatbotService();

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userProfile;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize with user profile for personalized responses
  void initializeWithProfile(UserModel user) {
    _userProfile = {
      'age': user.age ?? 25, // Use existing age field
      'gender': user.gender ?? 'unknown',
      'weight': user.weight ?? 70.0,
      'height': user.height ?? 170.0,
      'activity': user.activityLevel ?? 'moderate',
    };

    // Add welcome message
    _messages.add({
      'text': 'Hello! I\'m HealthNest AI, your personal health assistant. '
          'I can answer questions in both English and Bangla. '
          'How can I help you today?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
    notifyListeners();
  }

  /// Send a message to the AI chatbot
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add({
      'text': message,
      'isUser': true,
      'timestamp': DateTime.now(),
    });
    notifyListeners();

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call AI service
      final response = await _service.chat(message, _userProfile);

      // Add AI response
      _messages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      _error = null;
    } catch (e) {
      _error = e.toString();

      // Add error message
      _messages.add({
        'text':
            'Sorry, I couldn\'t process your request. Please make sure the AI backend is running. '
                'Error: ${e.toString()}',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      if (kDebugMode) {
        print('AI Chatbot Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Update user profile (for dynamic updates)
  void updateProfile(Map<String, dynamic> profile) {
    _userProfile = profile;
    notifyListeners();
  }
}
