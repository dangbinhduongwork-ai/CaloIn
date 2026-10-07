import '../../foods/domain/nutrition.dart';
import 'meal_type.dart';

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.total,
    required this.subtotalByMeal,
    required this.targetKcal,
    required this.remainingKcal,
  });

  final Nutrition total;
  final Map<MealType, Nutrition> subtotalByMeal;
  final int targetKcal;
  final int remainingKcal;

  Map<MealType, Nutrition> get meals => subtotalByMeal;
  bool get isExceeded => remainingKcal < 0;
  int get exceededKcal => remainingKcal < 0 ? -remainingKcal : 0;
  int get totalKcal => total.kcal.round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyNutritionSummary &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          targetKcal == other.targetKcal &&
          remainingKcal == other.remainingKcal &&
          _mapsEqual(subtotalByMeal, other.subtotalByMeal);

  static bool _mapsEqual(
    Map<MealType, Nutrition> a,
    Map<MealType, Nutrition> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        total,
        targetKcal,
        remainingKcal,
        Object.hashAll(subtotalByMeal.entries),
      );

  @override
  String toString() =>
      'DailyNutritionSummary(total: ${totalKcal} kcal, target: $targetKcal, remaining: $remainingKcal)';
}
