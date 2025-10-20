// lib/src/services/freemium_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FreemiumService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 Daily Limits for Free Users
  static const Map<String, int> dailyLimits = {
    'calculator_uses': 20, // Calculator দিনে 20 বার
    'ai_chat_messages': 500, // AI chat দিনে 500 message
    'nutrition_logs': 10, // Nutrition log দিনে 10টি
    'workout_saves': 5, // Custom workout save দিনে 5টি
    'community_posts': 3, // Community post দিনে 3টি
    'exercise_downloads': 2, // Exercise video download দিনে 2টি
  };

  // 🎯 Premium Features (Unlimited for Premium Users)
  static const List<String> premiumFeatures = [
    'unlimited_calculator',
    'unlimited_ai_chat',
    'advanced_analytics',
    'custom_meal_plans',
    'personal_trainer_access',
    'premium_courses',
    'family_sharing',
    'offline_downloads',
    'priority_support',
    'advanced_progress_tracking',
  ];

  // Check if user is premium (including free trial users)
  static Future<bool> isPremiumUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;

      // Check if in free trial
      if (await isInFreeTrial()) return true;

      // Check paid subscription
      final isPremium = userData['isPremium'] ?? false;

      if (isPremium) {
        // Check if subscription is still active
        final endDate = userData['subscriptionEndDate'] as Timestamp?;
        if (endDate != null) {
          return endDate.toDate().isAfter(DateTime.now());
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get daily usage for a feature
  static Future<int> getDailyUsage(String feature) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final usageDoc = await _firestore
          .collection('user_usage')
          .doc(user.uid)
          .collection('daily')
          .doc(todayStr)
          .get();

      if (!usageDoc.exists) return 0;

      final data = usageDoc.data()!;
      return data[feature] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Check if user can use a feature
  static Future<Map<String, dynamic>> canUseFeature(String feature) async {
    final isPremium = await isPremiumUser();

    if (isPremium) {
      return {
        'canUse': true,
        'isPremium': true,
        'usage': 0,
        'limit': -1, // Unlimited
        'remaining': -1,
      };
    }

    final limit = dailyLimits[feature] ?? 0;
    if (limit == 0) {
      // Feature not tracked or not available for free users
      return {
        'canUse': false,
        'isPremium': false,
        'usage': 0,
        'limit': 0,
        'remaining': 0,
        'requiresPremium': true,
      };
    }

    final usage = await getDailyUsage(feature);
    final remaining = limit - usage;

    return {
      'canUse': remaining > 0,
      'isPremium': false,
      'usage': usage,
      'limit': limit,
      'remaining': remaining,
      'requiresPremium': remaining <= 0,
    };
  }

  // Increment feature usage
  static Future<bool> incrementUsage(String feature) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if can use first
      final canUse = await canUseFeature(feature);
      if (!canUse['canUse']) return false;

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final usageRef = _firestore
          .collection('user_usage')
          .doc(user.uid)
          .collection('daily')
          .doc(todayStr);

      await usageRef.set({
        feature: FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user's daily summary
  static Future<Map<String, dynamic>> getDailySummary() async {
    final isPremium = await isPremiumUser();
    Map<String, dynamic> summary = {
      'isPremium': isPremium,
      'features': <String, dynamic>{},
    };

    for (final feature in dailyLimits.keys) {
      final usage = await getDailyUsage(feature);
      final limit = dailyLimits[feature]!;

      summary['features'][feature] = {
        'usage': usage,
        'limit': isPremium ? -1 : limit,
        'remaining': isPremium ? -1 : (limit - usage),
        'percentage': isPremium ? 0 : ((usage / limit) * 100).clamp(0, 100),
      };
    }

    return summary;
  }

  // Get feature display info
  static Map<String, String> getFeatureDisplayInfo(String feature) {
    final displayInfo = {
      'calculator_uses': {
        'title': 'Calculator Usage',
        'description': 'BMI, Calorie, Macro calculators',
        'icon': 'calculate',
      },
      'ai_chat_messages': {
        'title': 'AI Health Coach',
        'description': 'Chat with AI for health advice',
        'icon': 'chat',
      },
      'nutrition_logs': {
        'title': 'Nutrition Logging',
        'description': 'Track your daily meals',
        'icon': 'restaurant',
      },
      'workout_saves': {
        'title': 'Custom Workouts',
        'description': 'Save personalized workout plans',
        'icon': 'fitness_center',
      },
      'community_posts': {
        'title': 'Community Posts',
        'description': 'Share progress and tips',
        'icon': 'people',
      },
      'exercise_downloads': {
        'title': 'Exercise Downloads',
        'description': 'Download workout videos',
        'icon': 'download',
      },
    };

    return displayInfo[feature] ??
        {
          'title': feature,
          'description': 'Feature usage',
          'icon': 'star',
        };
  }

  // Show premium upgrade prompt
  static Map<String, dynamic> getPremiumPrompt(String feature) {
    final featureInfo = getFeatureDisplayInfo(feature);

    return {
      'title': 'Upgrade to Premium',
      'message':
          'You\'ve reached your daily limit for ${featureInfo['title']}. Upgrade to Premium for unlimited access!',
      'benefits': [
        'Unlimited ${featureInfo['title']}',
        'Access to all premium features',
        'Priority customer support',
        'Advanced analytics & insights',
        'Exclusive premium content',
      ],
      'ctaText': 'Upgrade Now - Only ৳199/month',
      'feature': feature,
    };
  }

  // Reset daily usage (called automatically at midnight)
  static Future<void> resetDailyUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      // Archive yesterday's data
      final yesterdayDoc = await _firestore
          .collection('user_usage')
          .doc(user.uid)
          .collection('daily')
          .doc(yesterdayStr)
          .get();

      if (yesterdayDoc.exists) {
        await _firestore
            .collection('user_usage')
            .doc(user.uid)
            .collection('archived')
            .doc(yesterdayStr)
            .set(yesterdayDoc.data()!);

        await yesterdayDoc.reference.delete();
      }
    } catch (e) {
      print('Error resetting daily usage: $e');
    }
  }

  // 🎁 FREE TRIAL METHODS

  // Check if user has already used free trial
  static Future<bool> hasUsedFreeTrial() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      return userData['hasUsedFreeTrial'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Check if user is currently in free trial
  static Future<bool> isInFreeTrial() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final isInTrial = userData['isInFreeTrial'] ?? false;

      if (isInTrial) {
        // Check if trial is still active
        final trialEndDate = userData['freeTrialEndDate'] as Timestamp?;
        if (trialEndDate != null) {
          final isStillActive = trialEndDate.toDate().isAfter(DateTime.now());

          // If trial expired, update status
          if (!isStillActive) {
            await _firestore.collection('users').doc(user.uid).update({
              'isInFreeTrial': false,
            });
            return false;
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Start free trial (7 days)
  static Future<void> startFreeTrial() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if already used trial
      if (await hasUsedFreeTrial()) {
        throw Exception('Free trial already used');
      }

      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 7));

      await _firestore.collection('users').doc(user.uid).update({
        'isInFreeTrial': true,
        'hasUsedFreeTrial': true,
        'freeTrialStartDate': Timestamp.fromDate(now),
        'freeTrialEndDate': Timestamp.fromDate(trialEndDate),
        'updatedAt': Timestamp.fromDate(now),
      });

      // Log trial start event
      await _firestore.collection('analytics').add({
        'event': 'free_trial_started',
        'userId': user.uid,
        'timestamp': Timestamp.fromDate(now),
        'trialEndDate': Timestamp.fromDate(trialEndDate),
      });
    } catch (e) {
      throw Exception('Failed to start free trial: $e');
    }
  }

  // Get remaining trial days
  static Future<int> getRemainingTrialDays() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (!await isInFreeTrial()) return 0;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return 0;

      final userData = userDoc.data()!;
      final trialEndDate = userData['freeTrialEndDate'] as Timestamp?;

      if (trialEndDate != null) {
        final now = DateTime.now();
        final endDate = trialEndDate.toDate();

        if (endDate.isAfter(now)) {
          return endDate.difference(now).inDays + 1;
        }
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get today's usage for all features
  static Future<Map<String, int>> getTodayUsage() async {
    try {
      final Map<String, int> usage = {};

      // Get calculator usage
      usage['calculator'] = await getDailyUsage('calculator_uses');

      // Get AI chat usage
      usage['aiChat'] = await getDailyUsage('ai_chat_messages');

      // Get nutrition usage
      usage['nutrition'] = await getDailyUsage('nutrition_logs');

      // Get workout usage
      usage['workout'] = await getDailyUsage('workout_saves');

      // Get community usage
      usage['community'] = await getDailyUsage('community_posts');

      return usage;
    } catch (e) {
      // Return empty usage on error
      return {
        'calculator': 0,
        'aiChat': 0,
        'nutrition': 0,
        'workout': 0,
        'community': 0,
      };
    }
  }
}
