import 'package:flutter/material.dart';
import 'package:health_nest/src/screens/onboarding/signup_screen.dart';
import 'package:health_nest/src/widgets/main_navigation.dart';

// Authentication Screens
import '../screens/onboarding/login_screen.dart';

// Core Screens
import '../screens/home_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/exercise_screen.dart';
import '../screens/history_screen.dart';
import '../screens/community_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/documentation_screen.dart';
import '../screens/paid_services_screen.dart';

// Messaging Screens
import '../screens/messaging/chat_list_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/messaging/profile_view_screen.dart';

// Main Navigation Widget

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mainNavigation = '/'; // Root route for the main app UI
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String exercise = '/exercise';
  static const String history = '/history';
  static const String community = '/community';
  static const String aiCoach = '/ai-coach';
  static const String profile = '/profile';
  static const String documentation = '/documentation';
  static const String paidServices = '/paid-services';

  // Messaging routes
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String profileView = '/profile-view';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      mainNavigation: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      nutrition: (context) => const NutritionScreen(),
      exercise: (context) => const ExerciseScreen(),
      history: (context) => const HistoryScreen(),
      community: (context) => const CommunityScreen(),
      profile: (context) => const ProfileScreen(),
      documentation: (context) => const DocumentationScreen(),
      paidServices: (context) => const PaidServicesScreen(),
      chatList: (context) => const ChatListScreen(),
      chat: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatScreen(
          chatId: args['chatId'] as String,
          otherUserId: args['otherUserId'] as String,
        );
      },
      profileView: (context) => const ProfileViewScreen(),
    };
  }
}
