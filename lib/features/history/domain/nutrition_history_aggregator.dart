import '../../diary/domain/daily_nutrition_aggregator.dart';
import '../../diary/domain/daily_nutrition_summary.dart';
import '../../diary/domain/food_log_entry.dart';

class DayHistoryItem {
  const DayHistoryItem({
    required this.date,
    required this.summary,
    required this.hasLog,
    required this.entries,
  });

  final DateTime date;
  final DailyNutritionSummary summary;
  final bool hasLog;
  final List<FoodLogEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayHistoryItem &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          summary == other.summary &&
          hasLog == other.hasLog;

  @override
  int get hashCode => Object.hash(date.year, date.month, date.day, summary, hasLog);

  @override
  String toString() =>
      'DayHistoryItem(${date.year}-${date.month}-${date.day}: ${summary.totalKcal} kcal, hasLog: $hasLog)';
}

class HistoryReport {
  const HistoryReport({
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.targetKcal,
    required this.daysWithLogCount,
    required this.totalDays,
    required this.averageKcal,
    required this.averageProtein,
    required this.averageCarb,
    required this.averageFat,
    this.highestDay,
    this.lowestDay,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<DayHistoryItem> days;
  final int targetKcal;
  final int daysWithLogCount;
  final int totalDays;
  final double averageKcal;
  final double averageProtein;
  final double averageCarb;
  final double averageFat;
  final DayHistoryItem? highestDay;
  final DayHistoryItem? lowestDay;

  bool get isEmpty => daysWithLogCount == 0;
}

class NutritionHistoryAggregator {
  NutritionHistoryAggregator._();

  /// Aggregates food log entries across a date range.
  /// Generates a DayHistoryItem for EVERY day in the range.
  /// Days without logs have `hasLog: false` and are NOT factored into averages.
  static HistoryReport aggregate({
    required List<FoodLogEntry> entries,
    required DateTime startDate,
    required DateTime endDate,
    required int targetKcal,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Group entries by normalized date key (yyyy-MM-dd)
    final Map<int, List<FoodLogEntry>> entriesByDay = {};
    for (final entry in entries) {
      final key = DateTime(entry.loggedAt.year, entry.loggedAt.month, entry.loggedAt.day).millisecondsSinceEpoch;
      entriesByDay.putIfAbsent(key, () => []).add(entry);
    }

    final List<DayHistoryItem> days = [];
    DateTime cursor = start;

    double sumKcal = 0.0;
    double sumProtein = 0.0;
    double sumCarb = 0.0;
    double sumFat = 0.0;
    int daysWithLog = 0;

    DayHistoryItem? highest;
    DayHistoryItem? lowest;

    while (!cursor.isAfter(end)) {
      final key = cursor.millisecondsSinceEpoch;
      final dayEntries = entriesByDay[key] ?? [];
      final hasLog = dayEntries.isNotEmpty;

      final summary = DailyNutritionAggregator.aggregate(
        entries: dayEntries,
        targetKcal: targetKcal,
      );

      final dayItem = DayHistoryItem(
        date: cursor,
        summary: summary,
        hasLog: hasLog,
        entries: dayEntries,
      );
      days.add(dayItem);

      if (hasLog) {
        daysWithLog++;
        sumKcal += summary.total.kcal;
        sumProtein += summary.total.protein;
        sumCarb += summary.total.carb;
        sumFat += summary.total.fat;

        if (highest == null || summary.total.kcal > highest.summary.total.kcal) {
          highest = dayItem;
        }
        if (lowest == null || summary.total.kcal < lowest.summary.total.kcal) {
          lowest = dayItem;
        }
      }

      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    final totalDays = days.length;
    final avgKcal = daysWithLog > 0 ? (sumKcal / daysWithLog) : 0.0;
    final avgProtein = daysWithLog > 0 ? (sumProtein / daysWithLog) : 0.0;
    final avgCarb = daysWithLog > 0 ? (sumCarb / daysWithLog) : 0.0;
    final avgFat = daysWithLog > 0 ? (sumFat / daysWithLog) : 0.0;

    return HistoryReport(
      startDate: start,
      endDate: end,
      days: days,
      targetKcal: targetKcal,
      daysWithLogCount: daysWithLog,
      totalDays: totalDays,
      averageKcal: avgKcal,
      averageProtein: avgProtein,
      averageCarb: avgCarb,
      averageFat: avgFat,
      highestDay: highest,
      lowestDay: lowest,
    );
  }
}
