import 'package:flutter/material.dart';
import 'package:health_nest/src/models/food_model.dart';
import 'package:health_nest/src/services/api_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  NutritionScreenState createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodModel> _searchResults = [];
  bool _isLoading = false;

  void _searchFood() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await _apiService.searchFood(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logMeal(FoodModel food) {
    // In a real app, this would save to Firestore and update the HistoryProvider.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} logged successfully!')),
    );
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchFood,
                ),
              ),
              onSubmitted: (_) => _searchFood(),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Search for a food item to get started.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final food = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(food.name),
                        subtitle:
                            Text('${food.calories.toStringAsFixed(0)} kcal'),
                        trailing: ElevatedButton(
                          onPressed: () => _logMeal(food),
                          child: const Text('Log'),
                        ),
                        onTap: () {
                          // Show detailed breakdown
                          _showFoodDetails(context, food);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFoodDetails(BuildContext context, FoodModel food) {
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
                onPressed: () {
                  _logMeal(food);
                  Navigator.pop(context);
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
