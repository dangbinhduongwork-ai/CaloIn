import 'profile_enums.dart';

class BmrCalculator {
  BmrCalculator._();

  /// Calculates Basal Metabolic Rate using the Mifflin-St Jeor equation.
  /// Men: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + 5
  /// Women: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) - 161
  static double calculate({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);
    return gender.isMale ? base + 5.0 : base - 161.0;
  }
}
