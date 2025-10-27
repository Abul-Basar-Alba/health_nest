import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/activity_history_model.dart';
import '../../models/bmi_history_model.dart';
import '../../models/nutrition_history_model.dart';
import '../../services/history_service.dart';

class HistoryAnalyticsScreen extends StatefulWidget {
  final String userId;
  final int selectedTab; // 0=All, 1=BMI, 2=Activity, 3=Nutrition

  const HistoryAnalyticsScreen({
    super.key,
    required this.userId,
    this.selectedTab = 0,
  });

  @override
  State<HistoryAnalyticsScreen> createState() => _HistoryAnalyticsScreenState();
}

class _HistoryAnalyticsScreenState extends State<HistoryAnalyticsScreen> {
  final HistoryService _historyService = HistoryService();
  int _selectedDays = 7; // 7, 30, or 90 days

  DateTime get _startDate {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _selectedDays));
    // Set time to start of day (00:00:00)
    return DateTime(start.year, start.month, start.day);
  }

  DateTime get _endDate {
    final now = DateTime.now();
    // Set time to end of day (23:59:59)
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFF093FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildDateRangeSelector(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (widget.selectedTab == 0 || widget.selectedTab == 1)
                        _buildBMISection(),
                      if (widget.selectedTab == 0 || widget.selectedTab == 2)
                        _buildActivitySection(),
                      if (widget.selectedTab == 0 || widget.selectedTab == 3)
                        _buildNutritionSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insights, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Last $_selectedDays days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildRangeButton('7D', 7),
          _buildRangeButton('30D', 30),
          _buildRangeButton('90D', 90),
        ],
      ),
    );
  }

  Widget _buildRangeButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDays = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF667eea) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBMISection() {
    return FutureBuilder<List<BMIHistoryModel>>(
      future: _historyService.getBMIHistoryByDateRange(
          widget.userId, _startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(
              'BMI', 'No BMI data available for this period');
        }

        final records = snapshot.data!;
        return Column(
          children: [
            _buildSectionHeader('BMI Trend', Icons.monitor_weight_rounded),
            const SizedBox(height: 16),
            _buildBMIChart(records),
            const SizedBox(height: 16),
            _buildBMIStats(records),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildActivitySection() {
    return FutureBuilder<List<ActivityHistoryModel>>(
      future: _historyService.getActivityHistoryByDateRange(
          widget.userId, _startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(
              'Activity', 'No activity data available for this period');
        }

        final records = snapshot.data!;
        return Column(
          children: [
            _buildSectionHeader(
                'Activity Pattern', Icons.fitness_center_rounded),
            const SizedBox(height: 16),
            _buildActivityChart(records),
            const SizedBox(height: 16),
            _buildActivityStats(records),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildNutritionSection() {
    return FutureBuilder<List<NutritionHistoryModel>>(
      future: _historyService.getNutritionHistoryByDateRange(
          widget.userId, _startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(
              'Nutrition', 'No nutrition data available for this period');
        }

        final records = snapshot.data!;
        return Column(
          children: [
            _buildSectionHeader(
                'Nutrition Breakdown', Icons.restaurant_menu_rounded),
            const SizedBox(height: 16),
            _buildNutritionChart(records),
            const SizedBox(height: 16),
            _buildNutritionStats(records),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBMIChart(List<BMIHistoryModel> records) {
    final sortedRecords = records..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bmi);
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
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
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedRecords.length) {
                    final date = sortedRecords[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MMM d').format(date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 15,
          maxY: 40,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF667eea),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF667eea),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF667eea).withOpacity(0.2),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 18.5,
                color: Colors.blue.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              HorizontalLine(
                y: 25,
                color: Colors.green.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              HorizontalLine(
                y: 30,
                color: Colors.orange.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart(List<ActivityHistoryModel> records) {
    final sortedRecords = records..sort((a, b) => a.date.compareTo(b.date));

    // Group by date and sum steps
    final Map<String, int> stepsPerDay = {};
    for (var record in sortedRecords) {
      final dateKey = DateFormat('MMM d').format(record.date);
      stepsPerDay[dateKey] = (stepsPerDay[dateKey] ?? 0) + (record.steps ?? 0);
    }

    final entries = stepsPerDay.entries.toList();
    final barGroups = entries.asMap().entries.map((entry) {
      final steps = entry.value.value;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: steps.toDouble(),
            color: steps >= 10000
                ? Colors.green
                : steps >= 5000
                    ? const Color(0xFF667eea)
                    : Colors.orange,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value % 5000 == 0) {
                    return Text(
                      '${(value / 1000).toInt()}K',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          maxY: stepsPerDay.values.reduce((a, b) => a > b ? a : b).toDouble() *
              1.2,
        ),
      ),
    );
  }

  Widget _buildNutritionChart(List<NutritionHistoryModel> records) {
    // Calculate total macros
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var record in records) {
      totalProtein += record.protein ?? 0;
      totalCarbs += record.carbs ?? 0;
      totalFats += record.fats ?? 0;
    }

    final total = totalProtein + totalCarbs + totalFats;
    if (total == 0) {
      return _buildEmptyCard('Nutrition', 'No nutrition data available');
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: totalProtein,
                    color: Colors.blue,
                    title: '${((totalProtein / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalCarbs,
                    color: Colors.orange,
                    title: '${((totalCarbs / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalFats,
                    color: Colors.green,
                    title: '${((totalFats / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Protein', Colors.blue, totalProtein),
                const SizedBox(height: 12),
                _buildLegendItem('Carbs', Colors.orange, totalCarbs),
                const SizedBox(height: 12),
                _buildLegendItem('Fats', Colors.green, totalFats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toInt()}g',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMIStats(List<BMIHistoryModel> records) {
    final firstRecord = records.first;
    final lastRecord = records.last;
    final change = lastRecord.bmi - firstRecord.bmi;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Average',
            (records.map((e) => e.bmi).reduce((a, b) => a + b) / records.length)
                .toStringAsFixed(1),
            Icons.analytics,
          ),
          _buildStatItem(
            'Latest',
            lastRecord.bmi.toStringAsFixed(1),
            Icons.timeline,
          ),
          _buildStatItem(
            'Change',
            '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
            change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            isPositive: change <= 0,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(List<ActivityHistoryModel> records) {
    final totalSteps = records.map((e) => e.steps ?? 0).reduce((a, b) => a + b);
    final avgSteps = (totalSteps / records.length).toInt();
    final totalCalories =
        records.map((e) => e.caloriesBurned ?? 0).reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Steps',
            '${(totalSteps / 1000).toStringAsFixed(1)}K',
            Icons.directions_walk,
          ),
          _buildStatItem(
            'Avg/Day',
            '${(avgSteps / 1000).toStringAsFixed(1)}K',
            Icons.show_chart,
          ),
          _buildStatItem(
            'Calories',
            totalCalories.toInt().toString(),
            Icons.local_fire_department,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStats(List<NutritionHistoryModel> records) {
    final totalCalories =
        records.map((e) => e.calories).reduce((a, b) => a + b);
    final avgCalories = (totalCalories / records.length).toInt();
    final totalMeals = records.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Cal',
            '${(totalCalories / 1000).toStringAsFixed(1)}K',
            Icons.local_fire_department,
          ),
          _buildStatItem(
            'Avg/Day',
            avgCalories.toString(),
            Icons.restaurant,
          ),
          _buildStatItem(
            'Meals',
            totalMeals.toString(),
            Icons.fastfood,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {bool isPositive = true}) {
    return Column(
      children: [
        Icon(
          icon,
          color: isPositive ? Colors.white : Colors.redAccent,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
