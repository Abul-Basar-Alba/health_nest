// lib/src/providers/recommendation_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';

// ChatMessage মডেল ক্লাসটি যোগ করা হয়েছে
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});
}

class RecommendationProvider with ChangeNotifier {
  final String _apiKey = dotenv.env['GROQ_API_KEY']!;

  bool _isLoading = false;
  String? _healthSummary;
  String? _nutritionTips;
  String? _exerciseTips;
  String? _errorMessage;

  // চ্যাট হিস্টোরি রাখার জন্য নতুন তালিকা
  final List<ChatMessage> _chatHistory = [
    // প্রাথমিক সিস্টেম প্রম্পট (optional)
    ChatMessage(
      role: 'system',
      content:
          'You are an AI health coach. Answer questions in a helpful and friendly tone.',
    ),
  ];

  bool get isLoading => _isLoading;
  String? get healthSummary => _healthSummary;
  String? get nutritionTips => _nutritionTips;
  String? get exerciseTips => _exerciseTips;
  String? get errorMessage => _errorMessage;
  // চ্যাট হিস্টোরি বাইরের থেকে পাওয়ার জন্য getter
  List<ChatMessage> get chatHistory => _chatHistory;

  bool get recommendationsAreEmpty =>
      _healthSummary == null && _nutritionTips == null && _exerciseTips == null;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> generateRecommendations({
    required UserModel user,
    required List<HistoryModel> history,
  }) async {
    if (_apiKey.isEmpty) {
      _errorMessage =
          'API key is missing. Please add your actual Groq API key.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prompt = _generatePrompt(user, history);

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gemma2-9b-it",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final generatedText =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        _parseAndSetRecommendations(generatedText);
      } else {
        _errorMessage =
            "Failed to generate recommendations. Status code: ${response.statusCode}";
        if (kDebugMode) {
          print('API Error Response: ${response.body}');
        }
      }
    } catch (e) {
      _errorMessage = "Failed to generate recommendations. Error: $e";
      if (kDebugMode) {
        print('Groq API Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // চ্যাট মেসেজ পাঠানোর জন্য নতুন মেথড যোগ করা হয়েছে
  Future<void> sendChatMessage(String message) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // ব্যবহারকারীর বার্তা হিস্টোরিতে যোগ করা হয়েছে
    _chatHistory.add(ChatMessage(role: 'user', content: message));

    List<Map<String, String>> apiMessages = _chatHistory
        .map((m) => {
              'role': m.role,
              'content': m.content,
            })
        .toList();

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gemma2-9b-it",
          "messages": apiMessages,
        }),
      );

      if (response.statusCode == 200) {
        final generatedText =
            jsonDecode(response.body)['choices'][0]['message']['content'];

        _chatHistory
            .add(ChatMessage(role: 'assistant', content: generatedText));
      } else {
        _errorMessage = "Chat failed: ${response.body}";
      }
    } catch (e) {
      _errorMessage = "Chat error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generatePrompt(UserModel user, List<HistoryModel> history) {
    String historyText = history.map((h) {
      final date = h.timestamp.toDate().toLocal();
      final dateStr = date.toString().split(' ').first;
      final calories = h.data['calories'] ?? h.data['daily_calories'] ?? '-';
      final steps = h.data['steps'] ?? '-';
      final bmi = h.data['bmi'] ?? '-';
      return 'Date: $dateStr, Type: ${h.type}, Calories: $calories, Steps: $steps, BMI: $bmi';
    }).join('\n');

    return """
You are an AI health coach. Analyze the user's data and provide personalized, actionable health recommendations in a friendly tone. Structure your response into three sections: "Summary", "Nutrition", and "Exercise".

**User Profile:**
- Name: ${user.name}
- Age: ${user.age ?? '-'}
- Gender: ${user.gender ?? '-'}
- Height: ${user.height ?? '-'} cm
- Weight: ${user.weight ?? '-'} kg

**User History (last few days):**
$historyText

**Instructions:**
1.  **Summary:** Provide a brief summary of the user's current health status based on their data. Mention trends in their steps, calories, and BMI.
2.  **Nutrition:** Suggest simple, actionable tips for their diet based on the logged food or calorie data.
3.  **Exercise:** Give specific tips based on their step count and overall activity. Suggest goals.
    
Format your response exactly like this:
Summary: <Your health summary here>
Nutrition: <Your nutrition tips here>
Exercise: <Your exercise tips here>
""";
  }

  void _parseAndSetRecommendations(String text) {
    final summaryMatch = RegExp(r'Summary:\s*(.*)').firstMatch(text);
    final nutritionMatch = RegExp(r'Nutrition:\s*(.*)').firstMatch(text);
    final exerciseMatch = RegExp(r'Exercise:\s*(.*)').firstMatch(text);

    _healthSummary = summaryMatch?.group(1)?.trim();
    _nutritionTips = nutritionMatch?.group(1)?.trim();
    _exerciseTips = exerciseMatch?.group(1)?.trim();

    if (_healthSummary == null ||
        _nutritionTips == null ||
        _exerciseTips == null) {
      _errorMessage =
          "Failed to parse recommendations from API response. Response format may have changed.";
    }

    notifyListeners();
  }
}
