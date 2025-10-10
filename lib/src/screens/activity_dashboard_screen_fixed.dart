// lib/src/screens/activity_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/step_provider.dart';
import '../providers/workout_history_provider.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  ActivityDashboardScreenState createState() => ActivityDashboardScreenState();
}

class ActivityDashboardScreenState extends State<ActivityDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<StepProvider, WorkoutHistoryProvider>(
      builder: (context, stepProvider, workoutHistoryProvider, child) {
        final int steps = stepProvider.steps;
        const int goal = 10000;
        final double progress = steps / goal;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity Dashboard'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Today\'s Activity',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your step counter runs automatically in the background',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 30),

                // Steps Counter Section
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
                              steps.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
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
                            const SizedBox(height: 8),
                            Text(
                              stepProvider.statusMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: stepProvider.isAvailable
                                    ? Colors.green
                                    : Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Testing Controls (for debugging)
                if (!stepProvider.isAvailable)
                  _buildTestingControls(context, stepProvider),

                const SizedBox(height: 40),

                // Progress Details Card
                _buildProgressDetailsCard(context, stepProvider),

                // Music Integration Section
                const SizedBox(height: 30),
                _buildMusicIntegrationCard(context),

                // Recent Activity Section
                const SizedBox(height: 30),
                Text(
                  'Recent Workouts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                _buildRecentWorkouts(context, workoutHistoryProvider),

                // Health Stats Cards
                const SizedBox(height: 30),
                Text(
                  'Health Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                _buildHealthMetricsGrid(context, stepProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressDetailsCard(
      BuildContext context, StepProvider stepProvider) {
    final int steps = stepProvider.steps;
    const int goal = 10000;
    final double progressPercent = (steps / goal * 100).clamp(0.0, 100.0);
    final int remaining = (goal - steps).clamp(0, goal);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${progressPercent.toStringAsFixed(1)}% Complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green.shade600,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Current',
                    steps.toString(),
                    Icons.directions_walk,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Remaining',
                    remaining.toString(),
                    Icons.flag,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicIntegrationCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.headphones_rounded,
                    color: Colors.purple.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Workout Music',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Get motivated with your favorite music from your phone!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMusicAppButton(
                      context,
                      'Spotify',
                      Icons.music_note,
                      Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMusicAppButton(
                      context,
                      'YouTube Music',
                      Icons.play_circle_filled,
                      Colors.red.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMusicAppButton(
                      context,
                      'Device Music',
                      Icons.library_music,
                      Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMusicAppButton(
                      context,
                      'Samsung Music',
                      Icons.apps,
                      Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Start your music app before walking for the best experience!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicAppButton(
      BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Open $label from your app drawer'),
            duration: const Duration(seconds: 2),
            backgroundColor: color,
          ),
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(
      BuildContext context, WorkoutHistoryProvider historyProvider) {
    if (historyProvider.workoutHistory.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No workouts yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your fitness journey by selecting exercises!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: historyProvider.workoutHistory.take(3).map((workout) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(
                Icons.fitness_center,
                color: Colors.green.shade700,
              ),
            ),
            title: Text(
              workout.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${workout.sets} sets × ${workout.reps} reps • ${workout.date.day}/${workout.date.month}',
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthMetricsGrid(
      BuildContext context, StepProvider stepProvider) {
    final int steps = stepProvider.steps;
    final double estimatedCalories = steps * 0.04; // Rough estimate
    final double estimatedDistance = steps * 0.0008; // Rough estimate in km

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          context,
          'Calories',
          '${estimatedCalories.toStringAsFixed(0)} kcal',
          Icons.local_fire_department,
          Colors.red,
        ),
        _buildMetricCard(
          context,
          'Distance',
          '${estimatedDistance.toStringAsFixed(1)} km',
          Icons.straighten,
          Colors.purple,
        ),
        _buildMetricCard(
          context,
          'Active Time',
          '${(steps / 120).toStringAsFixed(0)} min',
          Icons.timer,
          Colors.teal,
        ),
        _buildMetricCard(
          context,
          'Goal Progress',
          '${((steps / 10000) * 100).clamp(0, 100).toStringAsFixed(0)}%',
          Icons.track_changes,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestingControls(
      BuildContext context, StepProvider stepProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Step Counter Testing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Step counter not detected. Use buttons below to test.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => stepProvider.addTestSteps(100),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+100'),
                ),
                ElevatedButton(
                  onPressed: () => stepProvider.addTestSteps(500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+500'),
                ),
                ElevatedButton(
                  onPressed: () => stepProvider.addTestSteps(1000),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+1000'),
                ),
                ElevatedButton(
                  onPressed: () => stepProvider.resetDailySteps(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
