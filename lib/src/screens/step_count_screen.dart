import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';

class StepTrackingScreen extends StatefulWidget {
  const StepTrackingScreen({super.key});

  @override
  State<StepTrackingScreen> createState() => _StepTrackingScreenState();
}

class _StepTrackingScreenState extends State<StepTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    Pedometer.stepCountStream.listen((StepCount event) {
      if (!mounted) return;
      final stepProvider = Provider.of<StepProvider>(context, listen: false);
      stepProvider.updateSteps(event.steps);
    }, onError: (error) {
      print("Step count error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: stepProvider.steps / 10000,
                        strokeWidth: 15,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade600!),
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
                              ),
                        ),
                        Text(
                          'Steps Today',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Goal: 10,000 Steps',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildActivityMetric(
            context,
            icon: Icons.local_fire_department_rounded,
            label: 'Calories Burned',
            value: '${stepProvider.caloriesBurned.toStringAsFixed(1)} kcal',
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
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.headphones_rounded,
                          color: Colors.blue[700], size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Audio-Guided Workouts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Get motivated with personalized audio workout plans based on your activity data. Works offline!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Starting an audio workout!')),
                        );
                      },
                      child: const Text('Start Workout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
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

  Widget _buildActivityMetric(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 15),
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
