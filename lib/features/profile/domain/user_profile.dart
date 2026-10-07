import 'macro_split.dart';
import 'profile_enums.dart';

class UserProfile {
  const UserProfile({
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    required this.dailyGoalKcal,
    this.isGoalManual = false,
    this.macroSplit = MacroSplit.defaultSplit,
  });

  final Gender gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Goal goal;
  final int dailyGoalKcal;
  final bool isGoalManual;
  final MacroSplit macroSplit;

  UserProfile copyWith({
    Gender? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Goal? goal,
    int? dailyGoalKcal,
    bool? isGoalManual,
    MacroSplit? macroSplit,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyGoalKcal: dailyGoalKcal ?? this.dailyGoalKcal,
      isGoalManual: isGoalManual ?? this.isGoalManual,
      macroSplit: macroSplit ?? this.macroSplit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          gender == other.gender &&
          age == other.age &&
          heightCm == other.heightCm &&
          weightKg == other.weightKg &&
          activityLevel == other.activityLevel &&
          goal == other.goal &&
          dailyGoalKcal == other.dailyGoalKcal &&
          isGoalManual == other.isGoalManual &&
          macroSplit == other.macroSplit;

  @override
  int get hashCode => Object.hash(
        gender,
        age,
        heightCm,
        weightKg,
        activityLevel,
        goal,
        dailyGoalKcal,
        isGoalManual,
        macroSplit,
      );

  @override
  String toString() =>
      'UserProfile(gender: $gender, age: $age, height: ${heightCm}cm, weight: ${weightKg}kg, goal: $goal, target: $dailyGoalKcal kcal)';
}
