import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/profile/data/profile_providers.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/user_profile.dart';

void main() {
  group('ProfileNotifier & NutritionTargetProvider Tests', () {
    test('Recalculates target when weight changes and goal is automatic; preserves target when manual', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // Initial auto profile: Male 30yo, 70kg, 175cm, moderate -> maintain target = 2560 kcal
      const initialProfile = UserProfile(
        gender: Gender.male,
        age: 30,
        heightCm: 175.0,
        weightKg: 70.0,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.maintain,
        dailyGoalKcal: 2560,
        isGoalManual: false,
      );

      final notifier = container.read(profileProvider.notifier);
      await notifier.saveProfile(initialProfile);

      expect(container.read(profileProvider).value?.dailyGoalKcal, 2560);

      // Update weight to 80kg (not manual):
      // BMR = 10*80 + 6.25*175 - 5*30 + 5 = 800 + 1093.75 - 150 + 5 = 1748.75
      // TDEE = 1748.75 * 1.55 = 2710.5625 -> roundTo10 = 2710
      await notifier.updateProfile(weightKg: 80.0);
      final updatedProfile = container.read(profileProvider).value;
      expect(updatedProfile?.weightKg, 80.0);
      expect(updatedProfile?.isGoalManual, isFalse);
      expect(updatedProfile?.dailyGoalKcal, 2710); // Automatically recalculated!

      // Now set manual target = 2200 kcal
      await notifier.updateProfile(
        dailyGoalKcal: 2200,
        isGoalManual: true,
      );
      final manualProfile = container.read(profileProvider).value;
      expect(manualProfile?.isGoalManual, isTrue);
      expect(manualProfile?.dailyGoalKcal, 2200);

      // Change weight to 90kg while manual: dailyGoalKcal should remain 2200!
      await notifier.updateProfile(weightKg: 90.0);
      final afterWeightChangeManual = container.read(profileProvider).value;
      expect(afterWeightChangeManual?.weightKg, 90.0);
      expect(afterWeightChangeManual?.dailyGoalKcal, 2200); // Preserved!

      // Revert to suggested goal:
      await notifier.resetToSuggestedGoal();
      final reverted = container.read(profileProvider).value;
      expect(reverted?.isGoalManual, isFalse);
      // For 90kg, BMR = 900 + 1093.75 - 150 + 5 = 1848.75 -> TDEE = 1848.75 * 1.55 = 2865.56 -> 2870
      expect(reverted?.dailyGoalKcal, 2870);
    });

    test('nutritionTargetProvider calculates correct macro grams from current profile', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      const profile = UserProfile(
        gender: Gender.male,
        age: 25,
        heightCm: 170.0,
        weightKg: 65.0,
        activityLevel: ActivityLevel.sedentary,
        goal: Goal.maintain,
        dailyGoalKcal: 2000,
      );

      await container.read(profileProvider.notifier).saveProfile(profile);

      final target = container.read(nutritionTargetProvider);
      expect(target, isNotNull);
      expect(target?.targetKcal, 2000);
      expect(target?.proteinGrams, closeTo(100.0, 1e-4));
      expect(target?.carbGrams, closeTo(250.0, 1e-4));
      expect(target?.fatGrams, closeTo(66.6667, 1e-3));
    });
  });
}
