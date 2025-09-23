// lib/src/providers/nutrition_provider.dart

import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/nutrition_service.dart';

class NutritionProvider with ChangeNotifier {
  final NutritionService _nutritionService = NutritionService();
  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchFoodItems(String query) async {
    if (query.isEmpty) {
      _foodItems = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _foodItems = await _nutritionService.searchFood(query);
    } catch (e) {
      _errorMessage = 'Failed to fetch food items. Please try again.';
      _foodItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to fetch a default list of popular food items
  Future<void> fetchPopularFoods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For now, we'll search for 'popular' or a similar common term.
      // In a more advanced app, this would be a specific API call.
      _foodItems = await _nutritionService.searchFood('popular');
      if (_foodItems.isEmpty) {
        _errorMessage = 'No popular foods found. Try a different search.';
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch popular foods. Please try again.';
      _foodItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
