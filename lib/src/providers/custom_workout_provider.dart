// lib/src/providers/custom_workout_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/custom_workout_model.dart';

class CustomWorkoutProvider with ChangeNotifier {
  List<CustomWorkoutModel> _customWorkouts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CustomWorkoutModel> get customWorkouts => _customWorkouts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomWorkoutProvider() {
    fetchCustomWorkouts();
  }

  // Fetch custom workouts from Firestore
  Future<void> fetchCustomWorkouts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .orderBy('createdAt', descending: true)
          .get();

      _customWorkouts = querySnapshot.docs
          .map((doc) => CustomWorkoutModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch custom workouts: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save a new custom workout
  Future<void> saveCustomWorkout(CustomWorkoutModel workout) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in';
        notifyListeners();
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .add(workout.toJson());

      // Refresh the list
      await fetchCustomWorkouts();
    } catch (e) {
      _errorMessage = 'Failed to save custom workout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete a custom workout
  Future<void> deleteCustomWorkout(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in';
        notifyListeners();
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(workoutId)
          .delete();

      // Remove from local list
      _customWorkouts.removeWhere((workout) => workout.id == workoutId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete custom workout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update last used time for a workout
  Future<void> markWorkoutAsUsed(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(workoutId)
          .update({'lastUsedAt': Timestamp.now()});

      // Update local list
      final index =
          _customWorkouts.indexWhere((workout) => workout.id == workoutId);
      if (index != -1) {
        // Create updated workout with new lastUsedAt
        // Note: This is a simplified update, you might want to implement proper copyWith method
        await fetchCustomWorkouts(); // Refresh for now
      }
    } catch (e) {
      _errorMessage = 'Failed to update workout usage: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
