import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Replace with your actual Nutrition API URL and Key
  final String _nutritionApiUrl =
      'https://api.edamam.com/api/food-database/v2/parser';
  final String _appId = 'YOUR_APP_ID';
  final String _appKey = 'YOUR_APP_KEY';

  /// Searches for food items based on a query.
  Future<List<FoodItem>> searchFood(String query) async {
    final uri = Uri.parse(
        '$_nutritionApiUrl?ingr=$query&app_id=$_appId&app_key=$_appKey');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> foods = data['hints'];
  return foods.map((food) => FoodItem.fromJson({'food': food['food']})).toList();
      } else {
        throw Exception('Failed to load food data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Sends user health data to an external health-related API if needed.
  Future<Map<String, dynamic>> sendHealthData(UserModel user) async {
    // Example for sending user data to an API
    final uri = Uri.parse('https://api.your-health-partner.com/data');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toMap()),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to send data to partner API: ${response.statusCode}');
    }
  }
}
