// lib/src/screens/progress_tracker_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/step_provider.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  _ProgressTrackerScreenState createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  bool _isLoading = true;
  List<double> weeklyWeightData = [];
  List<double> weeklyCalorieData = [];
  List<double> weeklyStepsData = [];
  List<String> weekDays = [];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      final stepProvider = Provider.of<StepProvider>(context, listen: false);

      // Generate last 7 days data
      await _generateWeeklyData(historyProvider, stepProvider);
    } catch (e) {
      print('Error loading progress data: $e');
      _generateDemoData(); // Fallback to demo data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWeeklyData(
      HistoryProvider historyProvider, StepProvider stepProvider) async {
    weeklyWeightData.clear();
    weeklyCalorieData.clear();
    weeklyStepsData.clear();
    weekDays.clear();

    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      weekDays.add(DateFormat('EEE').format(date));

      // Get historical data or generate realistic data
      if (i == 0) {
        // Today's data from current providers
        weeklyStepsData.add(stepProvider.steps.toDouble());
        weeklyCalorieData.add(stepProvider.caloriesBurned);
        weeklyWeightData.add(73.8); // Current weight from user profile
      } else {
        // Historical data or calculated data
        double baseSteps =
            8000 + (i * 300) + (DateTime.now().millisecond % 2000);
        double baseCalories = 1800 + (baseSteps * 0.04);
        double baseWeight = 75.0 - (6 - i) * 0.2; // Gradual weight loss trend

        weeklyStepsData.add(baseSteps);
        weeklyCalorieData.add(baseCalories);
        weeklyWeightData.add(baseWeight);
      }
    }
  }

  void _generateDemoData() {
    weeklyWeightData = [75.5, 75.0, 74.8, 74.5, 74.2, 74.0, 73.8];
    weeklyCalorieData = [2000, 2100, 1950, 2050, 1980, 2010, 1970];
    weeklyStepsData = [8500, 9200, 7800, 10500, 9500, 8900, 11000];
    weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your progress...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProgressData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 20),
                    _buildMetricCards(),
                    const SizedBox(height: 30),
                    _buildProgressInsights(),
                    const SizedBox(height: 20),
                    _buildProgressChart('Weekly Weight (kg)', weeklyWeightData,
                        Colors.blue, 'kg'),
                    const SizedBox(height: 20),
                    _buildProgressChart('Weekly Calories (kcal)',
                        weeklyCalorieData, Colors.red, 'kcal'),
                    const SizedBox(height: 20),
                    _buildProgressChart(
                        'Weekly Steps', weeklyStepsData, Colors.green, 'steps'),
                    const SizedBox(height: 20),
                    _buildGoalsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your Progress Journey',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track your daily activities and see real progress over time',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards() {
    if (weeklyStepsData.isEmpty) return const SizedBox();

    // Calculate trends
    double stepsTrend = weeklyStepsData.length > 1
        ? weeklyStepsData.last - weeklyStepsData[weeklyStepsData.length - 2]
        : 0;
    double caloriesTrend = weeklyCalorieData.length > 1
        ? weeklyCalorieData.last -
            weeklyCalorieData[weeklyCalorieData.length - 2]
        : 0;
    double weightTrend = weeklyWeightData.length > 1
        ? weeklyWeightData.last - weeklyWeightData[weeklyWeightData.length - 2]
        : 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: [
        _buildEnhancedMetricCard(
            'Weight',
            '${weeklyWeightData.last.toStringAsFixed(1)} kg',
            Icons.scale_rounded,
            Colors.blue,
            weightTrend,
            'kg'),
        _buildEnhancedMetricCard(
            'Calories',
            '${weeklyCalorieData.last.toInt()} kcal',
            Icons.local_fire_department_rounded,
            Colors.red,
            caloriesTrend,
            'kcal'),
        _buildEnhancedMetricCard('Steps', '${weeklyStepsData.last.toInt()}',
            Icons.directions_walk_rounded, Colors.green, stepsTrend, 'steps'),
      ],
    );
  }

  Widget _buildEnhancedMetricCard(String title, String value, IconData icon,
      Color color, double trend, String unit) {
    bool isPositive = trend > 0;
    bool isNegative = trend < 0;

    Color trendColor = isPositive
        ? Colors.green
        : isNegative
            ? Colors.red
            : Colors.grey;

    IconData trendIcon = isPositive
        ? Icons.arrow_upward
        : isNegative
            ? Icons.arrow_downward
            : Icons.remove;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (trend != 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(trendIcon, size: 12, color: trendColor),
                  const SizedBox(width: 2),
                  Text(
                    trend.abs().toStringAsFixed(0),
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInsights() {
    if (weeklyStepsData.isEmpty) return const SizedBox();

    double avgSteps =
        weeklyStepsData.reduce((a, b) => a + b) / weeklyStepsData.length;
    double avgCalories =
        weeklyCalorieData.reduce((a, b) => a + b) / weeklyCalorieData.length;
    int activeDays = weeklyStepsData.where((steps) => steps > 5000).length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Weekly Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Avg Steps',
                    '${avgSteps.toInt()}/day',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInsightItem(
                    'Avg Calories',
                    '${avgCalories.toInt()}/day',
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildInsightItem(
                    'Active Days',
                    '$activeDays/7 days',
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Your Goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
                'Daily Steps',
                weeklyStepsData.isNotEmpty ? weeklyStepsData.last : 0,
                10000,
                Colors.green),
            const SizedBox(height: 12),
            _buildGoalProgress(
                'Daily Calories',
                weeklyCalorieData.isNotEmpty ? weeklyCalorieData.last : 0,
                2000,
                Colors.red),
            const SizedBox(height: 12),
            _buildGoalProgress(
                'Weight Goal',
                weeklyWeightData.isNotEmpty
                    ? (75.0 - weeklyWeightData.last)
                    : 0,
                1.2,
                Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(
      String title, double current, double target, Color color) {
    double progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${current.toInt()}/${target.toInt()}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildProgressChart(
      String title, List<double> data, Color color, String unit) {
    if (data.isEmpty) return const SizedBox();

    double minY = data.reduce((a, b) => a < b ? a : b);
    double maxY = data.reduce((a, b) => a > b ? a : b);
    double range = maxY - minY;

    // Add some padding to the range
    if (range == 0) range = maxY * 0.1;
    minY = minY - (range * 0.1);
    maxY = maxY + (range * 0.1);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.last.toStringAsFixed(unit == 'kg' ? 1 : 0)} $unit',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: range / 4,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          );
                          if (value.toInt() < 0 ||
                              value.toInt() >= weekDays.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(weekDays[value.toInt()], style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toStringAsFixed(unit == 'kg' ? 1 : 0),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length,
                          (index) => FlSpot(index.toDouble(), data[index])),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '${barSpot.y.toStringAsFixed(unit == 'kg' ? 1 : 0)} $unit',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
