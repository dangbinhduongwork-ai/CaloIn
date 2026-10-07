import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/theme_provider.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadInitial(SharedPreferences prefs) {
    final languageCode = prefs.getString(AppConstants.prefLanguage) ?? 'vi';
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(AppConstants.prefLanguage, locale.languageCode);
  }
}
