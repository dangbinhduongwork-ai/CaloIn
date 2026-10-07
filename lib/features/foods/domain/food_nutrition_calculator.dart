import 'food.dart';
import 'nutrition.dart';

class FoodNutritionCalculator {
  FoodNutritionCalculator._();

  /// Calculates Nutrition for a given Food and consumed quantity in grams.
  /// Nutrition = (value_per_100g * grams) / 100
  static Nutrition calculate({
    required Food food,
    required double grams,
  }) {
    if (grams <= 0) return Nutrition.zero;

    final factor = grams / 100.0;
    return Nutrition(
      kcal: food.kcalPer100g * factor,
      protein: food.proteinPer100g * factor,
      carb: food.carbPer100g * factor,
      fat: food.fatPer100g * factor,
    );
  }
}
