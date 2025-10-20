// lib/src/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Admin email addresses (শুধুমাত্র এই emails admin access পাবে)
  static const List<String> adminEmails = [
    'mdabulbasarbasar025@gmail.com', // Your main admin email
    'admin@healthnest.com',
    'healthnest.admin@gmail.com',
    // শুধুমাত্র authorized admin emails এখানে add করুন
  ];

  // Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check by email
      if (adminEmails.contains(user.email?.toLowerCase())) {
        return true;
      }

      // Check by database
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['isAdmin'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Make current user admin (SECURE - only for authorized emails)
  static Future<bool> makeCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // ✅ SECURITY CHECK: Only authorized emails can become admin
      if (!adminEmails.contains(user.email?.toLowerCase())) {
        print('Unauthorized admin attempt: ${user.email}');
        return false;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'isAdmin': true,
        'adminSince': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Log admin creation
      await _firestore.collection('analytics').add({
        'event': 'admin_created',
        'userId': user.uid,
        'email': user.email,
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print('Error making user admin: $e');
      return false;
    }
  }

  // Check if user can become admin (authorized email check)
  static Future<bool> canBecomeAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      return adminEmails.contains(user.email?.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  // Remove admin privileges
  static Future<bool> removeAdminPrivileges(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': false,
        'adminRemovedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Log admin removal
      await _firestore.collection('analytics').add({
        'event': 'admin_removed',
        'userId': userId,
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print('Error removing admin privileges: $e');
      return false;
    }
  }

  // Get all admin users
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting admins: $e');
      return [];
    }
  }

  // Log admin activity
  static Future<void> logAdminActivity({
    required String action,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('admin_logs').add({
        'adminId': user.uid,
        'adminEmail': user.email,
        'action': action,
        'description': description,
        'metadata': metadata ?? {},
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error logging admin activity: $e');
    }
  }

  // Dashboard stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get user stats
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final premiumUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isPremium'] == true;
      }).length;
      final freeTrialUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isInFreeTrial'] == true;
      }).length;

      // Get payment stats
      final paymentsSnapshot = await _firestore
          .collection('analytics')
          .where('event', isEqualTo: 'payment_success')
          .get();

      final totalRevenue = paymentsSnapshot.docs.fold<double>(0, (sum, doc) {
        final data = doc.data();
        return sum + (data['amount'] ?? 0.0);
      });

      // Get today's activity
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayAnalytics = await _firestore
          .collection('analytics')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      return {
        'totalUsers': totalUsers,
        'premiumUsers': premiumUsers,
        'freeTrialUsers': freeTrialUsers,
        'freeUsers': totalUsers - premiumUsers - freeTrialUsers,
        'totalRevenue': totalRevenue,
        'totalPayments': paymentsSnapshot.docs.length,
        'todayActivity': todayAnalytics.docs.length,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {};
    }
  }
}
