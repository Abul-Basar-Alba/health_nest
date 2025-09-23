import 'package:flutter/material.dart';
import 'package:health_nest/src/models/history_model.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    if (userProvider.user != null) {
      historyProvider.fetchHistory(userProvider.user!.id);
    }
  }

  String _generateFeedback(List<HistoryModel> history) {
    if (history.isEmpty) return 'No data available for feedback.';
    final bmiList = history
        .map((item) => item.data['bmi'])
        .where((bmi) => bmi != null)
        .cast<num>()
        .toList();
    final caloriesList = history
        .map((item) => item.data['calories'] ?? item.data['daily_calories'])
        .where((cal) => cal != null)
        .cast<num>()
        .toList();
    final stepsList = history
        .map((item) => item.data['steps'])
        .where((steps) => steps != null)
        .cast<num>()
        .toList();

    final avgBmi = bmiList.isNotEmpty
        ? bmiList.reduce((a, b) => a + b) / bmiList.length
        : null;
    final avgCalories = caloriesList.isNotEmpty
        ? caloriesList.reduce((a, b) => a + b) / caloriesList.length
        : null;
    final avgSteps = stepsList.isNotEmpty
        ? stepsList.reduce((a, b) => a + b) / stepsList.length
        : null;

    String feedback = 'Based on your data:\n';
    if (avgBmi != null && avgBmi > 25) {
      feedback +=
          '- Your BMI (${avgBmi.toStringAsFixed(1)}) is high. Consider reducing calorie intake.\n';
    }
    if (avgBmi != null && avgBmi < 18.5) {
      feedback +=
          '- Your BMI (${avgBmi.toStringAsFixed(1)}) is low. Increase calorie intake.\n';
    }
    if (avgCalories != null && avgCalories < 1800) {
      feedback +=
          '- Your calorie intake (${avgCalories.toStringAsFixed(0)} kcal) is low. Eat more nutritious food.\n';
    }
    if (avgSteps != null && avgSteps < 5000) {
      feedback +=
          '- Your steps (${avgSteps.toStringAsFixed(0)}) are low. Aim for 5000+ steps daily.\n';
    }
    if (feedback == 'Based on your data:\n') {
      feedback += 'You are doing great! Keep it up!';
    }
    return feedback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Feedback')),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final history = historyProvider.history;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _generateFeedback(history),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
