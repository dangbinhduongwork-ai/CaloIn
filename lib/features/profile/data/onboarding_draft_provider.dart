import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/calorie_goal_calculator.dart';
import '../domain/macro_split.dart';
import '../domain/profile_enums.dart';
import '../domain/user_profile.dart';

class OnboardingDraft {
  const OnboardingDraft({
    this.gender = Gender.male,
    this.age = 25,
    this.heightCm = 170.0,
    this.weightKg = 65.0,
    this.activityLevel = ActivityLevel.sedentary,
    this.goal = Goal.maintain,
    this.macroSplit = MacroSplit.defaultSplit,
    this.customDailyGoalKcal,
    this.isGoalManual = false,
  });

  final Gender gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Goal goal;
  final MacroSplit macroSplit;
  final int? customDailyGoalKcal;
  final bool isGoalManual;

  OnboardingDraft copyWith({
    Gender? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Goal? goal,
    MacroSplit? macroSplit,
    int? customDailyGoalKcal,
    bool? isGoalManual,
  }) {
    return OnboardingDraft(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      macroSplit: macroSplit ?? this.macroSplit,
      customDailyGoalKcal: customDailyGoalKcal ?? this.customDailyGoalKcal,
      isGoalManual: isGoalManual ?? this.isGoalManual,
    );
  }

  CalorieGoalResult calculateResult() {
    return CalorieGoalCalculator.calculate(
      gender: gender,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      goal: goal,
    );
  }

  UserProfile toUserProfile() {
    final calc = calculateResult();
    final targetKcal = isGoalManual && customDailyGoalKcal != null
        ? customDailyGoalKcal!
        : calc.targetKcal;

    return UserProfile(
      gender: gender,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      goal: goal,
      dailyGoalKcal: targetKcal,
      isGoalManual: isGoalManual,
      macroSplit: macroSplit,
    );
  }
}

final onboardingDraftProvider = StateProvider<OnboardingDraft>((ref) {
  return const OnboardingDraft();
});
