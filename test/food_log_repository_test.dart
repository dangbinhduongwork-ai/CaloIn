import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/features/diary/data/food_log_repository_impl.dart';
import 'package:caloin/features/diary/domain/food_log_entry.dart';
import 'package:caloin/features/diary/domain/meal_type.dart';
import 'package:caloin/features/foods/data/food_repository_impl.dart';
import 'package:caloin/features/foods/domain/food.dart';
import 'package:caloin/features/foods/domain/nutrition.dart';

void main() {
  group('FoodLogRepositoryImpl In-Memory Database Tests', () {
    late AppDatabase db;
    late FoodLogRepositoryImpl logRepo;
    late FoodRepositoryImpl foodRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      logRepo = FoodLogRepositoryImpl(db);
      foodRepo = FoodRepositoryImpl(db: db);

      // Seed a sample food
      await foodRepo.seedFoods([
        {
          'seedKey': 'pho_bo',
          'nameVi': 'Phở bò',
          'nameEn': 'Beef Pho',
          'kcalPer100g': 105.0,
          'proteinPer100g': 5.5,
          'carbPer100g': 15.0,
          'fatPer100g': 2.5,
          'defaultServingGrams': 500.0,
          'servingLabelKey': 'bowl',
          'category': 'carb',
        },
        {
          'seedKey': 'com_tam',
          'nameVi': 'Cơm tấm',
          'nameEn': 'Broken Rice',
          'kcalPer100g': 175.0,
          'proteinPer100g': 7.5,
          'carbPer100g': 23.5,
          'fatPer100g': 5.5,
          'defaultServingGrams': 350.0,
          'servingLabelKey': 'plate',
          'category': 'carb',
        },
      ], version: 1);
    });

    tearDown(() async {
      await db.close();
    });

    test('add, update, delete food log entries', () async {
      final entry = FoodLogEntry(
        id: 'entry_1',
        foodId: '1',
        foodNameSnapshot: 'Phở bò',
        mealType: MealType.breakfast,
        grams: 500,
        nutrition: const Nutrition(kcal: 525, protein: 27.5, carb: 75, fat: 12.5),
        loggedAt: DateTime(2026, 10, 7, 8, 30),
      );

      await logRepo.add(entry);
      final retrieved = await logRepo.getById('entry_1');
      expect(retrieved, isNotNull);
      expect(retrieved?.foodNameSnapshot, 'Phở bò');
      expect(retrieved?.nutrition.kcal, 525);

      // Update
      final updated = entry.copyWith(
        grams: 400,
        nutrition: const Nutrition(kcal: 420, protein: 22, carb: 60, fat: 10),
      );
      await logRepo.update(updated);
      final afterUpdate = await logRepo.getById('entry_1');
      expect(afterUpdate?.grams, 400);
      expect(afterUpdate?.nutrition.kcal, 420);

      // Delete
      await logRepo.delete('entry_1');
      final afterDelete = await logRepo.getById('entry_1');
      expect(afterDelete, isNull);
    });

    test('Queries within day boundaries (00:00:00 and 23:59:59)', () async {
      final date = DateTime(2026, 10, 7);

      // Exact start of day (00:00:00)
      await logRepo.add(
        FoodLogEntry(
          id: 'start_day',
          foodNameSnapshot: 'Nước lọc',
          mealType: MealType.breakfast,
          nutrition: Nutrition.zero,
          loggedAt: DateTime(2026, 10, 7, 0, 0, 0, 0),
        ),
      );

      // Middle of day
      await logRepo.add(
        FoodLogEntry(
          id: 'mid_day',
          foodNameSnapshot: 'Cơm tấm',
          mealType: MealType.lunch,
          nutrition: const Nutrition(kcal: 600, protein: 20, carb: 70, fat: 15),
          loggedAt: DateTime(2026, 10, 7, 12, 30),
        ),
      );

      // Exact end of day (23:59:59)
      await logRepo.add(
        FoodLogEntry(
          id: 'end_day',
          foodNameSnapshot: 'Sữa chua đêm',
          mealType: MealType.snack,
          nutrition: const Nutrition(kcal: 100, protein: 3, carb: 15, fat: 3),
          loggedAt: DateTime(2026, 10, 7, 23, 59, 59, 999),
        ),
      );

      // Next day (00:00:00 of next day - should NOT be included)
      await logRepo.add(
        FoodLogEntry(
          id: 'next_day',
          foodNameSnapshot: 'Bữa sáng ngày mai',
          mealType: MealType.breakfast,
          nutrition: const Nutrition(kcal: 300, protein: 10, carb: 40, fat: 5),
          loggedAt: DateTime(2026, 10, 8, 0, 0, 0, 0),
        ),
      );

      final dayEntries = await logRepo.watchDay(date).first;
      expect(dayEntries.length, 3);
      expect(dayEntries.map((e) => e.id), containsAll(['start_day', 'mid_day', 'end_day']));
      expect(dayEntries.map((e) => e.id), isNot(contains('next_day')));
    });

    test('recentFoods returns unique foods ordered by most recent log time', () async {
      // Log food 1, then food 2, then food 1 again
      await logRepo.add(
        FoodLogEntry(
          id: 'log_1',
          foodId: '1',
          foodNameSnapshot: 'Phở bò',
          mealType: MealType.breakfast,
          nutrition: const Nutrition(kcal: 500, protein: 25, carb: 70, fat: 10),
          loggedAt: DateTime(2026, 10, 5, 8, 0),
        ),
      );

      await logRepo.add(
        FoodLogEntry(
          id: 'log_2',
          foodId: '2',
          foodNameSnapshot: 'Cơm tấm',
          mealType: MealType.lunch,
          nutrition: const Nutrition(kcal: 600, protein: 25, carb: 80, fat: 15),
          loggedAt: DateTime(2026, 10, 6, 12, 0),
        ),
      );

      await logRepo.add(
        FoodLogEntry(
          id: 'log_3',
          foodId: '1',
          foodNameSnapshot: 'Phở bò',
          mealType: MealType.dinner,
          nutrition: const Nutrition(kcal: 500, protein: 25, carb: 70, fat: 10),
          loggedAt: DateTime(2026, 10, 7, 19, 0),
        ),
      );

      final recents = await logRepo.recentFoods(limit: 10);
      expect(recents.length, 2);
      // Most recently logged food was food 1 (Phở bò on Oct 7)
      expect(recents[0].nameVi, contains('Phở bò'));
      expect(recents[1].nameVi, contains('Cơm tấm'));
    });

    test('copyMeal copies meal entries with snapshot values to target date', () async {
      final fromDate = DateTime(2026, 10, 6);
      final toDate = DateTime(2026, 10, 7);

      // Add 2 items to yesterday breakfast
      await logRepo.add(
        FoodLogEntry(
          id: 'yest_1',
          foodId: '1',
          foodNameSnapshot: 'Phở bò',
          mealType: MealType.breakfast,
          nutrition: const Nutrition(kcal: 525, protein: 27.5, carb: 75, fat: 12.5),
          loggedAt: DateTime(2026, 10, 6, 7, 30),
        ),
      );

      await logRepo.add(
        FoodLogEntry(
          id: 'yest_2',
          foodId: null,
          foodNameSnapshot: 'Quẩy giòn',
          mealType: MealType.breakfast,
          nutrition: const Nutrition(kcal: 150, protein: 3, carb: 20, fat: 7),
          isQuickAdd: true,
          loggedAt: DateTime(2026, 10, 6, 7, 35),
        ),
      );

      final count = await logRepo.copyMeal(fromDate, MealType.breakfast, toDate);
      expect(count, 2);

      final todayEntries = await logRepo.watchDay(toDate).first;
      expect(todayEntries.length, 2);
      expect(todayEntries.map((e) => e.foodNameSnapshot), containsAll(['Phở bò', 'Quẩy giòn']));
      expect(todayEntries.first.loggedAt.day, 7);
      expect(todayEntries.first.nutrition.kcal, 525);
    });

    test('Snapshot nutrition does not change when custom food is updated', () async {
      // Add a custom food
      const customFood = Food(
        id: '',
        nameVi: 'Sinh tố bơ tự làm',
        nameEn: 'Avocado Smoothie',
        kcalPer100g: 150,
        proteinPer100g: 2,
        carbPer100g: 20,
        fatPer100g: 8,
        defaultServingGrams: 200,
        servingLabelKey: 'cup',
        category: 'drink',
        isCustom: true,
      );
      final insertedFood = await foodRepo.addCustomFood(customFood);

      // Log it
      await logRepo.add(
        FoodLogEntry(
          id: 'log_snapshot_test',
          foodId: insertedFood.id,
          foodNameSnapshot: insertedFood.nameVi,
          mealType: MealType.snack,
          grams: 200,
          nutrition: const Nutrition(kcal: 300, protein: 4, carb: 40, fat: 16),
          loggedAt: DateTime(2026, 10, 7, 15, 0),
        ),
      );

      // Now change food in food library (e.g. kcal to 200)
      final modifiedFood = insertedFood.copyWith(kcalPer100g: 200);
      await foodRepo.updateCustomFood(modifiedFood);

      // The snapshot log entry MUST retain original 300 kcal!
      final logAfterFoodEdit = await logRepo.getById('log_snapshot_test');
      expect(logAfterFoodEdit?.nutrition.kcal, 300);
    });
  });
}
