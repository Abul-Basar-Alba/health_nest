import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
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

  double _calculateAverage(List<HistoryModel> history, String key) {
    final values = history
        .where((item) =>
            item.bmi != null || item.calories != null || item.steps != null)
        .map((item) {
      if (key == 'bmi' && item.bmi != null) return item.bmi!;
      if (key == 'calories' && item.calories != null)
        return item.calories!.toDouble();
      if (key == 'steps' && item.steps != null) return item.steps!.toDouble();
      return 0.0;
    }).toList();
    return values.isNotEmpty
        ? values.reduce((a, b) => a + b) / values.length
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final history = historyProvider.history;
          if (history.isEmpty) {
            return const Center(child: Text('No history available'));
          }
          final avgBmi = _calculateAverage(history, 'bmi').toStringAsFixed(1);
          final avgCalories = _calculateAverage(history, 'calories').toInt();
          final avgSteps = _calculateAverage(history, 'steps').toInt();
          String feedback = '';
          if (avgSteps > 5000) {
            feedback =
                'Great job! Your average steps ($avgSteps) are above 5000!';
          } else {
            feedback =
                'Try to increase your steps. Current average: $avgSteps.';
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      title: Text('Date: ${item.timestamp.substring(0, 10)}'),
                      subtitle: Text(
                        item.bmi != null
                            ? 'BMI: ${item.bmi!.toStringAsFixed(1)}, Calories: ${item.calories ?? 0} kcal, Protein: ${item.protein ?? 0}g, Water: ${item.waterIntake ?? 0}L'
                            : 'Steps: ${item.steps ?? 0}',
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'History Feedback: $feedback',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
