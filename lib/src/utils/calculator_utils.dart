double calculateBMI(double weight, double height) {
  return weight / (height * height);
}

int calculateCalories(int age, double weight, double height, String activityLevel) {
  // Harris-Benedict Formula (for men, simplified)
  double bmr = 10 * weight + 6.25 * height * 100 - 5 * age + 5;
  double multiplier;
  switch (activityLevel) {
    case 'sedentary':
      multiplier = 1.2;
      break;
    case 'moderate':
      multiplier = 1.55;
      break;
    case 'active':
      multiplier = 1.725;
      break;
    default:
      multiplier = 1.55;
  }
  return (bmr * multiplier).toInt();
}