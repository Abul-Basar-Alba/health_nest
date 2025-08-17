double calculateBMI(double weight, double height) {
  return weight / ((height / 100) * (height / 100));
}

int calculateCalories(
    int age, double weight, double height, String activityLevel) {
  double bmr = 10 * weight + 6.25 * height - 5 * age + 5; // For males
  switch (activityLevel.toLowerCase()) {
    case 'sedentary':
      return (bmr * 1.2).round();
    case 'light':
      return (bmr * 1.375).round();
    case 'moderate':
      return (bmr * 1.55).round();
    case 'active':
      return (bmr * 1.725).round();
    default:
      return (bmr * 1.2).round();
  }
}
