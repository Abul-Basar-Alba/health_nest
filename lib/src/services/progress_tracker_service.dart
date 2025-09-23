import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // এই ফাংশনটি ব্যবহারকারীর স্টেপ ডেটা সংগ্রহ করবে।
  Stream<List<Map<String, dynamic>>> getStepsData(String userId) {
    // এখানে আপনি Firebase থেকে স্টেপ ডেটা আনতে পারেন।
    // আপনার ডেটাবেস স্ট্রাকচার অনুযায়ী পথ (path) পরিবর্তন করুন।
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('steps')
        .orderBy('timestamp', descending: true)
        .limit(7) // উদাহরণস্বরূপ, গত ৭ দিনের ডেটা আনা হচ্ছে
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // এই ফাংশনটি ব্যবহারকারীর এক্সারসাইজ ডেটা সংগ্রহ করবে।
  Stream<List<Map<String, dynamic>>> getExerciseData(String userId) {
    // আপনার ডেটাবেস স্ট্রাকচার অনুযায়ী পথ পরিবর্তন করুন।
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('exercise_sessions')
        .orderBy('timestamp', descending: true)
        .limit(7) // উদাহরণস্বরূপ, গত ৭ দিনের ডেটা আনা হচ্ছে
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // এই ফাংশনটি ব্যবহারকারীর নিউট্রিশন ডেটা সংগ্রহ করবে।
  Stream<List<Map<String, dynamic>>> getNutritionData(String userId) {
    // আপনার ডেটাবেস স্ট্রাকচার অনুযায়ী পথ পরিবর্তন করুন।
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition')
        .orderBy('timestamp', descending: true)
        .limit(7) // উদাহরণস্বরূপ, গত ৭ দিনের ডেটা আনা হচ্ছে
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
