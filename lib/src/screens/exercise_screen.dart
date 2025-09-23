// lib/src/screens/exercise_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/step_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_history_provider.dart';
import '../models/exercise_model.dart';
import 'custom_workout_screen.dart'; // <-- Added for navigation

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ExerciseScreenState createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
  // New: selected exercises list for custom workout
  final List<ExerciseModel> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Consumer2<StepProvider, ExerciseProvider>(
      builder: (context, stepProvider, exerciseProvider, child) {
        final int steps = stepProvider.steps;
        const int goal = 10000;
        final double progress = steps / goal;

        if (exerciseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (exerciseProvider.errorMessage.isNotEmpty) {
          return Center(child: Text(exerciseProvider.errorMessage));
        }

        // Group exercises by primaryMuscle
        final Map<String, List<ExerciseModel>> exercisesByMuscle = {};
        for (var exercise in exerciseProvider.allExercises) {
          if (exercise.primaryMuscle != null &&
              exercise.primaryMuscle!.isNotEmpty) {
            if (!exercisesByMuscle.containsKey(exercise.primaryMuscle)) {
              exercisesByMuscle[exercise.primaryMuscle!] = [];
            }
            exercisesByMuscle[exercise.primaryMuscle!]!.add(exercise);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity & Workouts'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: selectedExercises.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomWorkoutScreen(
                                selectedExercises: List.from(selectedExercises),
                              ),
                            ),
                          );
                        },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: selectedExercises.isEmpty
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade400
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: selectedExercises.isEmpty
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  )
                                ],
                        ),
                        child: const Icon(
                          Icons.fitness_center_outlined,
                          color: Colors.white,
                        ),
                      ),
                      if (selectedExercises.isNotEmpty)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              selectedExercises.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Activity Tracker Section ---
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildProgressDetailsCard(context, stepProvider),

                // --- Exercise Library Section ---
                const SizedBox(height: 40),
                Text(
                  'Workout Library',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercisesByMuscle.keys.length,
                  itemBuilder: (context, index) {
                    final muscle = exercisesByMuscle.keys.elementAt(index);
                    final exercises = exercisesByMuscle[muscle]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8.0),
                          child: Text(
                            muscle.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: exercises.length,
                            itemBuilder: (context, innerIndex) {
                              final exercise = exercises[innerIndex];
                              final isSelected =
                                  selectedExercises.contains(exercise);
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedExercises.remove(exercise);
                                      } else {
                                        selectedExercises.add(exercise);
                                      }
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Container(
                                          width: 150,
                                          height: 200, // Fixed total height
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3, // 60% for image
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              16)),
                                                  child: Image.network(
                                                    exercise.fullImageUrl ??
                                                        'https://via.placeholder.com/150',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                            'assets/images/placeholder.png',
                                                            fit: BoxFit.cover,
                                                            width: double
                                                                .infinity),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2, // 40% for text
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        exercise.name ??
                                                            'No Name',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        '${exercise.caloriesPerMinute ?? 'N/A'} kcal/min',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .green[600],
                                                            fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // --- Workout History Section ---
                const SizedBox(height: 40),
                Text(
                  'Your Workout History',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 20),
                Consumer<WorkoutHistoryProvider>(
                  builder: (context, workoutHistoryProvider, child) {
                    if (workoutHistoryProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (workoutHistoryProvider.errorMessage.isNotEmpty) {
                      return Center(
                          child: Text(workoutHistoryProvider.errorMessage));
                    }
                    if (workoutHistoryProvider.workoutHistory.isEmpty) {
                      return const Center(
                          child: Text('No workout history found.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutHistoryProvider.workoutHistory.length,
                      itemBuilder: (context, index) {
                        final history =
                            workoutHistoryProvider.workoutHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(Icons.fitness_center,
                                color: Colors.green[600]),
                            title: Text(
                              history.exerciseName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            subtitle: Text(
                              'Duration: ${history.durationInMinutes.toStringAsFixed(0)} mins\n'
                              'Calories: ${history.caloriesBurned.toStringAsFixed(0)} kcal',
                            ),
                            trailing: Text(
                              '${history.date.day}/${history.date.month}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressDetailsCard(
      BuildContext context, StepProvider stepProvider) {
    const int goal = 10000;

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
                  value: stepProvider.caloriesBurned.toStringAsFixed(0),
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: Colors.red,
                ),
                _buildDetailItem(
                  context,
                  title: 'Distance',
                  value: stepProvider.distanceKm.toStringAsFixed(2),
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
