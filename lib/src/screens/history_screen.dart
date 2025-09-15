// lib/src/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/history_model.dart'; // Import HistoryModel
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../services/ai_service.dart';
import '../constants/app_colors.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAiFeedback();
    });
  }

  void _fetchAiFeedback() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    if (userProvider.user != null && historyProvider.history.isNotEmpty) {
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
    } else {
      setState(() {
        _aiFeedback = 'No user or historical data available.';
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
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: color,
                      dotData: const FlDotData(show: false),
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
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));

      // Changed to handle null correctly
      final dayHistory = history.firstWhere(
        (h) =>
            h is HistoryModel &&
            DateFormat('yyyy-MM-dd')
                    .format(DateTime.tryParse(h.timestamp) ?? DateTime(0)) ==
                DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HistoryModel(
          id: 'dummy',
          timestamp: '',
          steps: 0, // Default to 0 steps
        ),
      );

      spots.add(FlSpot(
          i.toDouble(), (dayHistory as HistoryModel).steps?.toDouble() ?? 0));
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
        final entryDate = DateTime.tryParse(entry.timestamp);
        if (entryDate == null) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${entryDate.day}'),
            ),
            title: Text(DateFormat.yMMMd().format(entryDate)),
            subtitle: Text(
                'Steps: ${entry.steps ?? '-'} | Calories: ${entry.calories ?? '-'}'),
          ),
        );
      },
    );
  }
}
