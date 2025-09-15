// lib/src/screens/progress_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  _ProgressTrackerScreenState createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  // Sample data for demonstration.
  // Replace this with real data from your Firebase or database.
  final List<double> weeklyWeightData = [
    75.5,
    75.0,
    74.8,
    74.5,
    74.2,
    74.0,
    73.8
  ];
  final List<double> weeklyCalorieData = [
    2000,
    2100,
    1950,
    2050,
    1980,
    2010,
    1970
  ];
  final List<double> weeklyStepsData = [
    8500,
    9200,
    7800,
    10500,
    9500,
    8900,
    11000
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress at a Glance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildMetricCards(),
            const SizedBox(height: 30),
            _buildProgressChart(
                'Weekly Weight (kg)', weeklyWeightData, Colors.blue),
            const SizedBox(height: 20),
            _buildProgressChart(
                'Weekly Calories (kcal)', weeklyCalorieData, Colors.red),
            const SizedBox(height: 20),
            _buildProgressChart('Weekly Steps', weeklyStepsData, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildMetricCard('Weight', '${weeklyWeightData.last} kg',
            Icons.scale_rounded, Colors.blue),
        _buildMetricCard('Calories', '${weeklyCalorieData.last} kcal',
            Icons.local_fire_department_rounded, Colors.red),
        _buildMetricCard('Steps', '${weeklyStepsData.last}',
            Icons.directions_walk_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(String title, List<double> data, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Mon';
                              break;
                            case 1:
                              text = 'Tue';
                              break;
                            case 2:
                              text = 'Wed';
                              break;
                            case 3:
                              text = 'Thu';
                              break;
                            case 4:
                              text = 'Fri';
                              break;
                            case 5:
                              text = 'Sat';
                              break;
                            case 6:
                              text = 'Sun';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length,
                          (index) => FlSpot(index.toDouble(), data[index])),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
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
}
