// lib/src/screens/custom_workout_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_exercise_provider.dart';
import '../services/history_service.dart';

class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key});

  @override
  _CustomWorkoutScreenState createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final HistoryService _historyService = HistoryService();
  bool _isSaving = false;

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  void _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      final selectedExerciseProvider =
          Provider.of<SelectedExerciseProvider>(context, listen: false);

      if (selectedExerciseProvider.selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please add at least one exercise to save the workout.')),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final workoutName = _workoutNameController.text;
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        // Calculate total duration and calories
        int totalDuration = selectedExerciseProvider.selectedExercises.length *
            10; // 10 min per exercise
        double totalCalories = 0;

        for (var exercise in selectedExerciseProvider.selectedExercises) {
          totalCalories += (exercise.caloriesPerMinute ?? 0) * 10;
        }

        // Save workout to Firebase using HistoryService
        await _historyService.saveActivityHistory(
          userId: userId,
          activityLevel: 'Moderate',
          exerciseType: workoutName,
          durationMinutes: totalDuration,
          caloriesBurned: totalCalories.toInt(),
          notes:
              'Workout with ${selectedExerciseProvider.selectedExercises.length} exercises: ${selectedExerciseProvider.selectedExercises.map((e) => e.name).join(", ")}',
        );

        // Clear selection and navigate back
        selectedExerciseProvider.clearSelection();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$workoutName" saved successfully! 💪'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving workout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedExerciseProvider>(
      builder: (context, selectedExerciseProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Custom Workout'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _workoutNameController,
                    decoration: const InputDecoration(
                      labelText: 'Workout Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your workout';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: selectedExerciseProvider.selectedExercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises added yet. Go back and select some!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              selectedExerciseProvider.selectedExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = selectedExerciseProvider
                                .selectedExercises[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.fitness_center),
                                title:
                                    Text(exercise.name ?? 'Unknown Exercise'),
                                subtitle: Text(
                                    '${exercise.caloriesPerMinute ?? 'N/A'} kcal/min'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    selectedExerciseProvider
                                        .removeExerciseAt(index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveWorkout,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Workout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
