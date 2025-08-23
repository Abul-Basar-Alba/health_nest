// The code for RecommendationScreen remains the same as your provided code.
// It is already well-structured and visually appealing.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/history_model.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final history = historyProvider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Coach'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              context,
              title: 'Your Health Summary',
              content: _generateHealthSummary(history),
              icon: Icons.analytics_rounded,
              color: Colors.lightGreen,
            ),
            const SizedBox(height: 20),
            Text(
              'Actionable Tips',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              context,
              title: 'Nutrition Tips',
              content: _generateNutritionTips(history),
              icon: Icons.restaurant_menu_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              context,
              title: 'Exercise & Activity',
              content: _generateExerciseTips(history),
              icon: Icons.directions_run_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              context,
              title: 'Hydration & Water Intake',
              content: _generateWaterTips(history),
              icon: Icons.water_drop_rounded,
              color: Colors.cyan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context,
      {required String title,
      required String content,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateHealthSummary(List<HistoryModel> history) {
    if (history.isEmpty) return 'No data available to generate a summary.';
    final validHistory =
        history.where((h) => h.calories != null || h.steps != null).toList();
    if (validHistory.isEmpty) return 'No recent activity data available.';

    final totalCalories =
        validHistory.map((h) => h.calories ?? 0).reduce((a, b) => a + b);
    final totalSteps =
        validHistory.map((h) => h.steps ?? 0).reduce((a, b) => a + b);
    final numDays = validHistory.length;

    final avgCalories = (totalCalories / numDays).toStringAsFixed(0);
    final avgSteps = (totalSteps / numDays).toStringAsFixed(0);

    return 'Your average daily calorie intake is $avgCalories kcal and you average $avgSteps steps. This information helps us provide better health tips.';
  }

  String _generateNutritionTips(List<HistoryModel> history) {
    if (history.isEmpty) {
      return 'No nutrition data available. Start by logging your meals!';
    }
    final avgCalories = history
        .where((item) => item.calories != null)
        .map((item) => item.calories!)
        .average;

    if (avgCalories < 1800) {
      return 'Your average calorie intake is low. Focus on adding nutrient-dense foods like avocados, nuts, and whole grains to your diet to increase your energy levels.';
    } else if (avgCalories > 2500) {
      return 'Your average calorie intake is a bit high. Try to incorporate more low-calorie, high-fiber foods such as vegetables and fruits to feel full without excess calories.';
    }
    return 'Your calorie intake is within a healthy range. Maintain this by keeping a balanced diet with protein, carbs, and healthy fats.';
  }

  String _generateExerciseTips(List<HistoryModel> history) {
    if (history.isEmpty) {
      return 'No exercise data available. Start logging your steps!';
    }
    final avgSteps = history
        .where((item) => item.steps != null)
        .map((item) => item.steps!.toDouble())
        .average;

    if (avgSteps < 5000) {
      return 'Your average daily steps are low. Aim for at least 5,000 steps. Try taking a 15-minute walk after each meal to easily increase your count.';
    } else if (avgSteps < 10000) {
      return 'You are doing great! Keep up the good work. To challenge yourself, consider adding a new activity like jogging or cycling to your routine.';
    }
    return 'Excellent work! You are consistently hitting your step goals. Keep it up to maintain a healthy lifestyle.';
  }

  String _generateWaterTips(List<HistoryModel> history) {
    final historyWithWater =
        history.where((h) => h.waterIntake != null).toList();
    if (historyWithWater.isEmpty) {
      return 'Log your water intake to get personalized hydration tips!';
    }
    final avgWater = historyWithWater.map((h) => h.waterIntake!).average;

    if (avgWater < 2.0) {
      return 'You are drinking less than the recommended amount of water. Try to carry a reusable water bottle and set reminders to drink throughout the day.';
    } else if (avgWater < 3.0) {
      return 'Your hydration is good. Ensure you increase your intake on days with intense physical activity or in hot weather.';
    }
    return 'Great job! You are well-hydrated. Proper hydration is key for good health.';
  }
}

// Extension to calculate average
extension on Iterable<num> {
  double get average => isEmpty ? 0.0 : sum / length;
  num get sum => reduce((value, element) => value + element);
}
