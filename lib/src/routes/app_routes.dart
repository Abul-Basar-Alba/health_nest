import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/step_count_screen.dart';
import '../screens/exercise_screen.dart';
import '../screens/history_screen.dart';
import '../screens/community_screen.dart';
import '../screens/recommendation_screen.dart';
import '../screens/documentation_screen.dart' hide DashboardScreen;
import '../screens/admin_contact_screen.dart';
import '../screens/paid_services_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String nutrition = '/nutrition';
  static const String calculator = '/calculator';
  static const String stepCount = '/step-count';
  static const String exercise = '/exercise';
  static const String history = '/history';
  static const String community = '/community';
  static const String recommendation = '/recommendation';
  static const String documentation = '/documentation';
  static const String adminContact = '/admin-contact';
  static const String paidServices = '/paid-services';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      dashboard: (context) => const DashboardScreen(),
      nutrition: (context) => const NutritionScreen(),
      calculator: (context) => const CalculatorScreen(),
      stepCount: (context) => const StepTrackingScreen(),
      exercise: (context) => const ExerciseScreen(),
      history: (context) => const HistoryScreen(),
      community: (context) => const CommunityScreen(),
      recommendation: (context) => const RecommendationScreen(),
      documentation: (context) => const DashboardScreen(),
      adminContact: (context) => const AdminContactScreen(),
      paidServices: (context) => const PaidServicesScreen(),
    };
  }
}
