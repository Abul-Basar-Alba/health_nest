// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'src/providers/user_provider.dart';
import 'src/providers/history_provider.dart';
import 'src/providers/step_provider.dart';
import 'src/providers/chat_provider.dart';
import 'src/providers/nutrition_provider.dart';
import 'src/providers/recommendation_provider.dart';
import 'src/providers/community_provider.dart';
import 'src/providers/exercise_provider.dart'; // এই লাইনটি যোগ করা হয়েছে
import 'src/providers/selected_exercise_provider.dart'; // নতুন provider
import 'src/providers/notification_provider.dart'; // Notification provider
import 'src/routes/app_routes.dart';
import 'src/providers/workout_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env ফাইল লোড করা হবে সব প্ল্যাটফর্মে
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => StepProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => SelectedExerciseProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                WorkoutHistoryProvider()), // এই লাইনটি যোগ করা হয়েছে
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'HealthNest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          fontFamily: 'Inter',
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green[600],
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
            displayMedium: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
            displaySmall: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
            headlineMedium: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
            headlineSmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700]),
            titleLarge: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            bodyLarge: const TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: const TextStyle(fontSize: 14, color: Colors.black87),
            labelLarge: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
