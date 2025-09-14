import 'package:flutter/material.dart';
import '../models/food_model.dart'; // Correctly import the FoodModel class

class FoodCard extends StatelessWidget {
  final FoodItem food; // Change FoodModel to FoodItem to match the class name
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.food,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // You can use CachedNetworkImage here later for real images
              const Icon(
                Icons.restaurant_menu,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.calories.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12.0,
                      children: [
                        _buildNutrientTag(
                            'Protein', food.protein.toStringAsFixed(1), 'g'),
                        _buildNutrientTag(
                            'Carbs',
                            food.carbs.toStringAsFixed(1),
                            'g'), // Fix: changed from carbohydrates to carbs
                        _buildNutrientTag(
                            'Fat', food.fat.toStringAsFixed(1), 'g'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientTag(String label, String value, String unit) {
    return Chip(
      label: Text('$label: $value$unit'),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey[800],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
