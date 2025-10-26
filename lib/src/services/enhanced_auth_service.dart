// lib/src/services/enhanced_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/auth_colors.dart';

class EnhancedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn && _auth.currentUser != null;
  }

  // Email/Password Signup with Email Verification
  Future<Map<String, dynamic>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Send verification email
      await credential.user!.sendEmailVerification();

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
        'signInMethod': 'email',
        'emailVerified': false,
      });

      return {
        'success': true,
        'userId': credential.user!.uid,
        'message': 'Verification email sent! Please check your inbox.',
        'needsVerification': true,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'email-already-in-use':
          message = 'Email already registered. Please login instead.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Signup failed: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Check email verification status
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user signed in',
        };
      }

      await user.reload();
      if (user.emailVerified) {
        return {
          'success': false,
          'message': 'Email already verified',
        };
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send email: ${e.toString()}',
      };
    }
  }

  // Update email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'emailVerified': true,
    });
  }

  // Login with Email/Password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      await credential.user!.reload();
      if (!credential.user!.emailVerified) {
        return {
          'success': false,
          'message': 'Please verify your email first',
          'needsVerification': true,
          'userId': credential.user!.uid,
        };
      }

      // Update email verification status
      await updateEmailVerificationStatus(credential.user!.uid);

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', credential.user!.uid);

      // Check if profile is complete
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      final profileComplete = userDoc.data()?['profileComplete'] ?? false;

      return {
        'success': true,
        'userId': credential.user!.uid,
        'profileComplete': profileComplete,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Sign in cancelled',
        };
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);

      // Check if user document exists
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      bool isNewUser = !userDoc.exists;

      if (isNewUser) {
        // Create new user document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'photoUrl': userCredential.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
          'signInMethod': 'google',
          'emailVerified': true,
        });
      }

      final profileComplete = userDoc.data()?['profileComplete'] ?? false;

      return {
        'success': true,
        'userId': userCredential.user!.uid,
        'profileComplete': profileComplete,
        'isNewUser': isNewUser,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': 'Google Sign-In failed: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Save user profile (after signup)
  Future<Map<String, dynamic>> saveUserProfile({
    required String userId,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
    String? gender,
  }) async {
    try {
      // Calculate BMI
      final bmi = weight / ((height / 100) * (height / 100));
      String bmiCategory;
      String bmiAdvice;

      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiAdvice =
            'Consider gaining weight through a balanced diet and strength training.';
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        bmiAdvice =
            'Maintain your healthy weight through regular exercise and balanced diet.';
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiAdvice =
            'Consider losing weight through diet control and regular exercise.';
      } else {
        bmiCategory = 'Obese';
        bmiAdvice =
            'Consult a healthcare professional for a weight management plan.';
      }

      // Calculate recommended daily calorie intake (approximate)
      double bmr;
      if (gender == 'Male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else if (gender == 'Female') {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 78; // Average
      }

      // Activity multiplier using AuthConstants
      final activityMultiplier =
          AuthConstants.activityLevelMultipliers[activityLevel] ?? 1.55;

      final dailyCalories = (bmr * activityMultiplier).round();

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'weight': weight,
        'height': height,
        'age': age,
        'activityLevel': activityLevel,
        'gender': gender ?? 'Not specified',
        'bmi': double.parse(bmi.toStringAsFixed(1)),
        'bmiCategory': bmiCategory,
        'bmiAdvice': bmiAdvice,
        'dailyCalorieTarget': dailyCalories,
        'profileComplete': true,
        'profileUpdatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'bmi': double.parse(bmi.toStringAsFixed(1)),
        'bmiCategory': bmiCategory,
        'bmiAdvice': bmiAdvice,
        'dailyCalories': dailyCalories,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to save profile: ${e.toString()}',
      };
    }
  }

  // Password reset
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent! Check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Failed to send reset email: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Change password (requires old password)
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update to new password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password changed successfully!',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Old password is incorrect.';
          break;
        case 'weak-password':
          message = 'New password is too weak. Use at least 6 characters.';
          break;
        case 'requires-recent-login':
          message = 'Please logout and login again to change password.';
          break;
        default:
          message = 'Failed to change password: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Update user profile (name, height, weight, etc.)
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (activityLevel != null) updates['activityLevel'] = activityLevel;

      // Recalculate BMI if height and weight are provided
      if (height != null || weight != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final currentHeight = height ?? userDoc.data()?['height'];
        final currentWeight = weight ?? userDoc.data()?['weight'];
        final currentActivityLevel =
            activityLevel ?? userDoc.data()?['activityLevel'];
        final currentAge = age ?? userDoc.data()?['age'];
        final currentGender = gender ?? userDoc.data()?['gender'];

        if (currentHeight != null && currentWeight != null) {
          // Calculate BMI
          final heightInMeters = currentHeight / 100;
          final bmi = currentWeight / (heightInMeters * heightInMeters);
          updates['bmi'] = bmi;

          // Determine BMI category
          String bmiCategory;
          if (bmi < 18.5) {
            bmiCategory = 'Underweight';
          } else if (bmi < 25) {
            bmiCategory = 'Normal';
          } else if (bmi < 30) {
            bmiCategory = 'Overweight';
          } else {
            bmiCategory = 'Obese';
          }
          updates['bmiCategory'] = bmiCategory;

          // Calculate daily calories if we have all required data
          if (currentAge != null &&
              currentGender != null &&
              currentActivityLevel != null) {
            double bmr;
            if (currentGender == 'Male') {
              bmr = 10 * currentWeight +
                  6.25 * currentHeight -
                  5 * currentAge +
                  5;
            } else {
              bmr = 10 * currentWeight +
                  6.25 * currentHeight -
                  5 * currentAge -
                  161;
            }

            final multiplier =
                AuthConstants.activityLevelMultipliers[currentActivityLevel] ??
                    1.2;
            final dailyCalories = (bmr * multiplier).round();
            updates['dailyCalories'] = dailyCalories;
          }
        }
      }

      // Update display name in Firebase Auth if name is changed
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }

      // Update Firestore
      await _firestore.collection('users').doc(userId).update(updates);

      return {
        'success': true,
        'message': 'Profile updated successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Check if profile is complete
  Future<bool> isProfileComplete(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['profileComplete'] ?? false;
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data();
  }
}
