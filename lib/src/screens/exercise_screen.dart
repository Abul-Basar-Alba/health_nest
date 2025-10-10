// lib/src/screens/exercise_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exercise_provider.dart';
import '../providers/selected_exercise_provider.dart';
import '../models/exercise_model.dart';
import 'custom_workout_screen.dart'; // <-- Added for navigation

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ExerciseScreenState createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ExerciseProvider, SelectedExerciseProvider>(
      builder: (context, exerciseProvider, selectedExerciseProvider, child) {
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
            title: const Text('Workout Library'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: selectedExerciseProvider.selectedExercises.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomWorkoutScreen(),
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
                          gradient:
                              selectedExerciseProvider.selectedExercises.isEmpty
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
                          boxShadow:
                              selectedExerciseProvider.selectedExercises.isEmpty
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
                      if (selectedExerciseProvider.selectedExercises.isNotEmpty)
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
                              selectedExerciseProvider.selectedExercises.length
                                  .toString(),
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
                // Welcome Section
                Text(
                  'Exercise Library',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select exercises to build your custom workout',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
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
                                  selectedExerciseProvider.isSelected(exercise);
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    selectedExerciseProvider
                                        .toggleExerciseSelection(exercise);
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
              ],
            ),
          ),
        );
      },
    );
  }
}
