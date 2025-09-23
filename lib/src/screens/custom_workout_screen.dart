// lib/src/screens/custom_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_model.dart';
import '../providers/workout_history_provider.dart';
import '../models/workout_history_model.dart';

class CustomWorkoutScreen extends StatefulWidget {
  final List<ExerciseModel> selectedExercises;

  const CustomWorkoutScreen({super.key, required this.selectedExercises});

  @override
  _CustomWorkoutScreenState createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      if (widget.selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please add at least one exercise to save the workout.')),
        );
        return;
      }

      final workoutName = _workoutNameController.text;
      final workoutProvider =
          Provider.of<WorkoutHistoryProvider>(context, listen: false);

      // আমরা প্রতিটি এক্সারসাইজকে আলাদা এন্ট্রি হিসেবে সেভ করছি
      for (var exercise in widget.selectedExercises) {
        final newEntry = WorkoutHistoryModel(
          exerciseName: exercise.name ?? 'Unknown Exercise',
          caloriesBurned: exercise.caloriesPerMinute ?? 0, // ক্যালরি গণনা
          durationInMinutes: 10, // উদাহরণ হিসেবে ১০ মিনিট ধরা হলো
          date: DateTime.now(), exerciseId: '', sets: 0, reps: 0,
        );
        workoutProvider.saveWorkoutHistory(newEntry);
      }

      // সেভ করার পর আগের স্ক্রিনে ফিরে যান
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$workoutName" workout saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: widget.selectedExercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises added yet. Go back and select some!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = widget.selectedExercises[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(exercise.name ?? 'Unknown Exercise'),
                            subtitle: Text(
                                '${exercise.caloriesPerMinute ?? 'N/A'} kcal/min'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.selectedExercises.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
