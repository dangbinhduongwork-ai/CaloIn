import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/features/profile/data/profile_repository_impl.dart';
import 'package:caloin/features/profile/domain/macro_split.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/user_profile.dart';
import 'package:caloin/features/settings/data/settings_repository_impl.dart';
import 'package:caloin/features/settings/domain/settings_enums.dart';

void main() {
  group('ProfileRepositoryImpl Tests', () {
    test('Returns null when no profile saved or corrupted JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ProfileRepositoryImpl(prefs);

      final initial = await repo.getProfile();
      expect(initial, isNull);

      // Corrupted JSON
      await prefs.setString('user_profile_json', 'invalid json string {{{');
      final corrupted = await repo.getProfile();
      expect(corrupted, isNull);

      // Missing required fields
      await prefs.setString('user_profile_json', '{"gender": "male"}');
      final missingFields = await repo.getProfile();
      expect(missingFields, isNull);
    });

    test('Saves and retrieves profile correctly (always metric in storage)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ProfileRepositoryImpl(prefs);

      const profile = UserProfile(
        gender: Gender.male,
        age: 30,
        heightCm: 175.0,
        weightKg: 70.0,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.maintain,
        dailyGoalKcal: 2560,
        isGoalManual: false,
        macroSplit: MacroSplit(proteinPct: 25, carbPct: 45, fatPct: 30),
      );

      await repo.saveProfile(profile);

      final retrieved = await repo.getProfile();
      expect(retrieved, isNotNull);
      expect(retrieved?.gender, Gender.male);
      expect(retrieved?.age, 30);
      expect(retrieved?.heightCm, 175.0);
      expect(retrieved?.weightKg, 70.0);
      expect(retrieved?.activityLevel, ActivityLevel.moderate);
      expect(retrieved?.goal, Goal.maintain);
      expect(retrieved?.dailyGoalKcal, 2560);
      expect(retrieved?.isGoalManual, isFalse);
      expect(retrieved?.macroSplit.proteinPct, 25);
      expect(retrieved?.macroSplit.carbPct, 45);
      expect(retrieved?.macroSplit.fatPct, 30);
    });

    test('Deletes profile correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ProfileRepositoryImpl(prefs);

      const profile = UserProfile(
        gender: Gender.female,
        age: 28,
        heightCm: 160.0,
        weightKg: 52.0,
        activityLevel: ActivityLevel.light,
        goal: Goal.lose,
        dailyGoalKcal: 1200,
      );

      await repo.saveProfile(profile);
      expect(await repo.getProfile(), isNotNull);

      await repo.deleteProfile();
      expect(await repo.getProfile(), isNull);
    });
  });

  group('SettingsRepositoryImpl Tests', () {
    test('Default to kg and cm; saves and reads units correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepositoryImpl(prefs);

      final defaults = await repo.getSettings();
      expect(defaults.weightUnit, WeightUnit.kg);
      expect(defaults.heightUnit, HeightUnit.cm);

      const customSettings = UserSettings(
        weightUnit: WeightUnit.lb,
        heightUnit: HeightUnit.ftIn,
      );
      await repo.saveSettings(customSettings);

      final updated = await repo.getSettings();
      expect(updated.weightUnit, WeightUnit.lb);
      expect(updated.heightUnit, HeightUnit.ftIn);
    });
  });
}
