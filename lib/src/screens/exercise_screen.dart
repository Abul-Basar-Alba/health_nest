import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ExerciseScreenState createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
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
    final int steps = stepProvider.steps;
    const int goal = 10000;
    final double progress = steps / goal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value.clamp(0.0, 1.0),
                        strokeWidth: 20,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      );
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.shoePrints,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${steps.toString()}',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildProgressDetailsCard(context, steps, goal),
        ],
      ),
    );
  }

  Widget _buildProgressDetailsCard(BuildContext context, int steps, int goal) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  context,
                  title: 'Goal',
                  value: '$goal',
                  unit: 'steps',
                  icon: Icons.flag,
                  color: Colors.green,
                ),
                _buildDetailItem(
                  context,
                  title: 'Calories',
                  value: (steps * 0.04).toStringAsFixed(0), // approx value
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: Colors.red,
                ),
                _buildDetailItem(
                  context,
                  title: 'Distance',
                  value: (steps * 0.000762).toStringAsFixed(2), // approx km
                  unit: 'km',
                  icon: Icons.map,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String title,
      required String value,
      required String unit,
      required IconData icon,
      required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
