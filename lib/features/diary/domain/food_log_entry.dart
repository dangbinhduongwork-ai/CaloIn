import '../foods/domain/nutrition.dart';
import 'meal_type.dart';

class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    this.foodId,
    required this.foodNameSnapshot,
    required this.mealType,
    this.grams,
    required this.nutrition,
    this.isQuickAdd = false,
    required this.loggedAt,
  });

  final String id;
  final String? foodId;
  final String foodNameSnapshot;
  final MealType mealType;
  final double? grams;
  final Nutrition nutrition;
  final bool isQuickAdd;
  final DateTime loggedAt;

  FoodLogEntry copyWith({
    String? id,
    String? foodId,
    String? foodNameSnapshot,
    MealType? mealType,
    double? grams,
    Nutrition? nutrition,
    bool? isQuickAdd,
    DateTime? loggedAt,
  }) {
    return FoodLogEntry(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodNameSnapshot: foodNameSnapshot ?? this.foodNameSnapshot,
      mealType: mealType ?? this.mealType,
      grams: grams ?? this.grams,
      nutrition: nutrition ?? this.nutrition,
      isQuickAdd: isQuickAdd ?? this.isQuickAdd,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          foodId == other.foodId &&
          foodNameSnapshot == other.foodNameSnapshot &&
          mealType == other.mealType &&
          ((grams == null && other.grams == null) ||
              (grams != null && other.grams != null && (grams! - other.grams!).abs() < 1e-4)) &&
          nutrition == other.nutrition &&
          isQuickAdd == other.isQuickAdd &&
          loggedAt.isAtSameMomentAs(other.loggedAt);

  @override
  int get hashCode => Object.hash(
        id,
        foodId,
        foodNameSnapshot,
        mealType,
        grams,
        nutrition,
        isQuickAdd,
        loggedAt.millisecondsSinceEpoch,
      );

  @override
  String toString() =>
      'FoodLogEntry($foodNameSnapshot, meal: $mealType, grams: $grams, ${nutrition.kcal.toStringAsFixed(1)} kcal)';
}
