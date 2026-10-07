import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../domain/food.dart';
import '../domain/food_repository.dart';
import 'food_repository_impl.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FoodRepositoryImpl(db: db, prefs: prefs);
});

final favoriteFoodsStreamProvider = StreamProvider<List<Food>>((ref) {
  final repo = ref.watch(foodRepositoryProvider);
  return repo.watchFavorites();
});

final customFoodsStreamProvider = StreamProvider<List<Food>>((ref) {
  final repo = ref.watch(foodRepositoryProvider);
  return repo.watchCustomFoods();
});

Future<void> initializeFoodsSeed(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final savedVersion = prefs.getInt('foods_seed_version') ?? 0;

  if (savedVersion < AppConstants.currentSeedVersion) {
    final repo = ref.read(foodRepositoryProvider);
    final jsonStr = await rootBundle.loadString('assets/data/foods_seed.json');
    final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
    final List<dynamic> foodsList = data['foods'] as List<dynamic>;
    final rawFoods = foodsList.cast<Map<String, dynamic>>();

    await repo.seedFoods(rawFoods, version: AppConstants.currentSeedVersion);
  }
}
