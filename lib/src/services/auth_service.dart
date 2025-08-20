import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 2. Create a new UserModel
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
        );

        // 3. Save the user data to Firestore
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
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 2. Fetch the user data from Firestore
        return await _firestoreService.getUserData(user.uid);
      }
      throw Exception('Sign in failed. Invalid email or password.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
