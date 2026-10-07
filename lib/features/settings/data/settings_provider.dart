import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../domain/settings_enums.dart';
import '../domain/settings_repository.dart';
import 'settings_repository_impl.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier(this._repo) : super(const UserSettings()) {
    _loadSettings();
  }

  final SettingsRepository _repo;

  Future<void> _loadSettings() async {
    final s = await _repo.getSettings();
    state = s;
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    final updated = state.copyWith(weightUnit: unit);
    state = updated;
    await _repo.saveSettings(updated);
  }

  Future<void> setHeightUnit(HeightUnit unit) async {
    final updated = state.copyWith(heightUnit: unit);
    state = updated;
    await _repo.saveSettings(updated);
  }
}
