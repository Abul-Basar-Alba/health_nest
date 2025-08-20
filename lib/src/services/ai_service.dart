import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import '../models/user_model.dart';

class AiService {
  final String _apiUrl = 'https://api.your-ai-service.com/generate-feedback';

  Future<String> getHealthRecommendation({
    required UserModel user,
    required List<HistoryModel> recentHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user': user.toMap(),
          'history': recentHistory.map((h) => h.toMap()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['recommendation'] as String;
      } else {
        // Provide a more specific error message based on the status code
        throw Exception(
            'Failed to get recommendation from AI. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw with a more descriptive message to help with debugging
      throw Exception('Failed to connect to the AI service: $e');
    }
  }
}
