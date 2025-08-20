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
    final avgBmi = history
            .where((item) => item.bmi != null)
            .map((item) => item.bmi!)
            .reduce((a, b) => a + b) /
        history.where((item) => item.bmi != null).length;
    final avgCalories = history
            .where((item) => item.calories != null)
            .map((item) => item.calories!.toDouble())
            .reduce((a, b) => a + b) /
        history.where((item) => item.calories != null).length;
    final avgSteps = history
            .where((item) => item.steps != null)
            .map((item) => item.steps!.toDouble())
            .reduce((a, b) => a + b) /
        history.where((item) => item.steps != null).length;

    String feedback = 'Based on your data:\n';
    if (avgBmi > 25) {
      feedback +=
          '- Your BMI ($avgBmi) is high. Consider reducing calorie intake.\n';
    }
    if (avgBmi < 18.5) {
      feedback += '- Your BMI ($avgBmi) is low. Increase calorie intake.\n';
    }
    if (avgCalories < 1800) {
      feedback +=
          '- Your calorie intake ($avgCalories kcal) is low. Eat more nutritious food.\n';
    }
    if (avgSteps < 5000) {
      feedback +=
          '- Your steps ($avgSteps) are low. Aim for 5000+ steps daily.\n';
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
