import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;

  UserModel? get user => _user;

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    notifyListeners();
  }

  Future<void> createUser(String uid, String name, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'isProfilePublic': false,
    }, SetOptions(merge: true));
    await _fetchUserData(uid);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    double? height,
    double? weight,
    double? bmi,
    String? profileImageUrl,
    bool? isProfilePublic,
  }) async {
    if (_user == null) return;
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;
    if (height != null) updateData['height'] = height;
    if (weight != null) updateData['weight'] = weight;
    if (bmi != null) updateData['bmi'] = bmi;
    if (profileImageUrl != null)
      updateData['profileImageUrl'] = profileImageUrl;
    if (isProfilePublic != null)
      updateData['isProfilePublic'] = isProfilePublic;
    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(_user!.id).update(updateData);
      await _fetchUserData(_user!.id);
    }
  }

  // New function to fetch a user by their ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
    }
    return null;
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Refresh current user data
  Future<void> refreshUser() async {
    if (_user != null) {
      await _fetchUserData(_user!.id);
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
