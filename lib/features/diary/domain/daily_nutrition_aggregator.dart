import '../../foods/domain/nutrition.dart';
import 'daily_nutrition_summary.dart';
import 'food_log_entry.dart';
import 'meal_type.dart';

class DailyNutritionAggregator {
  DailyNutritionAggregator._();

  /// Aggregates food log entries into daily summary and meal subtotals.
  static DailyNutritionSummary aggregate({
    required List<FoodLogEntry> entries,
    required int targetKcal,
  }) {
    Nutrition total = Nutrition.zero;
    final Map<MealType, Nutrition> subtotals = {
      for (final type in MealType.values) type: Nutrition.zero,
    };

    for (final entry in entries) {
      total = total + entry.nutrition;
      subtotals[entry.mealType] = (subtotals[entry.mealType] ?? Nutrition.zero) + entry.nutrition;
    }

    final int totalRoundedKcal = total.kcal.round();
    final int remainingKcal = targetKcal - totalRoundedKcal;

    return DailyNutritionSummary(
      total: total,
      subtotalByMeal: subtotals,
      targetKcal: targetKcal,
      remainingKcal: remainingKcal,
    );
  }
}
