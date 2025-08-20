class CalculatorUtils {
  // BMI Calculation
  // Formula: weight (kg) / [height (m)]^2
  static double calculateBMI({
    required double weight,
    required double height,
  }) {
    if (weight <= 0 || height <= 0) {
      return 0.0;
    }
    final double heightInMeters = height / 100;
    return double.parse(
        (weight / (heightInMeters * heightInMeters)).toStringAsFixed(2));
  }

  // Daily Calorie Needs
  // Uses the Mifflin-St Jeor equation.
  static double calculateDailyCalories({
    required int age,
    required double weight,
    required double height,
    required double activityMultiplier,
    required bool isMale,
  }) {
    if (age <= 0 || weight <= 0 || height <= 0 || activityMultiplier <= 0) {
      return 0.0;
    }

    // Basal Metabolic Rate (BMR)
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (isMale) {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    return double.parse((bmr * activityMultiplier).toStringAsFixed(2));
  }

  // Macronutrient (Protein, Fat, Carb) Calculation
  // Standard recommended percentages
  static Map<String, double> calculateMacronutrients(double totalCalories) {
    // A standard distribution: 45-65% Carbs, 20-35% Fat, 10-35% Protein
    const double proteinPercentage = 0.20; // 20%
    const double fatPercentage = 0.25; // 25%
    const double carbsPercentage = 0.55; // 55%

    // 1 gram of protein = 4 kcal
    // 1 gram of fat = 9 kcal
    // 1 gram of carbohydrates = 4 kcal
    final double proteinGrams = (totalCalories * proteinPercentage) / 4;
    final double fatGrams = (totalCalories * fatPercentage) / 9;
    final double carbsGrams = (totalCalories * carbsPercentage) / 4;

    return {
      'protein': double.parse(proteinGrams.toStringAsFixed(1)),
      'fat': double.parse(fatGrams.toStringAsFixed(1)),
      'carbohydrates': double.parse(carbsGrams.toStringAsFixed(1)),
    };
  }

  // Water Needs Calculation (in Liters)
  // General recommendation: 35ml per kg of body weight
  static double calculateWaterNeeds(double weightKg) {
    if (weightKg <= 0) {
      return 0.0;
    }
    final double waterLiters = (weightKg * 35) / 1000;
    return double.parse(waterLiters.toStringAsFixed(1));
  }

  // Placeholder for Vitamin Recommendations (based on AI/API)
  static String getVitaminRecommendations(int age, bool isMale) {
    // This part should ideally come from an AI or a rich database.
    // For this example, we will provide a general recommendation.
    if (age < 18) {
      return 'For overall growth, focus on Vitamin D, Calcium, and Iron.';
    } else if (isMale) {
      return 'Focus on Vitamin C, Magnesium, and Zinc for general health.';
    } else {
      return 'Focus on Iron, Vitamin B12, and Folic Acid.';
    }
  }
}
