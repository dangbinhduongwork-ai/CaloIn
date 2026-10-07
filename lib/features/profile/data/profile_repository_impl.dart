import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/macro_split.dart';
import '../domain/profile_enums.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

const String _prefProfileKey = 'user_profile_json';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserProfile?> getProfile() async {
    final jsonStr = _prefs.getString(_prefProfileKey);
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;

    try {
      final Map<String, dynamic> map = json.decode(jsonStr) as Map<String, dynamic>;

      // Ensure all critical fields exist
      if (!map.containsKey('gender') ||
          !map.containsKey('age') ||
          !map.containsKey('heightCm') ||
          !map.containsKey('weightKg') ||
          !map.containsKey('activityLevel') ||
          !map.containsKey('goal') ||
          !map.containsKey('dailyGoalKcal')) {
        return null;
      }

      final gender = Gender.values.byName(map['gender'] as String);
      final age = (map['age'] as num).toInt();
      final heightCm = (map['heightCm'] as num).toDouble();
      final weightKg = (map['weightKg'] as num).toDouble();
      final activityLevel = ActivityLevel.values.byName(map['activityLevel'] as String);
      final goal = Goal.values.byName(map['goal'] as String);
      final dailyGoalKcal = (map['dailyGoalKcal'] as num).toInt();
      final isGoalManual = (map['isGoalManual'] as bool?) ?? false;

      MacroSplit macroSplit = MacroSplit.defaultSplit;
      if (map['macroSplit'] is Map<String, dynamic>) {
        final macroMap = map['macroSplit'] as Map<String, dynamic>;
        macroSplit = MacroSplit(
          proteinPct: (macroMap['proteinPct'] as num).toInt(),
          carbPct: (macroMap['carbPct'] as num).toInt(),
          fatPct: (macroMap['fatPct'] as num).toInt(),
        );
      }

      return UserProfile(
        gender: gender,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        goal: goal,
        dailyGoalKcal: dailyGoalKcal,
        isGoalManual: isGoalManual,
        macroSplit: macroSplit,
      );
    } catch (_) {
      // If parsing fails or data is corrupted, treat as no profile
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final map = {
      'gender': profile.gender.name,
      'age': profile.age,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'activityLevel': profile.activityLevel.name,
      'goal': profile.goal.name,
      'dailyGoalKcal': profile.dailyGoalKcal,
      'isGoalManual': profile.isGoalManual,
      'macroSplit': {
        'proteinPct': profile.macroSplit.proteinPct,
        'carbPct': profile.macroSplit.carbPct,
        'fatPct': profile.macroSplit.fatPct,
      },
    };

    await _prefs.setString(_prefProfileKey, json.encode(map));
  }

  @override
  Future<void> deleteProfile() async {
    await _prefs.remove(_prefProfileKey);
  }
}
