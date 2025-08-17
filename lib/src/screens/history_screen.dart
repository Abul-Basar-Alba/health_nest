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
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title:
                    Text('Date: ${item.timestamp.toString().substring(0, 10)}'),
                subtitle: Text(
                  item.bmi != null
                      ? 'BMI: ${item.bmi!.toStringAsFixed(1)}, Calories: ${item.calories ?? 0} kcal'
                      : 'Steps: ${item.steps ?? 0}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
