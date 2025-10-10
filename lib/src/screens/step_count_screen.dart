// lib/src/screens/step_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/step_provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../models/history_model.dart';

class StepTrackingScreen extends StatefulWidget {
  const StepTrackingScreen({super.key});

  @override
  State<StepTrackingScreen> createState() => _StepTrackingScreenState();
}

class _StepTrackingScreenState extends State<StepTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Start saving step data every 10 minutes, for example.
    // This is a simple implementation. In a real app, you might use a background service.
    // _startStepSavingService();
  }

  // A simple function to save step data
  void _saveStepsToHistory() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final stepProvider = Provider.of<StepProvider>(context, listen: false);

    if (userProvider.user != null && stepProvider.steps > 0) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Check if there's an existing history entry for today
      // Note: This requires a Firestore query to be truly effective,
      // which is handled in the HistoryProvider.
      // For now, we'll create a new entry. A more advanced implementation
      // would update an existing entry.
      final newEntry = HistoryModel(
        id: '', // Firestore will generate a unique ID
        timestamp: Timestamp.now(),
        type: 'steps',
        data: {
          'steps': stepProvider.steps,
          'calories_burned': stepProvider.caloriesBurned,
          'distance_km': stepProvider.distanceKm,
        },
      );
      historyProvider.addHistoryEntry(userProvider.user!.id, newEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StepProvider>(
      builder: (context, stepProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Step Tracker'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.green[800],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Daily Activity',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your progress towards a healthier lifestyle.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: stepProvider.steps / 10000,
                          strokeWidth: 20,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${stepProvider.steps}',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 60,
                                ),
                          ),
                          Text(
                            'Steps Today',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildActivityMetric(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calories Burned',
                  value:
                      '${stepProvider.caloriesBurned.toStringAsFixed(1)} kcal',
                  color: Colors.red.shade600,
                ),
                const SizedBox(height: 16),
                _buildActivityMetric(
                  context,
                  icon: Icons.map_rounded,
                  label: 'Distance Covered',
                  value: '${stepProvider.distanceKm.toStringAsFixed(2)} km',
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 20),
                // Info Card about Step Counting
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange[700], size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'Mobile Step Counting',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Step counting works automatically on mobile devices. Install the mobile app to track real steps with your phone\'s sensors.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(Icons.smartphone, color: Colors.orange[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-detects walking & running',
                              style: TextStyle(
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityMetric(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
