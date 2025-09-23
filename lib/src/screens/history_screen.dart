// lib/src/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Timestamp
import '../models/history_model.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Your Health History',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            Text(
              'Past Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            _buildDailySnapshots(historyProvider.history),
          ],
        ),
      ),
    );
  }

  Widget _buildAiFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_alt_rounded,
                  color: AppColors.primary, size: 30),
              const SizedBox(width: 12),
              const Text(
                'AI Coach Insights',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_aiFeedback, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required List<FlSpot> spots,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: AppColors.textSecondary, width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: color,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.3), color.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateStepData(List<dynamic> history) {
    final spots = <FlSpot>[];
    final today = DateUtils.dateOnly(DateTime.now());

    // Get the last 7 days of step data
    final recentSteps =
        history.where((h) => h is HistoryModel && h.type == 'steps').toList();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dayEntry = recentSteps.firstWhere(
        (h) => DateUtils.dateOnly(h.timestamp.toDate()).isAtSameMomentAs(date),
        // FIX: Return a valid HistoryModel with default values
        orElse: () => HistoryModel(
          id: 'dummy',
          timestamp: Timestamp.fromDate(date),
          type: 'steps',
          data: {'steps': 0},
        ),
      );

      spots.add(FlSpot(
          i.toDouble(), (dayEntry.data['steps'] as num?)?.toDouble() ?? 0));
    }
    return spots.reversed.toList();
  }

  Widget _buildDailySnapshots(List<dynamic> history) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
              'No history to show yet. Start tracking to see your progress!',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index] as HistoryModel;
        return _buildHistoryCard(entry);
      },
    );
  }

  Widget _buildHistoryCard(HistoryModel entry) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;

    switch (entry.type) {
      case 'calculation':
        title = 'Health Calculation';
        subtitle =
            'BMI: ${entry.data['bmi']?.toStringAsFixed(1) ?? 'N/A'} | Calories: ${entry.data['daily_calories']?.toStringAsFixed(0) ?? 'N/A'} kcal';
        icon = Icons.calculate_rounded;
        iconColor = Colors.blue.shade600;
        break;
      case 'steps':
        title = 'Step Tracking';
        subtitle =
            'Steps: ${entry.data['steps'] ?? 'N/A'} | Calories: ${entry.data['calories_burned']?.toStringAsFixed(0) ?? 'N/A'} kcal';
        icon = Icons.directions_walk_rounded;
        iconColor = Colors.green.shade600;
        break;
      case 'nutrition':
        title = 'Nutrition Log';
        subtitle =
            '${entry.data['name'] ?? 'N/A'} | Calories: ${entry.data['calories']?.toStringAsFixed(0) ?? 'N/A'} kcal';
        icon = Icons.restaurant_menu_rounded;
        iconColor = Colors.orange.shade600;
        break;
      default:
        title = 'Unknown Activity';
        subtitle = 'No details available.';
        icon = Icons.help_outline_rounded;
        iconColor = Colors.grey;
    }

    final entryDate = entry.timestamp.toDate();
    final formattedDate = DateFormat.yMMMd().format(entryDate);
    final formattedTime = DateFormat.jm().format(entryDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: iconColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subtitle\n$formattedDate at $formattedTime',
            style: TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: AppColors.primary),
      ),
    );
  }
}
