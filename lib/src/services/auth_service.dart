// lib/src/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // kIsWeb check এর জন্য
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          profileImageUrl: user.photoURL,
        );

        await _firestoreService.saveUserData(newUser);
        return newUser;
      }
      throw Exception('Sign up failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        final userModel = await _firestoreService.getUserData(user.uid);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userModel.id);

        return userModel;
      }
      throw Exception('Sign in failed. Invalid email or password.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      }
      throw Exception(e.message ?? 'An unknown authentication error occurred.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Google Sign-In session handle
      if (!kIsWeb) {
        // Android/iOS
        await _googleSignIn.signOut();
      } else {
        // Web: clientId না থাকলে crash হতে পারে, তাই try-catch
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          // Ignore errors on Web
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
    } catch (e) {
      // সব exceptions ignore করুন, যাতে logout crash না করে
      debugPrint('Logout error: $e');
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          final newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            profileImageUrl: user.photoURL,
          );
          await _firestoreService.saveUserData(newUser);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', newUser.id);

          return newUser;
        } else {
          final existingUser = await _firestoreService.getUserData(user.uid);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', existingUser.id);

          return existingUser;
        }
      }
      throw Exception('Google Sign-In failed.');
    } catch (e) {
      rethrow;
    }
  }
}
