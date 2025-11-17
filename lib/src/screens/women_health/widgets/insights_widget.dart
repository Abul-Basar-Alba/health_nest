// lib/src/screens/women_health/widgets/insights_widget.dart

import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../women_health_colors.dart';

class InsightsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final Map<String, int> symptomFrequency;
  final Map<String, dynamic>? pillAdherenceData;

  const InsightsWidget({
    super.key,
    this.statistics = const {},
    this.symptomFrequency = const {},
    this.pillAdherenceData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCycleStatsCard(),
        const SizedBox(height: 16),
        _buildCycleLengthChart(),
        const SizedBox(height: 16),
        _buildSymptomPatternsCard(),
        const SizedBox(height: 16),
        _buildPillAdherenceCard(),
      ],
    );
  }

  Widget _buildCycleStatsCard() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              WomenHealthColors.primaryPurple,
              WomenHealthColors.primaryPink,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.primaryPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Cycle Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatItem(
                  'Average Cycle',
                  '${statistics['averageCycleLength'] ?? 28} days',
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Average Period',
                  '${statistics['averagePeriodLength'] ?? 5} days',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Shortest',
                  '${statistics['shortestCycle'] ?? 25} days',
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Longest',
                  '${statistics['longestCycle'] ?? 31} days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthChart() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cycle Length Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WomenHealthColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}d',
                            style: TextStyle(
                              fontSize: 10,
                              color: WomenHealthColors.lightText,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun'
                          ];
                          if (value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                color: WomenHealthColors.lightText,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 20,
                  maxY: 35,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(
                            0,
                            (statistics['averageCycleLength'] ?? 28)
                                .toDouble()),
                        FlSpot(
                            1,
                            (statistics['averageCycleLength'] ?? 28)
                                    .toDouble() -
                                1),
                        FlSpot(
                            2,
                            (statistics['averageCycleLength'] ?? 28)
                                    .toDouble() +
                                1),
                        FlSpot(
                            3,
                            (statistics['averageCycleLength'] ?? 28)
                                .toDouble()),
                        FlSpot(
                            4,
                            (statistics['averageCycleLength'] ?? 28)
                                    .toDouble() -
                                1),
                        FlSpot(
                            5,
                            (statistics['averageCycleLength'] ?? 28)
                                .toDouble()),
                      ],
                      isCurved: true,
                      color: WomenHealthColors.primaryPink,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: WomenHealthColors.primaryPink,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: WomenHealthColors.primaryPink.withOpacity(0.1),
                      ),
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

  Widget _buildSymptomPatternsCard() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: WomenHealthColors.symptomOrange,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Most Common Symptoms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (symptomFrequency.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No symptom data yet. Start logging symptoms to see patterns!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: WomenHealthColors.mediumText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ..._buildSymptomBars(),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomBar(String symptom, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              symptom,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: WomenHealthColors.mediumText,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPillAdherenceCard() {
    // Extract pill adherence data
    final adherencePercentage = pillAdherenceData != null
        ? (pillAdherenceData!['adherencePercentage'] ?? 0).toDouble()
        : 0.0;
    final takenPills = pillAdherenceData?['takenPills'] ?? 0;
    final totalPills = pillAdherenceData?['totalPills'] ?? 0;
    final currentStreak = pillAdherenceData?['currentStreak'] ?? 0;

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.medication,
                  color: WomenHealthColors.pillYellow,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Pill Adherence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPillStat(
                    'Overall',
                    '${adherencePercentage.toStringAsFixed(1)}%',
                    adherencePercentage >= 90
                        ? Colors.green
                        : adherencePercentage >= 70
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPillStat(
                    'Status',
                    adherencePercentage >= 90
                        ? 'Excellent'
                        : adherencePercentage >= 70
                            ? 'Good'
                            : 'Needs Work',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPillStat(
                    'Taken',
                    '$takenPills/$totalPills',
                    WomenHealthColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPillStat(
                    'Streak',
                    '$currentStreak days',
                    WomenHealthColors.mintGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                adherencePercentage == 0
                    ? 'Start tracking pills to see adherence stats'
                    : adherencePercentage >= 90
                        ? '🎉 Excellent! Keep it up!'
                        : adherencePercentage >= 70
                            ? '👍 Good job! Stay consistent!'
                            : '⚠️ Try to take pills regularly!',
                style: const TextStyle(
                  fontSize: 14,
                  color: WomenHealthColors.mediumText,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: WomenHealthColors.mediumText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSymptomBars() {
    // Sort symptoms by frequency (descending)
    final sortedSymptoms = symptomFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get total count for percentage calculation
    final totalCount =
        symptomFrequency.values.fold<int>(0, (sum, count) => sum + count);

    // Take top 5 symptoms
    final topSymptoms = sortedSymptoms.take(5).toList();

    final colors = [
      WomenHealthColors.periodRed,
      WomenHealthColors.primaryPurple,
      WomenHealthColors.symptomOrange,
      WomenHealthColors.mintGreen,
      WomenHealthColors.accentPeach,
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < topSymptoms.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 12));

      final entry = topSymptoms[i];
      final percentage =
          totalCount > 0 ? ((entry.value / totalCount) * 100).round() : 0;

      widgets.add(_buildSymptomBar(
        entry.key,
        percentage,
        colors[i % colors.length],
      ));
    }

    return widgets;
  }
}
