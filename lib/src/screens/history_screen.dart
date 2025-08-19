import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../models/history_model.dart';
import 'package:intl/intl.dart';

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
      if (key == 'calories' && item.calories != null) {
        return item.calories!.toDouble();
      }
      if (key == 'steps' && item.steps != null) {
        return item.steps!.toDouble();
      }
      return 0.0;
    }).toList();
    return values.isNotEmpty
        ? values.reduce((a, b) => a + b) / values.length
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final history = historyProvider.history;
          if (history.isEmpty) {
            return const Center(
              child: Text(
                  'No history available. Start tracking to see your data!'),
            );
          }

          final avgSteps = _calculateAverage(history, 'steps').toInt();
          String feedback = '';
          if (avgSteps > 5000) {
            feedback =
                'Great job! Your average steps ($avgSteps) are well above 5000. Keep up the consistent effort!';
          } else {
            feedback =
                'Your average steps are $avgSteps. A daily goal of 5000+ steps can significantly improve your health. Try walking a bit more each day!';
          }

          return Column(
            children: [
              _buildFeedbackCard(context, feedback),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryEntryCard(context, item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, String feedback) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.insights, color: Colors.green[800], size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feedback,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.green[800],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryEntryCard(BuildContext context, HistoryModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM dd, yyyy').format(item.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const Divider(height: 20, thickness: 1),
            _buildMetricRow(
              context,
              icon: Icons.directions_walk,
              label: 'Steps',
              value: item.steps != null ? item.steps.toString() : 'N/A',
              color: Colors.blue.shade600,
            ),
            _buildMetricRow(
              context,
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: item.calories != null
                  ? '${item.calories!.toStringAsFixed(0)} kcal'
                  : 'N/A',
              color: Colors.orange.shade600,
            ),
            if (item.bmi != null)
              _buildMetricRow(
                context,
                icon: Icons.monitor_weight,
                label: 'BMI',
                value: item.bmi!.toStringAsFixed(1),
                color: Colors.purple.shade600,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
