import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/nutrition_screen.dart';

class AppRoutes {
  static final routes = {
    '/login': (context) => LoginScreen(),
    '/home': (context) => HomeScreen(),
    '/calculator': (context) => CalculatorScreen(),
    '/nutrition': (context) => NutritionScreen(),
  };
}
