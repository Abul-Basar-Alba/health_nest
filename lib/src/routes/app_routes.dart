import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/step_count_screen.dart';
import '../screens/exercise_screen.dart';
import '../screens/history_screen.dart';
import '../screens/feedback_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String calculator = '/calculator';
  static const String stepCount = '/step-count';
  static const String exercise = '/exercise';
  static const String history = '/history';
  static const String feedback = '/feedback';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      nutrition: (context) => const NutritionScreen(),
      calculator: (context) => const CalculatorScreen(),
      stepCount: (context) => const StepCountScreen(),
      exercise: (context) => const ExerciseScreen(),
      history: (context) => const HistoryScreen(),
      feedback: (context) => const FeedbackScreen(),
    };
  }
}
