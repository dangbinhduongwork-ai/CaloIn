import '../../../core/constants/app_constants.dart';
import 'bmr_calculator.dart';
import 'profile_enums.dart';
import 'tdee_calculator.dart';

class CalorieGoalResult {
  const CalorieGoalResult({
    required this.bmr,
    required this.tdee,
    required this.targetKcal,
    required this.floorApplied,
    required this.lossNotAdvisable,
  });

  final double bmr;
  final double tdee;
  final int targetKcal;
  final bool floorApplied;
  final bool lossNotAdvisable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieGoalResult &&
          runtimeType == other.runtimeType &&
          (bmr - other.bmr).abs() < 1e-4 &&
          (tdee - other.tdee).abs() < 1e-4 &&
          targetKcal == other.targetKcal &&
          floorApplied == other.floorApplied &&
          lossNotAdvisable == other.lossNotAdvisable;

  @override
  int get hashCode => Object.hash(bmr, tdee, targetKcal, floorApplied, lossNotAdvisable);

  @override
  String toString() =>
      'CalorieGoalResult(bmr: $bmr, tdee: $tdee, target: $targetKcal kcal, floor: $floorApplied, notAdvisable: $lossNotAdvisable)';
}

class CalorieGoalCalculator {
  CalorieGoalCalculator._();

  static int roundTo10(double value) {
    return ((value / 10.0).round()) * 10;
  }

  static int getSafeFloor(Gender gender) {
    return gender.isMale
        ? AppConstants.maleCalorieFloor
        : AppConstants.femaleCalorieFloor;
  }

  /// Calculates calorie goals with Mifflin-St Jeor BMR, TDEE, and safety constraints.
  static CalorieGoalResult calculate({
    required Gender gender,
    required int age,
    required double heightCm,
    required double weightKg,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) {
    final bmr = BmrCalculator.calculate(
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
    );
    final tdee = TdeeCalculator.calculate(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    final safeFloor = getSafeFloor(gender);

    if (goal == Goal.maintain) {
      return CalorieGoalResult(
        bmr: bmr,
        tdee: tdee,
        targetKcal: roundTo10(tdee),
        floorApplied: false,
        lossNotAdvisable: false,
      );
    }

    if (goal == Goal.gain) {
      return CalorieGoalResult(
        bmr: bmr,
        tdee: tdee,
        targetKcal: roundTo10(tdee + AppConstants.gainWeightCalorieDelta),
        floorApplied: false,
        lossNotAdvisable: false,
      );
    }

    // Goal is lose weight
    // Safe floor rule only applies when goal is lose weight
    if (safeFloor >= tdee) {
      // Cannot safely lose weight via calorie restriction in this app
      return CalorieGoalResult(
        bmr: bmr,
        tdee: tdee,
        targetKcal: roundTo10(tdee),
        floorApplied: false,
        lossNotAdvisable: true,
      );
    }

    final rawLossTarget = tdee + AppConstants.loseWeightCalorieDelta; // TDEE - 500
    if (rawLossTarget < safeFloor) {
      return CalorieGoalResult(
        bmr: bmr,
        tdee: tdee,
        targetKcal: safeFloor,
        floorApplied: true,
        lossNotAdvisable: false,
      );
    }

    return CalorieGoalResult(
      bmr: bmr,
      tdee: tdee,
      targetKcal: roundTo10(rawLossTarget),
      floorApplied: false,
      lossNotAdvisable: false,
    );
  }
}
