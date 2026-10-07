import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_enums.dart';
import '../domain/settings_repository.dart';

const String _prefWeightUnitKey = 'user_weight_unit';
const String _prefHeightUnitKey = 'user_height_unit';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserSettings> getSettings() async {
    final weightStr = _prefs.getString(_prefWeightUnitKey);
    final heightStr = _prefs.getString(_prefHeightUnitKey);

    final weightUnit = weightStr == 'lb' ? WeightUnit.lb : WeightUnit.kg;
    final heightUnit = heightStr == 'ftIn' ? HeightUnit.ftIn : HeightUnit.cm;

    return UserSettings(
      weightUnit: weightUnit,
      heightUnit: heightUnit,
    );
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setString(
      _prefWeightUnitKey,
      settings.weightUnit == WeightUnit.lb ? 'lb' : 'kg',
    );
    await _prefs.setString(
      _prefHeightUnitKey,
      settings.heightUnit == HeightUnit.ftIn ? 'ftIn' : 'cm',
    );
  }
}
