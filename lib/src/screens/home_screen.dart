import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
// Ensure you have this widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch history data when the screen is initialized
    _fetchHistoryData();
  }

  void _fetchHistoryData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    if (userProvider.user != null) {
      historyProvider.fetchHistory(userProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    String healthTip = historyProvider.todaySteps >= 5000
        ? 'Great work! You\'re well on your way to a healthier you. Keep it up!'
        : 'Aim for at least 5000 steps today to improve cardiovascular health.';
    if (historyProvider.todayCalories > 2500) {
      healthTip +=
          ' Also, consider tracking your calorie intake to stay on track.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${userProvider.user?.name ?? 'Guest'}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth / 2) - 8,
                    child: _buildSummaryCard(
                      context,
                      title: 'Steps',
                      value: historyProvider.todaySteps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk_rounded,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth / 2) - 8,
                    child: _buildSummaryCard(
                      context,
                      title: 'Calories',
                      value: historyProvider.todayCalories.toStringAsFixed(0),
                      unit: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Your Health Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_alt_rounded,
                          color: Colors.green[700], size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'AI Health Coach Tip',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    healthTip,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/recommendation');
                      },
                      child: const Text('Get More Tips'),
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

  Widget _buildSummaryCard(BuildContext context,
      {required String title,
      required String value,
      required String unit,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
