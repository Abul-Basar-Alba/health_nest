// test/freemium_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:health_nest/src/services/freemium_service.dart';

void main() {
  group('Freemium Service Tests', () {
    test('Daily limits should be defined correctly', () {
      expect(FreemiumService.dailyLimits['calculator_uses'], 20);
      expect(FreemiumService.dailyLimits['ai_chat_messages'], 500);
      expect(FreemiumService.dailyLimits['nutrition_logs'], 10);
      expect(FreemiumService.dailyLimits['workout_saves'], 5);
      expect(FreemiumService.dailyLimits['community_posts'], 3);
      expect(FreemiumService.dailyLimits['exercise_downloads'], 2);
    });

    test('Premium features should be defined', () {
      expect(FreemiumService.premiumFeatures.length, greaterThan(5));
      expect(FreemiumService.premiumFeatures, contains('unlimited_calculator'));
      expect(FreemiumService.premiumFeatures, contains('unlimited_ai_chat'));
      expect(FreemiumService.premiumFeatures, contains('advanced_analytics'));
    });

    test('Service should handle non-authenticated users gracefully', () async {
      // When no user is logged in, should return false for premium
      // Note: This will actually return false when Firebase Auth has no current user
      final isPremium = await FreemiumService.isPremiumUser();
      expect(isPremium, isFalse);
    });

    test('Daily usage should return 0 for non-authenticated users', () async {
      final usage = await FreemiumService.getDailyUsage('calculator_uses');
      expect(usage, 0);
    });
  });
}
