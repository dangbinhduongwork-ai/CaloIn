import 'package:flutter_test/flutter_test.dart';
import 'package:caloin/core/utils/formatters.dart';
import 'package:caloin/core/utils/unit_converter.dart';
import 'package:caloin/features/diary/domain/daily_nutrition_aggregator.dart';
import 'package:caloin/features/diary/domain/diary_validator.dart';
import 'package:caloin/features/diary/domain/food_log_entry.dart';
import 'package:caloin/features/diary/domain/meal_type.dart';
import 'package:caloin/features/foods/domain/food.dart';
import 'package:caloin/features/foods/domain/food_nutrition_calculator.dart';
import 'package:caloin/features/foods/domain/food_validator.dart';
import 'package:caloin/features/foods/domain/nutrition.dart';
import 'package:caloin/features/profile/domain/bmr_calculator.dart';
import 'package:caloin/features/profile/domain/calorie_goal_calculator.dart';
import 'package:caloin/features/profile/domain/macro_calculator.dart';
import 'package:caloin/features/profile/domain/macro_split.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/profile_validator.dart';
import 'package:caloin/features/profile/domain/tdee_calculator.dart';

void main() {
  group('BmrCalculator', () {
    test('Calculates Mifflin-St Jeor BMR for male and female', () {
      // Nam 30 tuổi, 70 kg, 175 cm → 1648.75
      final maleBmr = BmrCalculator.calculate(
        gender: Gender.male,
        weightKg: 70.0,
        heightCm: 175.0,
        age: 30,
      );
      expect(maleBmr, closeTo(1648.75, 1e-4));

      // Nữ 25 tuổi, 60 kg, 165 cm → 1345.25
      final femaleBmr = BmrCalculator.calculate(
        gender: Gender.female,
        weightKg: 60.0,
        heightCm: 165.0,
        age: 25,
      );
      expect(femaleBmr, closeTo(1345.25, 1e-4));
    });
  });

  group('TdeeCalculator', () {
    test('Calculates TDEE across all 5 activity levels', () {
      const maleBmr = 1648.75;

      // Sedentary: 1.2
      final sedentaryTdee = TdeeCalculator.calculate(
        bmr: maleBmr,
        activityLevel: ActivityLevel.sedentary,
      );
      expect(sedentaryTdee, closeTo(1978.5, 1e-4));

      // Light: 1.375
      final lightTdee = TdeeCalculator.calculate(
        bmr: maleBmr,
        activityLevel: ActivityLevel.light,
      );
      expect(lightTdee, closeTo(2267.03125, 1e-4));

      // Moderate: 1.55
      final moderateTdee = TdeeCalculator.calculate(
        bmr: maleBmr,
        activityLevel: ActivityLevel.moderate,
      );
      expect(moderateTdee, closeTo(2555.5625, 1e-4));

      // Very active: 1.725
      final veryActiveTdee = TdeeCalculator.calculate(
        bmr: maleBmr,
        activityLevel: ActivityLevel.veryActive,
      );
      expect(veryActiveTdee, closeTo(2844.09375, 1e-4));

      // Extra active: 1.9
      final extraActiveTdee = TdeeCalculator.calculate(
        bmr: maleBmr,
        activityLevel: ActivityLevel.extraActive,
      );
      expect(extraActiveTdee, closeTo(3132.625, 1e-4));
    });
  });

  group('CalorieGoalCalculator', () {
    test('Calculates maintain, lose, and gain goals rounded to 10 kcal', () {
      // Nam 30 tuổi, 70 kg, 175 cm, mức vừa (TDEE = 2555.5625)
      final maintainResult = CalorieGoalCalculator.calculate(
        gender: Gender.male,
        age: 30,
        heightCm: 175.0,
        weightKg: 70.0,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.maintain,
      );
      expect(maintainResult.targetKcal, 2560);
      expect(maintainResult.floorApplied, isFalse);
      expect(maintainResult.lossNotAdvisable, isFalse);

      final loseResult = CalorieGoalCalculator.calculate(
        gender: Gender.male,
        age: 30,
        heightCm: 175.0,
        weightKg: 70.0,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.lose,
      );
      expect(loseResult.targetKcal, 2060);
      expect(loseResult.floorApplied, isFalse);
      expect(loseResult.lossNotAdvisable, isFalse);

      final gainResult = CalorieGoalCalculator.calculate(
        gender: Gender.male,
        age: 30,
        heightCm: 175.0,
        weightKg: 70.0,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.gain,
      );
      expect(gainResult.targetKcal, 2860);
      expect(gainResult.floorApplied, isFalse);
      expect(gainResult.lossNotAdvisable, isFalse);
    });

    test('Applies safe floor when target < floor and floor < TDEE', () {
      // Nữ 35 tuổi, 55 kg, 160 cm, mức nhẹ (TDEE 1669.25), giảm cân → tính ra 1169.25 < 1200 => target = 1200, floorApplied = true
      final result = CalorieGoalCalculator.calculate(
        gender: Gender.female,
        age: 35,
        heightCm: 160.0,
        weightKg: 55.0,
        activityLevel: ActivityLevel.light,
        goal: Goal.lose,
      );

      expect(result.tdee, closeTo(1669.25, 1e-4));
      expect(result.targetKcal, 1200);
      expect(result.floorApplied, isTrue);
      expect(result.lossNotAdvisable, isFalse);
    });

    test('Marks lossNotAdvisable when floor >= TDEE, but allows maintain without floor', () {
      // Nữ 60 tuổi, 45 kg, 150 cm, ít vận động (TDEE 1111.8), giảm cân
      final loseResult = CalorieGoalCalculator.calculate(
        gender: Gender.female,
        age: 60,
        heightCm: 150.0,
        weightKg: 45.0,
        activityLevel: ActivityLevel.sedentary,
        goal: Goal.lose,
      );

      expect(loseResult.tdee, closeTo(1111.8, 1e-4));
      expect(loseResult.targetKcal, 1110);
      expect(loseResult.lossNotAdvisable, isTrue);
      expect(loseResult.floorApplied, isFalse);

      // Cùng người này chọn giữ cân: target = 1110, không áp dụng sàn, không cảnh báo
      final maintainResult = CalorieGoalCalculator.calculate(
        gender: Gender.female,
        age: 60,
        heightCm: 150.0,
        weightKg: 45.0,
        activityLevel: ActivityLevel.sedentary,
        goal: Goal.maintain,
      );
      expect(maintainResult.targetKcal, 1110);
      expect(maintainResult.lossNotAdvisable, isFalse);
      expect(maintainResult.floorApplied, isFalse);
    });
  });

  group('MacroCalculator & MacroSplit', () {
    test('Calculates grams from target kcal and MacroSplit', () {
      // 2000 kcal, tỉ lệ 20/50/30 → protein 100 g, carb 250 g, fat 66.667 g
      const split = MacroSplit(proteinPct: 20, carbPct: 50, fatPct: 30);
      expect(split.isValid, isTrue);

      final grams = MacroCalculator.calculateGrams(
        targetKcal: 2000,
        macroSplit: split,
      );

      expect(grams.proteinGrams, closeTo(100.0, 1e-4));
      expect(grams.carbGrams, closeTo(250.0, 1e-4));
      expect(grams.fatGrams, closeTo(66.6667, 1e-3));
    });

    test('Rejects invalid MacroSplit when total != 100 or negative', () {
      const invalidSplit = MacroSplit(proteinPct: 30, carbPct: 50, fatPct: 30); // 110
      expect(invalidSplit.isValid, isFalse);

      final result = ProfileValidator.validateMacroSplit(invalidSplit);
      expect(result.isValid, isFalse);
      expect(result.errorCode, 'macroSumNot100');

      const negativeSplit = MacroSplit(proteinPct: -10, carbPct: 60, fatPct: 50);
      expect(negativeSplit.isValid, isFalse);
      final negResult = ProfileValidator.validateMacroSplit(negativeSplit);
      expect(negResult.isValid, isFalse);
      expect(negResult.errorCode, 'macroNegative');
    });

    test('Calculates total kcal from macro grams (4/4/9)', () {
      // macro 20/50/10 g → 370 kcal
      final kcal = MacroCalculator.calculateKcalFromMacros(
        proteinGrams: 20.0,
        carbGrams: 50.0,
        fatGrams: 10.0,
      );
      expect(kcal, closeTo(370.0, 1e-4));
    });
  });

  group('FoodNutritionCalculator & Nutrition', () {
    test('Calculates food nutrition scaled by grams', () {
      // 130 kcal, 2.7 g đạm, 28 g carb, 0.3 g béo trên 100 g, ăn 150 g → 195 kcal, 4.05, 42, 0.45
      const food = Food(
        id: 'test_food',
        nameVi: 'Cơm trắng',
        nameEn: 'White Rice',
        kcalPer100g: 130.0,
        proteinPer100g: 2.7,
        carbPer100g: 28.0,
        fatPer100g: 0.3,
        defaultServingGrams: 150.0,
        servingLabelKey: 'bowl',
        category: 'rice',
      );

      final nutrition = FoodNutritionCalculator.calculate(
        food: food,
        grams: 150.0,
      );

      expect(nutrition.kcal, closeTo(195.0, 1e-4));
      expect(nutrition.protein, closeTo(4.05, 1e-4));
      expect(nutrition.carb, closeTo(42.0, 1e-4));
      expect(nutrition.fat, closeTo(0.45, 1e-4));
    });

    test('Nutrition operations and zero object', () {
      const n1 = Nutrition(kcal: 100, protein: 10, carb: 10, fat: 2);
      const n2 = Nutrition(kcal: 200, protein: 15, carb: 20, fat: 5);
      final sum = n1 + n2;

      expect(sum.kcal, closeTo(300, 1e-4));
      expect(sum.protein, closeTo(25, 1e-4));
      expect(sum.carb, closeTo(30, 1e-4));
      expect(sum.fat, closeTo(7, 1e-4));

      final scaled = n1 * 2.0;
      expect(scaled.kcal, closeTo(200, 1e-4));

      expect(Nutrition.zero.kcal, 0.0);
    });
  });

  group('DailyNutritionAggregator', () {
    test('Empty day returns zero nutrition and full target remaining', () {
      final summary = DailyNutritionAggregator.aggregate(
        entries: [],
        targetKcal: 2000,
      );

      expect(summary.totalKcal, 0);
      expect(summary.remainingKcal, 2000);
      expect(summary.isExceeded, isFalse);
      expect(summary.exceededKcal, 0);
      expect(summary.subtotalByMeal[MealType.breakfast], Nutrition.zero);
      expect(summary.subtotalByMeal[MealType.lunch], Nutrition.zero);
      expect(summary.subtotalByMeal[MealType.dinner], Nutrition.zero);
      expect(summary.subtotalByMeal[MealType.snack], Nutrition.zero);
    });

    test('Aggregates multiple meals with empty meals and quick add', () {
      final now = DateTime(2026, 10, 7, 12, 0);
      final entries = [
        FoodLogEntry(
          id: '1',
          foodId: 'pho_bo',
          foodNameSnapshot: 'Phở bò',
          mealType: MealType.breakfast,
          grams: 450,
          nutrition: const Nutrition(kcal: 450, protein: 25, carb: 65, fat: 10),
          loggedAt: now,
        ),
        FoodLogEntry(
          id: '2',
          foodId: 'com_tam',
          foodNameSnapshot: 'Cơm tấm',
          mealType: MealType.lunch,
          grams: 350,
          nutrition: const Nutrition(kcal: 600, protein: 30, carb: 75, fat: 20),
          loggedAt: now,
        ),
        // Quick add (grams is null, foodId is null)
        FoodLogEntry(
          id: '3',
          foodId: null,
          foodNameSnapshot: 'Trà sữa chiều',
          mealType: MealType.snack,
          grams: null,
          nutrition: const Nutrition(kcal: 350, protein: 2, carb: 60, fat: 12),
          isQuickAdd: true,
          loggedAt: now,
        ),
      ];

      final summary = DailyNutritionAggregator.aggregate(
        entries: entries,
        targetKcal: 2000,
      );

      expect(summary.totalKcal, 1400);
      expect(summary.remainingKcal, 600);
      expect(summary.isExceeded, isFalse);
      expect(summary.exceededKcal, 0);

      expect(summary.subtotalByMeal[MealType.breakfast]!.kcal, closeTo(450, 1e-4));
      expect(summary.subtotalByMeal[MealType.lunch]!.kcal, closeTo(600, 1e-4));
      expect(summary.subtotalByMeal[MealType.dinner]!.kcal, closeTo(0, 1e-4)); // Empty meal
      expect(summary.subtotalByMeal[MealType.snack]!.kcal, closeTo(350, 1e-4));
    });

    test('Calculates negative remaining calories when exceeding target', () {
      final entries = [
        FoodLogEntry(
          id: '1',
          foodNameSnapshot: 'Buffet',
          mealType: MealType.dinner,
          grams: 1000,
          nutrition: const Nutrition(kcal: 2350, protein: 120, carb: 200, fat: 90),
          loggedAt: DateTime.now(),
        ),
      ];

      final summary = DailyNutritionAggregator.aggregate(
        entries: entries,
        targetKcal: 2000,
      );

      expect(summary.totalKcal, 2350);
      expect(summary.remainingKcal, -350);
      expect(summary.isExceeded, isTrue);
      expect(summary.exceededKcal, 350);
    });
  });

  group('Validators (Profile, Food, Diary)', () {
    test('ProfileValidator validates age boundaries and underAge code', () {
      expect(ProfileValidator.validateAge(18).isValid, isTrue); // Exact lower bound
      expect(ProfileValidator.validateAge(19).isValid, isTrue); // Near lower bound inside
      expect(ProfileValidator.validateAge(100).isValid, isTrue); // Exact upper bound
      expect(ProfileValidator.validateAge(99).isValid, isTrue); // Near upper bound inside

      final underAgeResult = ProfileValidator.validateAge(17); // Near lower bound outside
      expect(underAgeResult.isValid, isFalse);
      expect(underAgeResult.errorCode, 'underAge');

      final tooHighResult = ProfileValidator.validateAge(101); // Near upper bound outside
      expect(tooHighResult.isValid, isFalse);
      expect(tooHighResult.errorCode, 'ageTooHigh');
    });

    test('ProfileValidator validates height and weight boundaries', () {
      expect(ProfileValidator.validateHeight(100.0).isValid, isTrue);
      expect(ProfileValidator.validateHeight(250.0).isValid, isTrue);
      expect(ProfileValidator.validateHeight(99.9).errorCode, 'heightTooLow');
      expect(ProfileValidator.validateHeight(250.1).errorCode, 'heightTooHigh');

      expect(ProfileValidator.validateWeight(30.0).isValid, isTrue);
      expect(ProfileValidator.validateWeight(300.0).isValid, isTrue);
      expect(ProfileValidator.validateWeight(29.9).errorCode, 'weightTooLow');
      expect(ProfileValidator.validateWeight(300.1).errorCode, 'weightTooHigh');
    });

    test('FoodValidator validates custom food and macro limits with tolerance', () {
      // Valid custom food
      final valid = FoodValidator.validateCustomFood(
        name: 'Gà áp chảo',
        kcalPer100g: 165.0,
        proteinPer100g: 31.0,
        carbPer100g: 0.0,
        fatPer100g: 3.6,
      );
      expect(valid.isValid, isTrue);

      // Empty name
      expect(
        FoodValidator.validateCustomFood(
          name: '',
          kcalPer100g: 100,
          proteinPer100g: 10,
          carbPer100g: 10,
          fatPer100g: 2,
        ).errorCode,
        'nameRequired',
      );

      // Kcal > 900
      expect(
        FoodValidator.validateCustomFood(
          name: 'Dầu ăn tinh khiết',
          kcalPer100g: 901,
          proteinPer100g: 0,
          carbPer100g: 0,
          fatPer100g: 100,
        ).errorCode,
        'kcalTooHigh',
      );

      // Total macro sum <= 100 with 0.5 tolerance: 100.4 is accepted, 100.6 is rejected
      expect(
        FoodValidator.validateCustomFood(
          name: 'Food near boundary within tolerance',
          kcalPer100g: 400,
          proteinPer100g: 50.2,
          carbPer100g: 50.2,
          fatPer100g: 0.0, // total 100.4 <= 100.5
        ).isValid,
        isTrue,
      );

      expect(
        FoodValidator.validateCustomFood(
          name: 'Food exceeding boundary',
          kcalPer100g: 500,
          proteinPer100g: 50.3,
          carbPer100g: 50.3,
          fatPer100g: 0.0, // total 100.6 > 100.5
        ).errorCode,
        'macroSumExceeds100',
      );
    });

    test('DiaryValidator validates grams (1–5000g) and quick add (1–10000 kcal)', () {
      expect(DiaryValidator.validateGrams(1.0).isValid, isTrue);
      expect(DiaryValidator.validateGrams(5000.0).isValid, isTrue);
      expect(DiaryValidator.validateGrams(0.0).errorCode, 'gramsTooLow');
      expect(DiaryValidator.validateGrams(-10.0).errorCode, 'gramsTooLow');
      expect(DiaryValidator.validateGrams(5001.0).errorCode, 'gramsTooHigh');

      expect(DiaryValidator.validateQuickAddKcal(1.0).isValid, isTrue);
      expect(DiaryValidator.validateQuickAddKcal(10000.0).isValid, isTrue);
      expect(DiaryValidator.validateQuickAddKcal(0.0).errorCode, 'kcalTooLow');
      expect(DiaryValidator.validateQuickAddKcal(10001.0).errorCode, 'kcalTooHigh');
    });
  });

  group('UnitConverter and Formatters', () {
    test('Two-way conversions have error < 0.01', () {
      // kg <-> lb
      const testKg = 72.5;
      final lb = UnitConverter.kgToLb(testKg);
      final roundTripKg = UnitConverter.lbToKg(lb);
      expect((roundTripKg - testKg).abs(), lessThan(0.01));

      // cm <-> ft/in
      const testCm = 175.0;
      final ftIn = UnitConverter.cmToFtIn(testCm);
      final roundTripCm = UnitConverter.ftInToCm(ftIn.feet, ftIn.inches);
      expect((roundTripCm - testCm).abs(), lessThan(0.01));
    });

    test('AppFormatters formats kcal as integer and macros with 1 decimal', () {
      expect(AppFormatters.formatKcal(1234.6), '1235');
      expect(AppFormatters.formatKcalWithUnit(1234.2), '1234 kcal');
      expect(AppFormatters.formatMacro(25.56), '25.6');
      expect(AppFormatters.formatMacroWithUnit(25.54), '25.5 g');
    });
  });
}
