// lib/src/providers/recommendation_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';

class RecommendationProvider with ChangeNotifier {
  // Replace with your actual Gemini API Key
  final String _apiKey = 'AIzaSyDXZIvoa3N_5or2y07AYBbC3zKpYueXfR4';

  late final GenerativeModel _model;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  bool _isLoading = false;
  String? _healthSummary;
  String? _nutritionTips;
  String? _exerciseTips;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get healthSummary => _healthSummary;
  String? get nutritionTips => _nutritionTips;
  String? get exerciseTips => _exerciseTips;
  String? get errorMessage => _errorMessage;

  RecommendationProvider() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }

  Future<void> generateRecommendations({
    required UserModel user,
    required List<HistoryModel> history,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY') {
      _errorMessage = 'Gemini API Key is not set. Please add your API key.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prompt = _generatePrompt(user, history);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final generatedText = response.text;

      if (generatedText != null && generatedText.isNotEmpty) {
        _parseAndSetRecommendations(generatedText);
      } else {
        _errorMessage = "No recommendations received. Please try again.";
      }
    } catch (e) {
      _errorMessage = "Failed to generate recommendations. Error: $e";
      print('Gemini API Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generatePrompt(UserModel user, List<HistoryModel> history) {
    String historyText = history.map((h) {
      final date = DateTime.tryParse(h.timestamp)?.toLocal();
      final dateStr =
          date != null ? date.toString().split(' ').first : h.timestamp;
      return 'Date: $dateStr, Calories: ${h.calories ?? '-'}, Weight: -, Goal: -, Activity: ${h.steps ?? '-'} steps';
    }).join('\n');

    return """
You are an AI health coach. Analyze the user's data and provide personalized, actionable health recommendations in a friendly tone. Structure your response into two sections: "Your Health Summary" and "Actionable Tips".

**User Profile:**
- Name: ${user.name}
- Age: ${user.age ?? '-'}
- Gender: -
- Height: ${user.height ?? '-'} cm
- Weight: ${user.weight ?? '-'} kg
- Activity Level: -
- Health Goal: -

**User History (last few days):**
$historyText

**Instructions:**
1.  **Your Health Summary:** Provide a brief summary of the user's current health status based on their weight, goals, and history. Compare their current progress to their goals.
2.  **Actionable Tips:** Provide specific, numbered tips.
    - **Nutrition Tips:** Suggest what foods to eat or avoid, and how to adjust their diet based on their calorie and nutrition history. Mention their logged meals if available.
    - **Exercise & Activity Tips:** Based on their step count and activity level, suggest what they should continue or change.
    - **Motivation:** End with an encouraging sentence.
    
Format your response exactly like this:
Summary: <Your health summary here>
Nutrition: <Your nutrition tips here>
Exercise: <Your exercise tips here>
""";
  }

  void _parseAndSetRecommendations(String text) {
    final parts = text.split('\n');
    _healthSummary = parts[0].replaceFirst('Summary: ', '').trim();
    _nutritionTips = parts[1].replaceFirst('Nutrition: ', '').trim();
    _exerciseTips = parts[2].replaceFirst('Exercise: ', '').trim();
  }
}
