import 'package:flutter/material.dart';
import 'package:health_nest/src/constants/app_colors.dart';
import 'package:health_nest/src/providers/history_provider.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  String _aiFeedback = 'Loading insights...';

  @override
  void initState() {
    super.initState();
    _fetchAiFeedback();
  }

  void _fetchAiFeedback() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final aiService = AiService();
    try {
      final feedback = await aiService.getHealthRecommendation(
        user: userProvider.user!,
        recentHistory: historyProvider.history.take(7).toList(),
      );
      setState(() {
        _aiFeedback = feedback;
      });
    } catch (e) {
      setState(() {
        _aiFeedback = 'Failed to load AI feedback. $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health History'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiFeedbackCard(),
            const SizedBox(height: 24),
            _buildChartCard(
              title: 'Weekly Steps Trend',
              spots: _generateStepData(historyProvider.history),
              color: AppColors.steps,
            ),
            const SizedBox(height: 24),
            const Text(
              'Past Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDailySnapshots(historyProvider.history),
          ],
        ),
      ),
    );
  }

  Widget _buildAiFeedbackCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.lightGreen[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'AI Coach Insights',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_aiFeedback),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required List<FlSpot> spots,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: color,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateStepData(List<dynamic> history) {
    // This is a simplified example. A real-world app would need more robust data handling.
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayHistory = history.firstWhere(
        (h) =>
            DateFormat('yyyy-MM-dd').format(h.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => null,
      );
      spots.add(FlSpot(i.toDouble(), dayHistory?.steps.toDouble() ?? 0));
    }
    return spots.reversed.toList();
  }

  Widget _buildDailySnapshots(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(child: Text('No history to show.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${entry.date.day}'),
            ),
            title: Text(DateFormat.yMMMd().format(entry.date)),
            subtitle: Text(
                'Steps: ${entry.steps} | Calories: ${entry.calories.toStringAsFixed(0)}'),
          ),
        );
      },
    );
  }
}
