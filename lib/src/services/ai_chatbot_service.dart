// lib/src/services/ai_chatbot_service.dart
// Service to communicate with Flask backend (AI-Project)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIChatbotService {
  // Flask backend URL
  // Uses localhost for web/desktop, IP address for Android/iOS
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Use your computer's local IP address
      // Find it with: ip addr show (Linux) or ipconfig (Windows)
      return 'http://192.168.0.108:5000';
    } else {
      return 'http://localhost:5000';
    }
  }

  /// Send a chat message to the AI backend
  /// Returns the AI's response as a string
  Future<String> chat(String message,
      [Map<String, dynamic>? userProfile]) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'profile': userProfile,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please make sure the Flask backend is running:\n'
              'cd AI-Project/backend\n'
              'python app.py');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response from AI';
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AI Chatbot Service Error: $e');
      }

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
            'Cannot connect to AI backend. Please start the Flask server:\n\n'
            '1. Open terminal\n'
            '2. cd AI-Project/backend\n'
            '3. python app.py\n\n'
            'Original error: $e');
      }

      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Check if the backend is healthy and running
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Health check failed: $e');
      }
      return false;
    }
  }

  /// Get complete health analysis (BMI, calories, water, steps)
  Future<Map<String, dynamic>> getHealthAnalysis(
    Map<String, dynamic> userProfile,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/health-check'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userProfile),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get health analysis');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Health analysis error: $e');
      }
      rethrow;
    }
  }
}
