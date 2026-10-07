import 'profile_enums.dart';

class TdeeCalculator {
  TdeeCalculator._();

  /// Calculates Total Daily Energy Expenditure (TDEE).
  /// TDEE = BMR * ActivityLevel.factor
  static double calculate({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.factor;
  }
}
