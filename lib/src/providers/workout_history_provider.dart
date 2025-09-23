// lib/src/providers/workout_history_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_history_model.dart';

class WorkoutHistoryProvider with ChangeNotifier {
  List<WorkoutHistoryModel> _workoutHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<WorkoutHistoryModel> get workoutHistory => _workoutHistory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WorkoutHistoryProvider() {
    // এই প্রোভাইডার ইনস্ট্যান্স তৈরি হওয়ার সাথে সাথেই ওয়ার্কআউট হিস্টরি লোড করা হবে।
    fetchWorkoutHistory();
  }

  // নতুন ওয়ার্কআউট হিস্টরি Firestore-এ সংরক্ষণ করা
  Future<void> saveWorkoutHistory(WorkoutHistoryModel history) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .add(history.toJson());

      // নতুন ডেটা লোড করে UI আপডেট করা
      await fetchWorkoutHistory();
    } catch (e) {
      _errorMessage = 'Failed to save workout history: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  // Firestore থেকে ব্যবহারকারীর ওয়ার্কআউট হিস্টরি লোড করা
  Future<void> fetchWorkoutHistory() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .orderBy('date', descending: true)
          .get();

      _workoutHistory = querySnapshot.docs
          .map((doc) => WorkoutHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch workout history: $e';
    }
    _isLoading = false;
    notifyListeners();
  }
}
