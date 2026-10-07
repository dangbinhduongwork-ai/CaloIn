import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../diary/data/diary_providers.dart';
import '../../diary/domain/food_log_entry.dart';
import '../../diary/domain/meal_type.dart';
import '../../profile/data/profile_providers.dart';
import 'widgets/calorie_progress_ring.dart';
import 'widgets/macro_bars_card.dart';
import 'widgets/meal_section_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatDateTitle(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(date.year, date.month, date.day);

    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');

    if (compareDate == today) {
      return 'Hôm nay, $dayStr/$monthStr';
    } else if (compareDate == yesterday) {
      return 'Hôm qua, $dayStr/$monthStr';
    } else {
      return '$dayStr/$monthStr/${date.year}';
    }
  }

  void _previousDay(WidgetRef ref) {
    final current = ref.read(effectiveDateProvider);
    final prev = current.subtract(const Duration(days: 1));
    ref.read(selectedDateProvider.notifier).state = prev;
  }

  void _nextDay(WidgetRef ref) {
    final current = ref.read(effectiveDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (current.isBefore(today)) {
      final next = current.add(const Duration(days: 1));
      if (next == today) {
        // Reset to null so it automatically tracks today across midnight
        ref.read(selectedDateProvider.notifier).state = null;
      } else {
        ref.read(selectedDateProvider.notifier).state = next;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentDate = ref.watch(effectiveDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = currentDate == today;

    final summary = ref.watch(daySummaryProvider(currentDate));
    final target = ref.watch(nutritionTargetProvider);
    final logsAsync = ref.watch(foodLogsForDayStreamProvider(currentDate));

    final entries = logsAsync.value ?? <FoodLogEntry>[];
    final breakfastEntries = entries.where((e) => e.mealType == MealType.breakfast).toList();
    final lunchEntries = entries.where((e) => e.mealType == MealType.lunch).toList();
    final dinnerEntries = entries.where((e) => e.mealType == MealType.dinner).toList();
    final snackEntries = entries.where((e) => e.mealType == MealType.snack).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Navigation Bar
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        tooltip: 'Ngày trước',
                        onPressed: () => _previousDay(ref),
                      ),
                      Text(
                        _formatDateTitle(currentDate, context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        tooltip: 'Ngày sau',
                        onPressed: isToday ? null : () => _nextDay(ref),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Animated Calorie Progress Ring
              CalorieProgressRing(
                consumedKcal: summary.totalKcal,
                targetKcal: summary.targetKcal,
                remainingKcal: summary.remainingKcal,
                isExceeded: summary.isExceeded,
              ),
              const SizedBox(height: 16),

              // Macro Nutrient Progress Bars
              MacroBarsCard(
                consumedProtein: summary.total.protein,
                targetProtein: target?.proteinGrams ?? 0.0,
                consumedCarb: summary.total.carb,
                targetCarb: target?.carbGrams ?? 0.0,
                consumedFat: summary.total.fat,
                targetFat: target?.fatGrams ?? 0.0,
              ),
              const SizedBox(height: 20),

              // 4 Meal Sections
              MealSectionCard(
                mealType: MealType.breakfast,
                entries: breakfastEntries,
                targetDate: currentDate,
              ),
              const SizedBox(height: 12),
              MealSectionCard(
                mealType: MealType.lunch,
                entries: lunchEntries,
                targetDate: currentDate,
              ),
              const SizedBox(height: 12),
              MealSectionCard(
                mealType: MealType.dinner,
                entries: dinnerEntries,
                targetDate: currentDate,
              ),
              const SizedBox(height: 12),
              MealSectionCard(
                mealType: MealType.snack,
                entries: snackEntries,
                targetDate: currentDate,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ghi món'),
        onPressed: () {
          context.push('/diary/add');
        },
      ),
    );
  }
}
