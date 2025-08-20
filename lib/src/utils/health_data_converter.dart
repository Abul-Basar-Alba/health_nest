class HealthDataConverter {
  /// Converts centimeters to feet and inches.
  static String convertCmToFtIn(double cm) {
    if (cm <= 0) return '0\' 0"';
    final double totalInches = cm / 2.54;
    final int feet = (totalInches / 12).floor();
    final int inches = (totalInches % 12).round();
    return '$feet\' $inches"';
  }

  /// Converts kilograms to pounds.
  static double convertKgToLbs(double kg) {
    if (kg <= 0) return 0.0;
    return double.parse((kg * 2.20462).toStringAsFixed(1));
  }

  /// Converts pounds to kilograms.
  static double convertLbsToKg(double lbs) {
    if (lbs <= 0) return 0.0;
    return double.parse((lbs / 2.20462).toStringAsFixed(1));
  }

  /// Converts meters to miles.
  static double convertMetersToMiles(double meters) {
    if (meters <= 0) return 0.0;
    return double.parse((meters * 0.000621371).toStringAsFixed(2));
  }
}
