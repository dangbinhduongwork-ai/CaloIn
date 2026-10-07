import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../foods/domain/food.dart';
import '../../profile/data/profile_providers.dart';
import '../domain/daily_nutrition_aggregator.dart';
import '../domain/daily_nutrition_summary.dart';
import '../domain/food_log_entry.dart';
import '../domain/food_log_repository.dart';
import '../domain/meal_type.dart';
import 'food_log_repository_impl.dart';

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FoodLogRepositoryImpl(db);
});

/// Null represents "today", which automatically tracks current day across midnight
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final effectiveDateProvider = Provider<DateTime>((ref) {
  final selected = ref.watch(selectedDateProvider);
  if (selected != null) {
    return DateTime(selected.year, selected.month, selected.day);
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final foodLogsForDayStreamProvider = StreamProvider.family<List<FoodLogEntry>, DateTime>((ref, date) {
  final repo = ref.watch(foodLogRepositoryProvider);
  return repo.watchDay(date);
});

final daySummaryProvider = Provider.family<DailyNutritionSummary, DateTime>((ref, date) {
  final entriesAsync = ref.watch(foodLogsForDayStreamProvider(date));
  final entries = entriesAsync.value ?? [];
  final target = ref.watch(nutritionTargetProvider);
  final targetKcal = target?.targetKcal ?? 2000;

  return DailyNutritionAggregator.aggregate(
    entries: entries,
    targetKcal: targetKcal,
  );
});

final recentFoodsFutureProvider = FutureProvider<List<Food>>((ref) async {
  final repo = ref.watch(foodLogRepositoryProvider);
  return repo.recentFoods(limit: 20);
});

/// Determine default meal type by current time of day:
/// 5h - 10h: Sáng (Breakfast)
/// 10h - 14h: Trưa (Lunch)
/// 14h - 17h: Phụ (Snack)
/// 17h - 22h: Tối (Dinner)
/// Còn lại: Phụ (Snack)
MealType getDefaultMealTypeForTime([DateTime? time]) {
  final now = time ?? DateTime.now();
  final hour = now.hour;
  if (hour >= 5 && hour < 10) {
    return MealType.breakfast;
  } else if (hour >= 10 && hour < 14) {
    return MealType.lunch;
  } else if (hour >= 14 && hour < 17) {
    return MealType.snack;
  } else if (hour >= 17 && hour < 22) {
    return MealType.dinner;
  } else {
    return MealType.snack;
  }
}
