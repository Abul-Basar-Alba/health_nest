import 'package:flutter/material.dart';
import 'package:health_nest/src/models/user_model.dart'; // Import UserModel
import 'package:health_nest/src/screens/dashboard_screen.dart';
import 'package:health_nest/src/widgets/main_navigation.dart';

import '../screens/admin_chat_screen.dart';
import '../screens/admin_contact_screen.dart';
import '../screens/admin_dashboard_screen.dart'; // New: Admin Dashboard
import '../screens/auth/modern_login_screen.dart';
import '../screens/auth/modern_signup_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
// Authentication Screens (Modern)
import '../screens/auth/splash_auth_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/calculators/premium_bmi_calculator_screen.dart';
import '../screens/community/premium_community_screen.dart';
import '../screens/community_screen.dart';
import '../screens/community_users_screen.dart';
import '../screens/documentation_screen.dart';
import '../screens/exercise_screen.dart';
import '../screens/history/history_screen.dart'; // Updated import path
// Core Screens
import '../screens/home_screen.dart';
// Messaging Screens
import '../screens/messaging/chat_list_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/messaging/profile_view_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/paid_services_screen.dart';
import '../screens/pregnancy/bump_photos_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/contraction_timer_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/doctor_visits_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/family_support_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/kick_counter_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/postpartum_tracker_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/pregnancy_report_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/pregnancy_tracker_screen.dart'; // Pregnancy Tracker
import '../screens/pregnancy/week_details_screen.dart'; // Pregnancy Tracker
import '../screens/premium_services_screen.dart'; // New: Import PremiumServicesScreen
import '../screens/profile/change_password_screen.dart';
// Profile Screens
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_tracker_screen.dart'; // New: Import ProgressTrackerScreen
import '../screens/recommendation_screen.dart';
import '../screens/settings/account_settings_screen.dart'; // Settings Screens
import '../screens/settings/privacy_settings_screen.dart'; // Settings Screens
import '../screens/settings/voice_settings_screen.dart'; // Settings Screens
import '../screens/step_counter_dashboard_screen.dart'; // Step Counter (New)
import '../screens/vscode_firebase_manager.dart';

class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String mainNavigation = '/main';
  static const String mainScreen = '/main-screen';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String exercise = '/exercise';
  static const String activityDashboard = '/activity-dashboard';
  static const String stepCounter = '/step-counter';
  static const String history = '/history';
  static const String community = '/community';
  static const String premiumCommunity = '/premium-community';
  static const String calculator = '/calculator';
  static const String premiumBMICalculator = '/premium-bmi-calculator';
  static const String recommendations = '/recommendations';
  static const String adminContact = '/admin-contact';
  static const String vscodeFirebaseManager = '/vscode-firebase-manager';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String privacySettings = '/privacy-settings'; // New
  static const String accountSettings = '/account-settings'; // New
  static const String voiceSettings = '/voice-settings'; // New
  static const String pregnancyReport = '/pregnancy-report'; // New
  static const String documentation = '/documentation';
  static const String paidServices = '/paid-services';
  static const String premiumServices =
      '/premium-services'; // New: Premium services route
  static const String premium = '/premium'; // Premium/Subscription screen
  static const String progressTracker =
      '/progress-tracker'; // New: Progress tracker route
  static const String adminDashboard =
      '/admin-dashboard'; // Admin Dashboard route

  // Pregnancy Tracker routes
  static const String pregnancyTracker = '/pregnancy-tracker';
  static const String weekDetails = '/week-details';
  static const String kickCounter = '/kick-counter';
  static const String contractionTimer = '/contraction-timer';
  static const String doctorVisits = '/doctor-visits';
  static const String familySupport = '/family-support';
  static const String bumpPhotos = '/bump-photos';
  static const String postpartumTracker = '/postpartum-tracker';

  // Messaging routes
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String profileView = '/profile-view';
  static const String communityUsers = '/community-users';
  static const String adminChat = '/admin-chat';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashAuthScreen(),
      dashboard: (context) => const DashboardScreen(),
      login: (context) => const ModernLoginScreen(),
      signup: (context) => const ModernSignupScreen(),
      mainNavigation: (context) => const MainNavigation(),
      mainScreen: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      nutrition: (context) => const NutritionScreen(),
      exercise: (context) => const ExerciseScreen(),
      activityDashboard: (context) =>
          const StepCounterDashboardScreen(), // Activity Dashboard = Step Counter
      stepCounter: (context) => const StepCounterDashboardScreen(),
      history: (context) => const HistoryScreen(),
      community: (context) => const CommunityScreen(),
      premiumCommunity: (context) => const PremiumCommunityScreen(),
      calculator: (context) => const CalculatorScreen(),
      premiumBMICalculator: (context) => const PremiumBMICalculatorScreen(),
      recommendations: (context) => const RecommendationScreen(),
      adminContact: (context) => const AdminContactScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      privacySettings: (context) => const PrivacySettingsScreen(), // New
      accountSettings: (context) => const AccountSettingsScreen(), // New
      voiceSettings: (context) => const VoiceSettingsScreen(), // New
      pregnancyReport: (context) => const PregnancyReportScreen(), // New
      documentation: (context) => const DocumentationScreen(),
      paidServices: (context) => const PaidServicesScreen(),
      premiumServices: (context) =>
          const PremiumServicesScreen(), // New: Add PremiumServicesScreen
      premium: (context) =>
          const PremiumServicesScreen(), // Premium route for subscription management
      progressTracker: (context) =>
          const ProgressTrackerScreen(), // New: Add ProgressTrackerScreen
      pregnancyTracker: (context) =>
          const PregnancyTrackerScreen(), // Pregnancy Tracker
      weekDetails: (context) => const WeekDetailsScreen(), // Pregnancy Tracker
      kickCounter: (context) => const KickCounterScreen(), // Pregnancy Tracker
      contractionTimer: (context) =>
          const ContractionTimerScreen(), // Pregnancy Tracker
      doctorVisits: (context) =>
          const DoctorVisitsScreen(), // Pregnancy Tracker
      familySupport: (context) =>
          const FamilySupportScreen(), // Pregnancy Tracker
      bumpPhotos: (context) => const BumpPhotosScreen(), // Pregnancy Tracker
      postpartumTracker: (context) =>
          const PostpartumTrackerScreen(), // Pregnancy Tracker
      chatList: (context) => const ChatListScreen(),
      communityUsers: (context) => const CommunityUsersScreen(),
      adminDashboard: (context) =>
          const AdminDashboardScreen(), // New: Admin Dashboard
      vscodeFirebaseManager: (context) => const VSCodeFirebaseManager(),
    };
  }

  // Use onGenerateRoute for routes that require arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case profileSetup:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Error: Missing userId')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
            userId: args['userId'] as String,
          ),
        );
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
      case adminChat:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('recipientId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Error: Missing recipient information')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AdminChatScreen(
            recipientId: args['recipientId'] as String,
            recipientName: args['recipientName'] as String? ?? 'User',
          ),
        );
      default:
        // Return null for routes defined in the 'routes' map
        return null;
    }
  }
}
