import 'package:flutter_test/flutter_test.dart';
import 'package:caloin/features/diary/domain/food_log_entry.dart';
import 'package:caloin/features/diary/domain/meal_type.dart';
import 'package:caloin/features/foods/domain/nutrition.dart';
import 'package:caloin/features/history/domain/nutrition_history_aggregator.dart';

void main() {
  group('NutritionHistoryAggregator Unit Tests', () {
    test('Khoảng rỗng (không có bản ghi nào): số ngày có ghi = 0, trung bình = 0, highest/lowest = null', () {
      final startDate = DateTime(2026, 10, 1);
      final endDate = DateTime(2026, 10, 7);

      final report = NutritionHistoryAggregator.aggregate(
        entries: [],
        startDate: startDate,
        endDate: endDate,
        targetKcal: 2000,
      );

      expect(report.totalDays, equals(7));
      expect(report.daysWithLogCount, equals(0));
      expect(report.isEmpty, isTrue);
      expect(report.averageKcal, equals(0.0));
      expect(report.averageProtein, equals(0.0));
      expect(report.averageCarb, equals(0.0));
      expect(report.averageFat, equals(0.0));
      expect(report.highestDay, isNull);
      expect(report.lowestDay, isNull);

      // Verify each day has hasLog == false
      for (final day in report.days) {
        expect(day.hasLog, isFalse);
        expect(day.entries, isEmpty);
        expect(day.summary.total.kcal, equals(0.0));
      }
    });

    test('Ngày thiếu dữ liệu KHÔNG kéo thấp trung bình (chia theo số ngày có ghi)', () {
      final startDate = DateTime(2026, 10, 1);
      final endDate = DateTime(2026, 10, 7); // 7 days

      final entries = [
        // Day 1 (10/01): 2000 kcal (Protein 100g, Carb 250g, Fat 66g)
        FoodLogEntry(
          id: '1',
          foodNameSnapshot: 'Món ngày 1',
          mealType: MealType.lunch,
          nutrition: const Nutrition(kcal: 2000, protein: 100, carb: 250, fat: 66),
          loggedAt: DateTime(2026, 10, 1, 12, 0),
        ),
        // Day 4 (10/04): 2200 kcal (Protein 120g, Carb 270g, Fat 70g)
        FoodLogEntry(
          id: '2',
          foodNameSnapshot: 'Món ngày 4',
          mealType: MealType.dinner,
          nutrition: const Nutrition(kcal: 2200, protein: 120, carb: 270, fat: 70),
          loggedAt: DateTime(2026, 10, 4, 19, 0),
        ),
      ];

      final report = NutritionHistoryAggregator.aggregate(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
        targetKcal: 2000,
      );

      expect(report.totalDays, equals(7));
      expect(report.daysWithLogCount, equals(2));
      expect(report.isEmpty, isFalse);

      // Average kcal must be (2000 + 2200) / 2 = 2100.0, NOT 4200 / 7 = 600.0!
      expect(report.averageKcal, equals(2100.0));
      expect(report.averageProtein, equals((100 + 120) / 2));
      expect(report.averageCarb, equals((250 + 270) / 2));
      expect(report.averageFat, equals((66 + 70) / 2));

      // Highest day is Day 4 (2200 kcal), Lowest day is Day 1 (2000 kcal)
      expect(report.highestDay, isNotNull);
      expect(report.highestDay!.date.day, equals(4));
      expect(report.highestDay!.summary.totalKcal, equals(2200));

      expect(report.lowestDay, isNotNull);
      expect(report.lowestDay!.date.day, equals(1));
      expect(report.lowestDay!.summary.totalKcal, equals(2000));

      // Days 2, 3, 5, 6, 7 have hasLog == false
      expect(report.days[0].hasLog, isTrue);
      expect(report.days[1].hasLog, isFalse);
      expect(report.days[2].hasLog, isFalse);
      expect(report.days[3].hasLog, isTrue);
      expect(report.days[4].hasLog, isFalse);
      expect(report.days[5].hasLog, isFalse);
      expect(report.days[6].hasLog, isFalse);
    });

    test('Tháng 28 ngày (Tháng 2 năm thường 2025)', () {
      final start = DateTime(2025, 2, 1);
      final end = DateTime(2025, 2, 28);

      final report = NutritionHistoryAggregator.aggregate(
        entries: [],
        startDate: start,
        endDate: end,
        targetKcal: 2000,
      );

      expect(report.totalDays, equals(28));
      expect(report.days.first.date.day, equals(1));
      expect(report.days.last.date.day, equals(28));
    });

    test('Tháng 29 ngày (Tháng 2 năm nhuận 2024)', () {
      final start = DateTime(2024, 2, 1);
      final end = DateTime(2024, 2, 29);

      final report = NutritionHistoryAggregator.aggregate(
        entries: [],
        startDate: start,
        endDate: end,
        targetKcal: 2000,
      );

      expect(report.totalDays, equals(29));
      expect(report.days.first.date.day, equals(1));
      expect(report.days.last.date.day, equals(29));
    });

    test('Tháng 30 ngày (Tháng 4) và Tháng 31 ngày (Tháng 3)', () {
      final march = NutritionHistoryAggregator.aggregate(
        entries: [],
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
        targetKcal: 2000,
      );
      expect(march.totalDays, equals(31));

      final april = NutritionHistoryAggregator.aggregate(
        entries: [],
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 30),
        targetKcal: 2000,
      );
      expect(april.totalDays, equals(30));
    });

    test('Chuyển giao năm (31/12 đến 01/01)', () {
      final start = DateTime(2025, 12, 29);
      final end = DateTime(2026, 1, 4); // 7 days week crossing new year

      final entries = [
        FoodLogEntry(
          id: 'old_year',
          foodNameSnapshot: 'Tất niên',
          mealType: MealType.dinner,
          nutrition: const Nutrition(kcal: 2500, protein: 100, carb: 250, fat: 80),
          loggedAt: DateTime(2025, 12, 31, 20, 0),
        ),
        FoodLogEntry(
          id: 'new_year',
          foodNameSnapshot: 'Tân niên',
          mealType: MealType.lunch,
          nutrition: const Nutrition(kcal: 1800, protein: 80, carb: 200, fat: 50),
          loggedAt: DateTime(2026, 1, 1, 12, 0),
        ),
      ];

      final report = NutritionHistoryAggregator.aggregate(
        entries: entries,
        startDate: start,
        endDate: end,
        targetKcal: 2000,
      );

      expect(report.totalDays, equals(7));
      expect(report.daysWithLogCount, equals(2));
      expect(report.averageKcal, equals((2500 + 1800) / 2));

      // Check dates order: Dec 29, 30, 31, Jan 1, 2, 3, 4
      expect(report.days[0].date, equals(DateTime(2025, 12, 29)));
      expect(report.days[1].date, equals(DateTime(2025, 12, 30)));
      expect(report.days[2].date, equals(DateTime(2025, 12, 31)));
      expect(report.days[3].date, equals(DateTime(2026, 1, 1)));
      expect(report.days[4].date, equals(DateTime(2026, 1, 2)));
      expect(report.days[5].date, equals(DateTime(2026, 1, 3)));
      expect(report.days[6].date, equals(DateTime(2026, 1, 4)));

      expect(report.days[2].hasLog, isTrue);
      expect(report.days[3].hasLog, isTrue);
      expect(report.highestDay!.summary.totalKcal, equals(2500));
      expect(report.lowestDay!.summary.totalKcal, equals(1800));
    });
  });
}
