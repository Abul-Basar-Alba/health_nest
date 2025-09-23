// lib/src/services/nutrition_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // এই লাইনটি যোগ করুন

class NutritionService {
  final String _appId = dotenv.env['EDAMAM_APP_ID']!; // মান পরিবর্তন করা হলো
  final String _appKey = dotenv.env['EDAMAM_APP_KEY']!; // মান পরিবর্তন করা হলো
  final String _baseUrl = 'https://api.edamam.com/api/food-database/v2/parser';

  Future<List<FoodItem>> searchFood(String query) async {
    final response = await http.get(
        Uri.parse('$_baseUrl?app_id=$_appId&app_key=$_appKey&ingr=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> hints = data['hints'];

      if (hints.isEmpty) {
        throw Exception('No food items found for "$query"');
      }

      return hints.map((hint) => FoodItem.fromJson(hint)).toList();
    } else {
      throw Exception(
          'Failed to load food data. Status code: ${response.statusCode}');
    }
  }
}
