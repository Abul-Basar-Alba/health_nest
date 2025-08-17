import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserModel(userCredential.user!);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });
      return UserModel(id: userCredential.user!.uid, name: name, email: email);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    throw UnimplementedError('Google sign-in is not available.');
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserModel _getUserModel(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
    );
  }
}
