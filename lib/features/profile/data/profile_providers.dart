import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../domain/calorie_goal_calculator.dart';
import '../domain/macro_calculator.dart';
import '../domain/macro_split.dart';
import '../domain/profile_enums.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';
import 'profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileRepositoryImpl(prefs);
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.saveProfile(profile);
      return profile;
    });
  }

  Future<void> updateProfile({
    Gender? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Goal? goal,
    int? dailyGoalKcal,
    bool? isGoalManual,
    MacroSplit? macroSplit,
  }) async {
    final current = state.value;
    if (current == null) return;

    final newGender = gender ?? current.gender;
    final newAge = age ?? current.age;
    final newHeightCm = heightCm ?? current.heightCm;
    final newWeightKg = weightKg ?? current.weightKg;
    final newActivityLevel = activityLevel ?? current.activityLevel;
    final newGoal = goal ?? current.goal;
    final newMacroSplit = macroSplit ?? current.macroSplit;
    final newIsGoalManual = isGoalManual ?? current.isGoalManual;

    int newTargetKcal;
    if (newIsGoalManual) {
      newTargetKcal = dailyGoalKcal ?? current.dailyGoalKcal;
    } else {
      final calculatedResult = CalorieGoalCalculator.calculate(
        gender: newGender,
        age: newAge,
        heightCm: newHeightCm,
        weightKg: newWeightKg,
        activityLevel: newActivityLevel,
        goal: newGoal,
      );
      newTargetKcal = calculatedResult.targetKcal;
    }

    final updated = current.copyWith(
      gender: newGender,
      age: newAge,
      heightCm: newHeightCm,
      weightKg: newWeightKg,
      activityLevel: newActivityLevel,
      goal: newGoal,
      dailyGoalKcal: newTargetKcal,
      isGoalManual: newIsGoalManual,
      macroSplit: newMacroSplit,
    );

    await saveProfile(updated);
  }

  Future<void> resetToSuggestedGoal() async {
    final current = state.value;
    if (current == null) return;
    await updateProfile(isGoalManual: false);
  }

  Future<void> clearProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.deleteProfile();
    state = const AsyncValue.data(null);
  }
}

class NutritionTarget {
  const NutritionTarget({
    required this.targetKcal,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.macroSplit,
  });

  final int targetKcal;
  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;
  final MacroSplit macroSplit;
}

final nutritionTargetProvider = Provider<NutritionTarget?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final profile = profileAsync.value;
  if (profile == null) return null;

  final macroGrams = MacroCalculator.calculateGrams(
    targetKcal: profile.dailyGoalKcal,
    macroSplit: profile.macroSplit,
  );

  return NutritionTarget(
    targetKcal: profile.dailyGoalKcal,
    proteinGrams: macroGrams.proteinGrams,
    carbGrams: macroGrams.carbGrams,
    fatGrams: macroGrams.fatGrams,
    macroSplit: profile.macroSplit,
  );
});
