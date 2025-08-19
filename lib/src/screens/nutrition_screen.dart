import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Nutrition Log',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adding a new meal...')),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Add New Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent Meals',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildMealEntry(
            context,
            mealType: 'Breakfast',
            items: 'Oats, Berries, Nuts',
            calories: '350 kcal',
            date: 'Aug 18, 2025',
          ),
          _buildMealEntry(
            context,
            mealType: 'Lunch',
            items: 'Chicken Salad, Quinoa',
            calories: '480 kcal',
            date: 'Aug 18, 2025',
          ),
        ],
      ),
    );
  }

  Widget _buildMealEntry(BuildContext context,
      {required String mealType,
      required String items,
      required String calories,
      required String date}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              items,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  calories,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
