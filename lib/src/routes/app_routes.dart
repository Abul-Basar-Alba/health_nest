import 'package:health_nest/src/screens/activity_dashboard_screen.dart';

import '../screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/main.dart';
import 'package:health_nest/src/screens/dashboard_screen.dart';
import 'package:health_nest/src/screens/onboarding/signup_screen.dart';
import 'package:health_nest/src/screens/step_count_screen.dart';
import 'package:health_nest/src/widgets/main_navigation.dart';
import 'package:health_nest/src/models/user_model.dart'; // Import UserModel

// Authentication Screens
import '../screens/onboarding/login_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';

// Core Screens
import '../screens/home_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/exercise_screen.dart';
import '../screens/activity_dashboard_screen.dart'
    hide ActivityDashboardScreen; // New: Activity Dashboard
import '../screens/history_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/documentation_screen.dart';
import '../screens/paid_services_screen.dart';
import '../screens/admin_contact_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/recommendation_screen.dart';
import '../screens/admin_panel_screen.dart'; // New: Import AdminPanelScreen
import '../screens/progress_tracker_screen.dart'; // New: Import ProgressTrackerScreen

// Messaging Screens
import '../screens/messaging/chat_list_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/messaging/profile_view_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String mainNavigation = '/';
  static const String mainScreen = '/main';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String exercise = '/exercise';
  static const String activityDashboard = '/activity-dashboard';
  static const String history = '/history';
  static const String community = '/community';
  static const String calculator = '/calculator';
  static const String recommendations = '/recommendations';
  static const String adminContact = '/admin-contact';
  static const String profile = '/profile';
  static const String documentation = '/documentation';
  static const String paidServices = '/paid-services';
  static const String stepCount = '/step-count';
  static const String adminPanel = '/admin-panel'; // New: Admin panel route
  static const String progressTracker =
      '/progress-tracker'; // New: Progress tracker route

  // Messaging routes
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String profileView = '/profile-view';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      dashboard: (context) => const DashboardScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      mainNavigation: (context) => const MainNavigation(),
      mainScreen: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      nutrition: (context) => const NutritionScreen(),
      exercise: (context) => const ExerciseScreen(),
      activityDashboard: (context) => const ActivityDashboardScreen(),
      history: (context) => const HistoryScreen(),
      community: (context) => const CommunityScreen(),
      calculator: (context) => const CalculatorScreen(),
      recommendations: (context) => const RecommendationScreen(),
      adminContact: (context) => const AdminContactScreen(),
      profile: (context) => const ProfileScreen(),
      documentation: (context) => const DocumentationScreen(),
      paidServices: (context) => const PaidServicesScreen(),
      stepCount: (context) => const StepTrackingScreen(),
      adminPanel: (context) =>
          const AdminPanelScreen(), // New: Add AdminPanelScreen
      progressTracker: (context) =>
          const ProgressTrackerScreen(), // New: Add ProgressTrackerScreen
      chatList: (context) => const ChatListScreen(),
    };
  }

  // Use onGenerateRoute for routes that require arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        if (!args.containsKey('chatId') || !args.containsKey('otherUserId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Error: Missing chat arguments')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'] as String,
            otherUserId: args['otherUserId'] as String,
          ),
        );
      case profileView:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => ProfileViewScreen(user: user),
        );
      default:
        // Return null for routes defined in the 'routes' map
        return null;
    }
  }
}
