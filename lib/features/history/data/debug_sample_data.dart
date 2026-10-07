import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import '../../diary/domain/meal_type.dart';

/// Populates 60 days of sample meal entries for debug/demo testing.
/// Intentionally leaves ~6 days unlogged to test the missing days aggregation logic.
/// Only runs in [kDebugMode].
Future<int> generate60DaysSampleData(AppDatabase db) async {
  if (!kDebugMode) return 0;

  final random = Random(42); // deterministic seed for reproducibility
  final today = DateTime.now();
  int insertedCount = 0;

  // Meal templates (realistic Vietnamese meals with P, C, F)
  final breakfastOptions = [
    _SampleFood('Phở bò tái', 525, 28.0, 75.0, 13.0, 500),
    _SampleFood('Bánh mì ốp la', 370, 14.0, 48.0, 14.0, 160),
    _SampleFood('Bún chả Hà Nội', 550, 26.0, 68.0, 19.0, 450),
    _SampleFood('Yến mạch chuối mật ong', 320, 10.0, 58.0, 5.0, 250),
    _SampleFood('Xôi xéo', 440, 12.0, 72.0, 11.0, 200),
  ];

  final lunchOptions = [
    _SampleFood('Cơm tấm sườn nướng', 615, 27.0, 82.0, 20.0, 350),
    _SampleFood('Cơm gà xối mỡ', 680, 34.0, 78.0, 24.0, 380),
    _SampleFood('Bún bò Huế', 580, 30.0, 70.0, 18.0, 500),
    _SampleFood('Cơm văn phòng cá kho', 540, 26.0, 68.0, 16.0, 320),
    _SampleFood('Mì Quảng gà', 490, 24.0, 62.0, 15.0, 400),
  ];

  final dinnerOptions = [
    _SampleFood('Cơm trắng thịt kho tàu', 650, 28.0, 76.0, 25.0, 350),
    _SampleFood('Canh chua cá lóc & cơm', 460, 28.0, 60.0, 10.0, 400),
    _SampleFood('Bò lúc lắc khoai tây', 590, 38.0, 45.0, 27.0, 320),
    _SampleFood('Ức gà áp chảo bông cải', 390, 42.0, 20.0, 12.0, 300),
    _SampleFood('Lẩu hải sản (1 phần)', 520, 35.0, 45.0, 18.0, 450),
  ];

  final snackOptions = [
    _SampleFood('Sữa chua Hy Lạp hạt chia', 160, 12.0, 15.0, 5.0, 150),
    _SampleFood('Chuối tiêu & bơ đậu phộng', 210, 6.0, 32.0, 8.0, 140),
    _SampleFood('Cà phê sữa đá ít đường', 130, 2.5, 20.0, 4.0, 200),
    _SampleFood('Táo Mỹ & phô mai', 140, 5.0, 22.0, 4.0, 160),
    _SampleFood('Trứng gà luộc (2 quả)', 155, 13.0, 1.0, 10.5, 110),
  ];

  // Specific days to leave intentionally unlogged out of 60 days (e.g. days 7, 15, 24, 38, 49, 56)
  final unloggedDayOffsets = {7, 15, 24, 38, 49, 56};

  await db.transaction(() async {
    for (int dayOffset = 59; dayOffset >= 0; dayOffset--) {
      if (unloggedDayOffsets.contains(dayOffset)) {
        // Intentionally left blank (no food logs)
        continue;
      }

      final logDate = today.subtract(Duration(days: dayOffset));

      // 1. Breakfast (8:00 AM)
      final bf = breakfastOptions[random.nextInt(breakfastOptions.length)];
      await db.into(db.foodLogs).insert(
            FoodLogsCompanion.insert(
              id: 'sample_bf_${dayOffset}_${random.nextInt(10000)}',
              foodNameSnapshot: bf.name,
              mealType: MealType.breakfast.name,
              grams: Value(bf.grams),
              kcal: bf.kcal,
              protein: bf.protein,
              carb: bf.carb,
              fat: bf.fat,
              isQuickAdd: const Value(false),
              loggedAt: DateTime(logDate.year, logDate.month, logDate.day, 8, random.nextInt(30)),
            ),
          );
      insertedCount++;

      // 2. Lunch (12:30 PM)
      final lunch = lunchOptions[random.nextInt(lunchOptions.length)];
      await db.into(db.foodLogs).insert(
            FoodLogsCompanion.insert(
              id: 'sample_lu_${dayOffset}_${random.nextInt(10000)}',
              foodNameSnapshot: lunch.name,
              mealType: MealType.lunch.name,
              grams: Value(lunch.grams),
              kcal: lunch.kcal,
              protein: lunch.protein,
              carb: lunch.carb,
              fat: lunch.fat,
              isQuickAdd: const Value(false),
              loggedAt: DateTime(logDate.year, logDate.month, logDate.day, 12, 15 + random.nextInt(30)),
            ),
          );
      insertedCount++;

      // 3. Dinner (19:00 PM)
      final din = dinnerOptions[random.nextInt(dinnerOptions.length)];
      await db.into(db.foodLogs).insert(
            FoodLogsCompanion.insert(
              id: 'sample_din_${dayOffset}_${random.nextInt(10000)}',
              foodNameSnapshot: din.name,
              mealType: MealType.dinner.name,
              grams: Value(din.grams),
              kcal: din.kcal,
              protein: din.protein,
              carb: din.carb,
              fat: din.fat,
              isQuickAdd: const Value(false),
              loggedAt: DateTime(logDate.year, logDate.month, logDate.day, 19, random.nextInt(40)),
            ),
          );
      insertedCount++;

      // 4. Snack (occasional, 70% of days, at 15:30 PM)
      if (random.nextDouble() < 0.7) {
        final snack = snackOptions[random.nextInt(snackOptions.length)];
        await db.into(db.foodLogs).insert(
              FoodLogsCompanion.insert(
                id: 'sample_snk_${dayOffset}_${random.nextInt(10000)}',
                foodNameSnapshot: snack.name,
                mealType: MealType.snack.name,
                grams: Value(snack.grams),
                kcal: snack.kcal,
                protein: snack.protein,
                carb: snack.carb,
                fat: snack.fat,
                isQuickAdd: const Value(false),
                loggedAt: DateTime(logDate.year, logDate.month, logDate.day, 15, 30 + random.nextInt(20)),
              ),
            );
        insertedCount++;
      }
    }
  });

  return insertedCount;
}

class _SampleFood {
  const _SampleFood(this.name, this.kcal, this.protein, this.carb, this.fat, this.grams);
  final String name;
  final double kcal;
  final double protein;
  final double carb;
  final double fat;
  final double grams;
}
