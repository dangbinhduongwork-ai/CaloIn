import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../diary/data/diary_providers.dart';
import '../../diary/domain/food_log_entry.dart';
import '../../profile/data/profile_providers.dart';
import '../domain/nutrition_history_aggregator.dart';

enum HistoryViewMode {
  day,
  week,
  month,
}

enum ChartDisplayMode {
  calorie,
  macro,
}

class DateRange {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start.year == other.start.year &&
          start.month == other.start.month &&
          start.day == other.start.day &&
          end.year == other.end.year &&
          end.month == other.end.month &&
          end.day == other.end.day;

  @override
  int get hashCode => Object.hash(start.year, start.month, start.day, end.year, end.month, end.day);
}

final historyViewModeProvider = StateProvider<HistoryViewMode>((ref) => HistoryViewMode.week);

final historyChartDisplayModeProvider = StateProvider<ChartDisplayMode>((ref) => ChartDisplayMode.calorie);

final historyReferenceDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

DateRange calculateHistoryDateRange({
  required HistoryViewMode mode,
  required DateTime refDate,
}) {
  final cleanDate = DateTime(refDate.year, refDate.month, refDate.day);

  switch (mode) {
    case HistoryViewMode.day:
      return DateRange(start: cleanDate, end: cleanDate);

    case HistoryViewMode.week:
      // Week starts on Monday (DateTime.monday = 1)
      final monday = DateTime(cleanDate.year, cleanDate.month, cleanDate.day - (cleanDate.weekday - 1));
      final sunday = DateTime(monday.year, monday.month, monday.day + 6);
      return DateRange(start: monday, end: sunday);

    case HistoryViewMode.month:
      final firstDay = DateTime(cleanDate.year, cleanDate.month, 1);
      final lastDay = DateTime(cleanDate.year, cleanDate.month + 1, 0);
      return DateRange(start: firstDay, end: lastDay);
  }
}

final historyDateRangeProvider = Provider<DateRange>((ref) {
  final mode = ref.watch(historyViewModeProvider);
  final refDate = ref.watch(historyReferenceDateProvider);
  return calculateHistoryDateRange(mode: mode, refDate: refDate);
});

bool canNavigateNextHistory({
  required HistoryViewMode mode,
  required DateTime refDate,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final cleanToday = DateTime(today.year, today.month, today.day);
  final cleanRef = DateTime(refDate.year, refDate.month, refDate.day);

  switch (mode) {
    case HistoryViewMode.day:
      return cleanRef.isBefore(cleanToday);

    case HistoryViewMode.week:
      final currentMonday = DateTime(cleanToday.year, cleanToday.month, cleanToday.day - (cleanToday.weekday - 1));
      final refMonday = DateTime(cleanRef.year, cleanRef.month, cleanRef.day - (cleanRef.weekday - 1));
      return refMonday.isBefore(currentMonday);

    case HistoryViewMode.month:
      if (cleanRef.year < cleanToday.year) return true;
      if (cleanRef.year == cleanToday.year) {
        return cleanRef.month < cleanToday.month;
      }
      return false;
  }
}

final canHistoryGoNextProvider = Provider<bool>((ref) {
  final mode = ref.watch(historyViewModeProvider);
  final refDate = ref.watch(historyReferenceDateProvider);
  return canNavigateNextHistory(mode: mode, refDate: refDate);
});

final historyLogsStreamProvider = StreamProvider<List<FoodLogEntry>>((ref) {
  final range = ref.watch(historyDateRangeProvider);
  final repo = ref.watch(foodLogRepositoryProvider);

  final startOfDay = DateTime(range.start.year, range.start.month, range.start.day, 0, 0, 0, 0);
  final endOfDay = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59, 999);

  return repo.watchRange(startOfDay, endOfDay);
});

final historyReportProvider = Provider<AsyncValue<HistoryReport>>((ref) {
  final range = ref.watch(historyDateRangeProvider);
  final entriesAsync = ref.watch(historyLogsStreamProvider);
  final target = ref.watch(nutritionTargetProvider);
  final targetKcal = target?.targetKcal ?? 2000;

  return entriesAsync.whenData((entries) {
    return NutritionHistoryAggregator.aggregate(
      entries: entries,
      startDate: range.start,
      endDate: range.end,
      targetKcal: targetKcal,
    );
  });
});
