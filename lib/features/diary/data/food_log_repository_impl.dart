import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../foods/domain/food.dart';
import '../../foods/domain/nutrition.dart';
import '../domain/food_log_entry.dart';
import '../domain/food_log_repository.dart';
import '../domain/meal_type.dart';

class FoodLogRepositoryImpl implements FoodLogRepository {
  FoodLogRepositoryImpl(this._db);

  final AppDatabase _db;

  FoodLogEntry _toDomain(FoodLogEntryData row) {
    return FoodLogEntry(
      id: row.id,
      foodId: row.foodId,
      foodNameSnapshot: row.foodNameSnapshot,
      mealType: MealType.values.byName(row.mealType),
      grams: row.grams,
      nutrition: Nutrition(
        kcal: row.kcal,
        protein: row.protein,
        carb: row.carb,
        fat: row.fat,
      ),
      isQuickAdd: row.isQuickAdd,
      loggedAt: row.loggedAt,
    );
  }

  Food _toFoodEntity(FoodEntry row) {
    return Food(
      id: row.id.toString(),
      nameVi: row.nameVi,
      nameEn: row.nameEn,
      kcalPer100g: row.kcalPer100g,
      proteinPer100g: row.proteinPer100g,
      carbPer100g: row.carbPer100g,
      fatPer100g: row.fatPer100g,
      defaultServingGrams: row.defaultServingGrams,
      servingLabelKey: row.servingLabelKey,
      category: row.category,
      isCustom: row.isCustom,
      isFavorite: row.isFavorite,
      dataQuality: row.dataQuality,
    );
  }

  @override
  Future<void> add(FoodLogEntry entry) async {
    final companion = FoodLogsCompanion.insert(
      id: entry.id,
      foodId: Value(entry.foodId),
      foodNameSnapshot: entry.foodNameSnapshot,
      mealType: entry.mealType.name,
      grams: Value(entry.grams),
      kcal: entry.nutrition.kcal,
      protein: entry.nutrition.protein,
      carb: entry.nutrition.carb,
      fat: entry.nutrition.fat,
      isQuickAdd: Value(entry.isQuickAdd),
      loggedAt: entry.loggedAt,
    );
    await _db.into(_db.foodLogs).insert(companion);
  }

  @override
  Future<void> update(FoodLogEntry entry) async {
    await (_db.update(_db.foodLogs)..where((tbl) => tbl.id.equals(entry.id))).write(
      FoodLogsCompanion(
        foodId: Value(entry.foodId),
        foodNameSnapshot: Value(entry.foodNameSnapshot),
        mealType: Value(entry.mealType.name),
        grams: Value(entry.grams),
        kcal: Value(entry.nutrition.kcal),
        protein: Value(entry.nutrition.protein),
        carb: Value(entry.nutrition.carb),
        fat: Value(entry.nutrition.fat),
        isQuickAdd: Value(entry.isQuickAdd),
        loggedAt: Value(entry.loggedAt),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.foodLogs)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<FoodLogEntry?> getById(String id) async {
    final query = _db.select(_db.foodLogs)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Stream<List<FoodLogEntry>> watchDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = _db.select(_db.foodLogs)
      ..where((tbl) => tbl.loggedAt.isBiggerOrEqualValue(startOfDay) & tbl.loggedAt.isSmallerOrEqualValue(endOfDay))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.loggedAt)]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<FoodLogEntry>> watchRange(DateTime from, DateTime to) {
    final query = _db.select(_db.foodLogs)
      ..where((tbl) => tbl.loggedAt.isBiggerOrEqualValue(from) & tbl.loggedAt.isSmallerOrEqualValue(to))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.loggedAt)]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Food>> recentFoods({int limit = 20}) async {
    // Select recent logs with non-null foodId, sorted by loggedAt descending
    final query = _db.select(_db.foodLogs)
      ..where((tbl) => tbl.foodId.isNotNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.loggedAt)]);

    final rows = await query.get();

    // Deduplicate food IDs in order of recency
    final uniqueFoodIds = <String>[];
    for (final r in rows) {
      if (r.foodId != null && !uniqueFoodIds.contains(r.foodId)) {
        uniqueFoodIds.add(r.foodId!);
        if (uniqueFoodIds.length >= limit) break;
      }
    }

    if (uniqueFoodIds.isEmpty) return [];

    final resultFoods = <Food>[];
    for (final foodIdStr in uniqueFoodIds) {
      final intId = int.tryParse(foodIdStr);
      if (intId != null) {
        final foodRow = await (_db.select(_db.foods)..where((tbl) => tbl.id.equals(intId))).getSingleOrNull();
        if (foodRow != null) {
          resultFoods.add(_toFoodEntity(foodRow));
        }
      }
    }

    return resultFoods;
  }

  @override
  Future<int> copyMeal(DateTime fromDate, MealType mealType, DateTime toDate) async {
    final startOfDay = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0, 0);
    final endOfDay = DateTime(fromDate.year, fromDate.month, fromDate.day, 23, 59, 59, 999);

    final fromRows = await (_db.select(_db.foodLogs)
          ..where((tbl) =>
              tbl.loggedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.loggedAt.isSmallerOrEqualValue(endOfDay) &
              tbl.mealType.equals(mealType.name)))
        .get();

    if (fromRows.isEmpty) return 0;

    int copiedCount = 0;
    await _db.transaction(() async {
      for (int i = 0; i < fromRows.length; i++) {
        final orig = fromRows[i];
        final newId = 'copy_${DateTime.now().microsecondsSinceEpoch}_$i';
        final newLoggedAt = DateTime(
          toDate.year,
          toDate.month,
          toDate.day,
          orig.loggedAt.hour,
          orig.loggedAt.minute,
          orig.loggedAt.second,
        );

        final companion = FoodLogsCompanion.insert(
          id: newId,
          foodId: Value(orig.foodId),
          foodNameSnapshot: orig.foodNameSnapshot,
          mealType: orig.mealType,
          grams: Value(orig.grams),
          kcal: orig.kcal,
          protein: orig.protein,
          carb: orig.carb,
          fat: orig.fat,
          isQuickAdd: Value(orig.isQuickAdd),
          loggedAt: newLoggedAt,
        );

        await _db.into(_db.foodLogs).insert(companion);
        copiedCount++;
      }
    });

    return copiedCount;
  }
}
