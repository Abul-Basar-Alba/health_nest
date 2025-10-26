// lib/src/screens/nutrition_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_model.dart';
import '../providers/nutrition_provider.dart';
import '../services/history_service.dart';
import '../widgets/food_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  NutritionScreenState createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch an initial list of popular food items when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NutritionProvider>(context, listen: false)
          .fetchPopularFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<NutritionProvider>(
              builder: (context, nutritionProvider, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => nutritionProvider
                          .searchFoodItems(_searchController.text),
                    ),
                  ),
                  onSubmitted: (query) =>
                      nutritionProvider.searchFoodItems(query),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<NutritionProvider>(
              builder: (context, nutritionProvider, child) {
                if (nutritionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (nutritionProvider.errorMessage != null) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        nutritionProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (nutritionProvider.foodItems.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text('Search for a food item to get started.'),
                    ),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: nutritionProvider.foodItems.length,
                      itemBuilder: (context, index) {
                        final food = nutritionProvider.foodItems[index];
                        return FoodCard(
                          food: food,
                          onTap: () => _showFoodDetails(context, food),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodDetails(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNutrientRow(
                  'Calories', '${food.calories.toStringAsFixed(0)} kcal'),
              _buildNutrientRow(
                  'Protein', '${food.protein.toStringAsFixed(1)} g'),
              _buildNutrientRow('Fat', '${food.fat.toStringAsFixed(1)} g'),
              _buildNutrientRow('Carbs', '${food.carbs.toStringAsFixed(1)} g'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Save the food to new nutrition history service
                  await _saveFoodToHistory(food);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.name} logged successfully! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Log Meal'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Updated method: Save food using new HistoryService
  Future<void> _saveFoodToHistory(FoodItem food) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId != null) {
      final historyService = HistoryService();
      
      try {
        // Show meal type selector
        String? mealType = await _showMealTypeDialog();
        
        if (mealType != null) {
          await historyService.saveNutritionHistory(
            userId: userId,
            mealType: mealType,
            foodName: food.name,
            calories: food.calories.toInt(),
            protein: food.protein,
            carbs: food.carbs,
            fats: food.fat,
            quantity: 1.0,
            unit: 'serving',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log meal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Add meal type selector dialog
  Future<String?> _showMealTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Meal Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMealTypeOption('Breakfast', '🌅'),
            _buildMealTypeOption('Lunch', '🌞'),
            _buildMealTypeOption('Dinner', '🌙'),
            _buildMealTypeOption('Snacks', '🍿'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeOption(String mealType, String emoji) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(mealType),
      onTap: () => Navigator.pop(context, mealType.toLowerCase()),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
