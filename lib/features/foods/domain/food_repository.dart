import 'food.dart';

abstract class FoodRepository {
  /// Search foods with optional category filter.
  /// Words in query are normalized (unaccented).
  /// Ranking: startsWith query > isFavorite > name.
  Future<List<Food>> search(
    String query, {
    String? category,
    int limit = 50,
  });

  /// Stream of favorite foods.
  Stream<List<Food>> watchFavorites();

  /// Stream of user-created custom foods.
  Stream<List<Food>> watchCustomFoods();

  /// Get all foods.
  Future<List<Food>> getAllFoods();

  /// Get food by ID.
  Future<Food?> getFoodById(String id);

  /// Toggle favorite status of a food.
  Future<void> toggleFavorite(String foodId);

  /// Add custom food (isCustom must be true).
  Future<Food> addCustomFood(Food food);

  /// Update custom food (only custom foods can be updated).
  Future<void> updateCustomFood(Food food);

  /// Delete custom food (only custom foods can be deleted).
  Future<void> deleteCustomFood(String foodId);

  /// Seed database from JSON string or map list.
  /// Upserts based on seedKey, preserving isFavorite and custom foods.
  Future<void> seedFoods(List<Map<String, dynamic>> rawFoods, {required int version});
}
