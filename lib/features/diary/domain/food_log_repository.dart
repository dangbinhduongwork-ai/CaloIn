import '../../foods/domain/food.dart';
import 'food_log_entry.dart';
import 'meal_type.dart';

abstract class FoodLogRepository {
  Future<void> add(FoodLogEntry entry);
  Future<void> update(FoodLogEntry entry);
  Future<void> delete(String id);
  Future<FoodLogEntry?> getById(String id);
  Stream<List<FoodLogEntry>> watchDay(DateTime date);
  Stream<List<FoodLogEntry>> watchRange(DateTime from, DateTime to);
  Future<List<Food>> recentFoods({int limit = 20});
  Future<int> copyMeal(DateTime fromDate, MealType mealType, DateTime toDate);
}
