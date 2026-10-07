import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/foods/data/food_repository_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Check and seed initial foods if necessary
  final savedVersion = prefs.getInt('foods_seed_version') ?? 0;
  if (savedVersion < AppConstants.currentSeedVersion) {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/foods_seed.json');
      final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
      final List<dynamic> foodsList = data['foods'] as List<dynamic>;
      final rawFoods = foodsList.cast<Map<String, dynamic>>();
      final repo = container.read(foodRepositoryProvider);
      await repo.seedFoods(rawFoods, version: AppConstants.currentSeedVersion);
    } catch (_) {
      // In test environments or when assets are not bundled, gracefully proceed
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CaloInApp(),
    ),
  );
}

class CaloInApp extends ConsumerWidget {
  const CaloInApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CaloIn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
